/**
 * Copyright: Copyright (c) 2011-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.arguments.Arguments;

import std.conv;

import tango.util.container.HashMap;
import tango.util.container.more.Stack;

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

	package Internal.Arguments arguments;

	private
	{
		Options options;
		HashMap!(string, ArgumentBase) positionalArguments;
		ArgumentProxy proxy;
		
		string[] originalArgs_;
		string[] args_;
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

	void parse (string[] input)
	{
		originalArgs = input;
		arguments.passThrough = passThrough;

		if (!arguments.parse(originalArgs, sloppy))
			assert(0, "throw InvalidArgumentException");

		args = cast(string[]) arguments(null).assigned;
		parsePositionalArguments();
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
		return "Help Text";
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

	private void parsePositionalArguments ()
	{
		if (args.isEmpty)
			return;

		auto posArgs = positionalArguments.toArray;
		posArgs.sort!((a, b) => a.position < b.position)();

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

		if (arg.min > arg.rawValues.length)
			assert(0, "too few arguments, throw here instead.");
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

		string name;
		string helpText;
		string defaults_;

		string[] values_;
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
			assert(hasValue);
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