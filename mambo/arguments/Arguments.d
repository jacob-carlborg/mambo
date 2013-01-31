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
		Options optionProxy;
		HashMap!(string, ArgumentBase) positionalArguments_;
		ArgumentProxy proxy;
		ArgumentBase[] sortedPosArgs_;
		Formatter formatter_;

		string[] originalArgs_;
		string[] args_;
	}

	alias option this;

	this (string shortPrefix = "-", string longPrefix = "--", char assignment = '=')
	{
		this.shortPrefix = shortPrefix;
		this.longPrefix = longPrefix;
		this.assignment = assignment;

		internalArguments = new Internal.Arguments(shortPrefix, longPrefix, assignment);
		optionProxy = Options(this);
		positionalArguments_ = new HashMap!(string, ArgumentBase);
		proxy = ArgumentProxy.create(this);
	}

	@property Formatter formatter ()
	{
		return formatter_ = formatter_ ? formatter_ : Formatter.instance(this);
	}

	Option!(T) opIndex (T = string) (string name)
	{
		return option.opIndex!(T)(name);
	}

	string opIndex () (size_t index)
	{
		if (index > args.length || isEmpty)
			assert(0, "throw MissingArgumentException - Missing argument(s)");

		return args[index];
	}

	@property Options option ()
	{
		return optionProxy;
	}

	@property ArgumentProxy argument () ()
	{
		return proxy;
	}

	Argument!(T) argument (T = string) (string name, string helpText)
	{
		return proxy.opCall!(T)(name, helpText);
	}

	bool parse (string[] input)
	{
		originalArgs = input;
		internalArguments.passThrough = passThrough;
		auto result = internalArguments.parse(originalArgs, sloppy);

		if (!result)
			return false;

		args = cast(string[]) internalArguments(null).assigned;
		return result && parsePositionalArguments();
	}

	@property string first ()
	{
		return this[0];
	}

	@property string last ()
	{
		return this[args.length - 1];
	}

	@property bool isEmpty ()
	{
		return args.isEmpty;
	}

	@property bool any ()
	{
		return args.any;
	}

	@property string helpText ()
	{
		return formatter.helpText();
	}

	@property ArgumentBase[] positionalArguments ()
	{
		return positionalArguments_.toArray();
	}

	@property Option!(int)[] options ()
	{
		return optionProxy.options;
	}

	@property string[] args ()
	{
		return args_;
	}

	private @property string[] args (string[] args)
	{
		return args_ = args;
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
		auto len = args.length;

		for (size_t i = 1; i < len; i++)
		{
			auto value = args[i];

			if (value == "--")
				break;

			else if (value.startsWith(longPrefix) || value.startsWith(shortPrefix))
				continue;

			arg.values_ ~= value;
			args = args.remove(i);
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
}

struct ArgumentProxy
{
	private Arguments arguments;

	static ArgumentProxy create (Arguments arguments)
	{
		ArgumentProxy proxy;
		proxy.arguments = arguments;

		return proxy;
	}

	Argument!(T) opCall (T = string) (string name, string helpText)
	{
		assert(!arguments.positionalArguments_.containsKey(name));

		auto arg = new Argument!(T)(arguments.positionalArguments_.size, name);
		arg.help(helpText);
		arguments.positionalArguments_[name] = arg;

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
		return cast(Argument!(T)) arguments.positionalArguments_[name];
	}
}

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