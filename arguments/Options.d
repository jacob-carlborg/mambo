/**
 * Copyright: Copyright (c) 2011-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Apr 3, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */

module mambo.arguments.Options;

import std.conv;
import std.exception;

import mambo.core._;
import mambo.arguments.Arguments;
import Internal = mambo.arguments.internal.Arguments;

struct Options
{
	alias arguments this;

	private Arguments arguments;

	package this (Arguments arguments)
	{
		this.arguments = arguments;
	}

	Option!(T) opCall (T = string) (char shortOption, string longOption, string helpText)
	{
		return opIndex!(T)(longOption).aliased(shortOption).help(helpText);
	}

	Option!(T) opCall (T = string) (string longOption, string helpText)
	{
		return opIndex!(T)(longOption).help(helpText);
	}

	Option!(T) opCall (T = string) (char shortOption, string helpText)
	{
		return opIndex!(T)(shortOption.toString).help(helpText);
	}

	template opDispatch (string name)
	{
		@property Option!(T) opDispatch (T = string) ()
		{
			return opIndex!(T)(name);
		}
	}

	Option!(T) opIndex (T = string) (string name)
	{
		return Option!(T)(arguments.arguments[name]);
	}
}

struct Option (T)
{
	private Internal.Arguments.Argument argument;

	alias value this;

	@property T value ()
	{
		static if (is(T == bool))
			return argument.set;

		else
			return as!(T);
	}

	@property bool hasValue ()
	{
		return argument.assigned.any;
	}

	@property U as (U) ()
	{
		assert(hasValue);
		return to!(U)(value);
	}

	@property string rawValue ()
	{
		auto value = argument.assigned;
		return value.any ? cast(string) value.first : "";
	}

	@property bool isPresent ()
	{
		return argument.set;
	}

	bool opCast (T : bool) ()
	{
		return isPresent;
	}

	Option aliased (char name)
	{
		argument.aliased(name);
		return this;
	}

	Option help (string text)
	{
		argument.help(text);
		return this;
	}

	Option defaults (string values)
	{
		argument.defaults(values);
		return this;
	}

	Option defaults (scope string delegate () value)
	{
		argument.defaults(value);
		return this;
	}

	Option params ()
	{
		argument.params();
		return this;
	}

	Option params (int count)
	{
		argument.params(count);
		return this;
	}

	Option params (int min, int max)
	{
		argument.params(min, max);
		return this;
	}

	Option restrict (string[] options ...)
	{
		argument.restrict(options);
		return this;
	}

	Option on (scope void delegate (string value) dg)
	{
		alias Internal.Arguments.Argument.Inspector Inspector;

		argument.bind(cast(Inspector) dg);
		return this;
	}
}