/**
 * Copyright: Copyright (c) 2011-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.arguments.Arguments;

import std.conv;

import tango.util.container.HashMap;

import Internal = mambo.arguments.internal.Arguments;
import mambo.arguments.Formatter;
import mambo.arguments.Options;
import mambo.core._;
import mambo.util.Traits;

class Arguments
{
	immutable string shortPrefix;
	immutable string longPrefix;
	immutable char assignment;

	bool sloppy;
	bool passThrough;

	string header;
	string footer = "Use the `-h' flag for help.";

	package Internal.Arguments internalArguments;

	private
	{
		alias ArgumentStore = HashMap!(string, ArgumentBase);

		ArgumentStore positionalArguments_;
		ArgumentStore commands_;

		Options optionProxy;
		PositionalProxy positionalProxy;
		CommandProxy commandProxy;

		ArgumentBase[] sortedPosArgs_;
		Formatter formatter_;

		string[] originalArgs_;
		string[] rawArgs_;
	}

	alias option this;

	this (string shortPrefix = "-", string longPrefix = "--", char assignment = '=')
	{
		this.shortPrefix = shortPrefix;
		this.longPrefix = longPrefix;
		this.assignment = assignment;

		internalArguments = new Internal.Arguments(shortPrefix, longPrefix, assignment);
		positionalArguments_ = new ArgumentStore;
		commands_ = new ArgumentStore;
		optionProxy = Options(this);
		positionalProxy = PositionalProxy(this);
		commandProxy = CommandProxy(this);
	}

	@property Formatter formatter ()
	{
		return formatter_ = formatter_ ? formatter_ : Formatter.instance(this);
	}

	@property Formatter formatter (Formatter formatter)
	{
		return formatter_ = formatter;
	}

	Option!(T) opIndex (T = string) (string name)
	{
		return option.opIndex!(T)(name);
	}

	string opIndex () (size_t index)
	{
		if (index > rawArgs.length || isEmpty)
			assert(0, "throw MissingArgumentException - Missing argument(s)");

		return rawArgs[index];
	}

	@property Options option ()
	{
		return optionProxy;
	}

	@property PositionalProxy positional () ()
	{
		return positionalProxy;
	}

	Argument!(T) positional (T = string) (string name, string helpText)
	{
		return positionalProxy.opCall!(T)(name, helpText);
	}

	@property CommandProxy command () ()
	{
		return commandProxy;
	}

	Argument!(T) command (T = string) (string name, string helpText)
	{
		return commandProxy.opCall!(T)(name, helpText);
	}

	bool parse (string[] input)
	{
		originalArgs = input;
		internalArguments.passThrough = passThrough;
		auto result = internalArguments.parse(originalArgs, sloppy);

		if (!result)
			return false;

		rawArgs = cast(string[]) internalArguments(null).assigned;
		parseCommand();
		return result && parsePositionalArguments();
	}

	@property string first ()
	{
		return this[0];
	}

	@property string last ()
	{
		return this[rawArgs.length - 1];
	}

	@property bool isEmpty ()
	{
		return rawArgs.isEmpty;
	}

	@property bool any ()
	{
		return rawArgs.any;
	}

	@property string helpText ()
	{
		return formatter.helpText();
	}

	@property ArgumentBase[] positionalArguments ()
	{
		return positionalArguments_.toArray();
	}

	@property ArgumentBase[] commands ()
	{
		return commands_.toArray();
	}

	@property Option!(int)[] options ()
	{
		return optionProxy.options;
	}

	@property string[] rawArgs ()
	{
		return rawArgs_;
	}

	private @property string[] rawArgs (string[] rawArgs)
	{
		return rawArgs_ = rawArgs;
	}

	@property string[] originalArgs ()
	{
		return originalArgs_;
	}

	private @property string[] originalArgs (string[] args)
	{
		return originalArgs_ = args;
	}

	string errors (char[] delegate (char[] buffer, const(char)[] format, ...) dg)
	{
		return internalArguments.errors(dg).assumeUnique;
	}

private:

	@property ArgumentBase[] sortedPosArgs ()
	{
		if (sortedPosArgs_.any)
			return sortedPosArgs_;

		sortedPosArgs_ = positionalArguments;
		sortedPosArgs_.sort!((a, b) => a.position < b.position)();

		return sortedPosArgs_;
	}

	bool parsePositionalArguments ()
	{
		int error;
		auto posArgs = sortedPosArgs;

		if (posArgs.isEmpty)
			return true;

		auto arg = posArgs.first;
		size_t numArgs;
		auto len = rawArgs.length;

		for (size_t i = 1; i < len; i++)
		{
			auto value = rawArgs[i];

			if (value == "--")
				break;

			else if (value.startsWith(longPrefix) || value.startsWith(shortPrefix))
				continue;

			arg.values_ ~= value;
			rawArgs = rawArgs.remove(i);
			len--;
			i--;

			if (++numArgs == arg.max)
			{
				if (numArgs >= posArgs.length)
					break;

				arg = posArgs[i - numArgs];
				numArgs = 0;
			}
		}

		foreach (e ; posArgs)
			error |= e.validate();

		return error == 0;
	}

	void parseCommand ()
	{
		if (commands.isEmpty)
			return;

		auto parsedCommands = rawArgs.filter!(e => !(e.startsWith(longPrefix) &&
			e.startsWith(shortPrefix)));

		if (parsedCommands.any)
		{
			auto cmd = parsedCommands.first;

			if (auto command = cmd in commands_)
			{
				rawArgs = rawArgs.remove(cmd);
				command.values_ ~= cmd;
			}
		}
	}
}

struct ArgumentProxy (string argumentStore)
{
	private Arguments arguments;

	this (Arguments arguments)
	{
		this.arguments = arguments;
	}

	Argument!(T) opCall (T = string) (string name, string helpText)
	{
		assert(!store.containsKey(name));

		auto arg = new Argument!(T)(store.size, name);
		arg.help(helpText);
		store[name] = arg;

		return arg;
	}

	template opDispatch (string name)
	{
		@property Argument!(T) opDispatch (T = string) ()
		{
			return opIndex!(T)(name);
		}
	}

	Argument!(T) opIndex (T = string) (string name)
	{
		return cast(Argument!(T)) store[name];
	}

	private auto store ()
	{
		mixin("return arguments." ~ argumentStore ~ ";");
	}
}

alias PositionalProxy = ArgumentProxy!("positionalArguments_");
alias CommandProxy = ArgumentProxy!("commands_");

class ArgumentBase
{
	int min = 1;
	int max = 1;

	private
	{
		enum maxParams = 42;
		size_t position_;
		string[] values_;
		int error_;

		string name_;
		string helpText_;
		string defaults_;
	}

	private this (size_t position, string name)
	{
		this.position_ = position;
		this.name_ = name;
	}

	@property string name ()
	{
		return name_;
	}

	@property string helpText ()
	{
		return helpText_;
	}

	private @property string helpText (string value)
	{
		return helpText_ = value;
	}

	@property size_t position ()
	{
		return position_;
	}

	@property int error ()
	{
		return error_;
	}

	private @property int error (int value)
	{
		return error_ = value;
	}

	@property bool hasValue ()
	{
		return values_.any;
	}

	@property U as (U) ()
	{
		static if (!isString!(U) && isArray!(U))
			return to!(U)(values_);

		else
		{
			assert(hasValue, "Missing value");
			return to!(U)(rawValue);
		}
	}

	@property string rawValue ()
	{
		return hasValue ? values_.first : "";
	}

	@property string[] rawValues ()
	{
		return values_;
	}

	private int validate ()
	{
		if (rawValues.length < min)
			error = Internal.Arguments.Argument.ParamLo;

		else if (rawValues.length > max)
			error = Internal.Arguments.Argument.ParamHi;

		return error;
	}
}

class Argument (T) : ArgumentBase
{
	alias value this;

	private this (size_t position, string name)
	{
		super(position, name);
	}

	@property T value ()
	{
		return as!(T);
	}

	@property T[] values ()
	{
		return as!(T[]);
	}

	Argument help (string text)
	{
		helpText = text;
		return this;
	}

	Argument defaults (string values)
	{
		defaults_ = values;
		return this;
	}

	Argument params ()
	{
		return params(1, maxParams);
	}

	Argument params (int count)
	{
		return params(count, count);
	}

	Argument params (int min, int max)
	{
		this.min = min;
		this.max = max;

		return this;
	}
}
