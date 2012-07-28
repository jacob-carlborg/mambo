/**
 * Copyright: Copyright (c) 2011-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.arguments.Arguments;

import std.conv;
import std.exception;

import tango.util.container.HashMap;

import Internal = mambo.arguments.internal.Arguments;
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

	package Internal.Arguments arguments;

	private
	{
		Options options;
		HashMap!(string, ArgumentBase) positionalArguments;
		ArgumentProxy proxy;
		ArgumentBase[] sortedPosArgs_;

		string[] originalArgs_;
		string[] args_;
		string[] errorMessages_ = defaultErrorMessages;
		enum defaultErrorMessages = [
			"argument '{0}' expects {2} parameter(s) but has {1}\n",
			"argument '{0}' expects {3} parameter(s) but has {1}\n",
			"argument '{0}' is missing\n",
			"argument '{0}' requires '{4}'\n",
			"argument '{0}' conflicts with '{4}'\n",
			"unexpected argument '{0}'\n",
			"argument '{0}' expects one of {5}\n",
			"invalid parameter for argument '{0}': {4}\n",
		];
	}

	alias option this;

	this (string shortPrefix = "-", string longPrefix = "--", char assignment = '=')
	{
		this.shortPrefix = shortPrefix;
		this.longPrefix = longPrefix;
		this.assignment = assignment;

		arguments = new Internal.Arguments(shortPrefix, longPrefix, assignment);
		options = Options(this);
		positionalArguments = new HashMap!(string, ArgumentBase);
		proxy = ArgumentProxy.create(this);
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
		return options;
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
		arguments.passThrough = passThrough;
		auto result = arguments.parse(originalArgs, sloppy);

		if (!result)
			return false;

		args = cast(string[]) arguments(null).assigned;
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
		return buildHelpText;
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
		auto res = arguments.errors(dg);
		string result = res.assumeUnique;
		char[256] buffer;
		auto msg = errorMessages;

		foreach (arg ; sortedPosArgs)
		{
			if (arg.error)
				result ~= dg(buffer, msg[arg.error - 1], arg.name, arg.rawValues.length,
					arg.min, arg.max);
		}

		return result;
	}

	@property string[] errorMessages ()
	{
		return errorMessages_;
	}

	@property string[] errorMessages (string[] errors)
	in
	{
		assert(errors.length == defaultErrorMessages.length);
	}
	body
	{
		return errorMessages_ = errors;
	}

private:

	@property ArgumentBase[] sortedPosArgs ()
	{
		if (sortedPosArgs_.any)
			return sortedPosArgs_;

		sortedPosArgs_ = positionalArguments.toArray;
		sortedPosArgs_.sort!((a, b) => a.position < b.position)();

		return sortedPosArgs_;
	}

	bool parsePositionalArguments ()
	{
		int error;
		auto posArgs = sortedPosArgs;

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

	string buildHelpText ()
	{
		static @property char shortOption (Internal.Arguments.Argument argument)
		{
			return argument.aliases.any ? argument.aliases[0] : char.init;
		}

		string help;
		auto len = lengthOfLongestOption;
		auto indentation = "    ";
		auto numberOfIndentations = 1;

		foreach (argument ; arguments.args)
		{
			auto text = argument.text ~ '.';
			auto name = argument.name;

			if (argument.min == 1)
				name ~= " <arg>";

			else if (argument.min > 1)
				name ~= " <arg0>";

			if (argument.max > 1)
				name ~= " .. <arg" ~ argument.max.toString ~ '>';

			if (argument.name.count == 0 && shortOption(argument) == char.init)
				help ~= format("{}\n", argument.text);

			else if (shortOption(argument) == char.init)
				help ~= format("{}--{}{}{}{}\n",
							indentation ~ indentation,
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							argument.text);

			else
				help ~= format("{}-{}, --{}{}{}{}\n",
							indentation,
							shortOption(argument),
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							argument.text);
		}

		return help;
	}

	@property size_t lengthOfLongestOption ()
	{
		return arguments.args.values.reduce!((a, b) => a.name.count > b.name.count ? a : b).name.count;
	}
}

class ArgumentBase 
{
	int min = 1;
	int max = 1;

	private
	{
		enum maxParams = 42;
		size_t position;
		string[] values_;
		int error;

		string name;
		string helpText;
		string defaults_;
	}

	private this (size_t position, string name)
	{
		this.position = position;
		this.name = name;
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
		assert(!arguments.positionalArguments.containsKey(name));

		auto arg = new Argument!(T)(arguments.positionalArguments.size, name);
		arguments.positionalArguments[name] = arg;

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
		return cast(Argument!(T)) arguments.positionalArguments[name];
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