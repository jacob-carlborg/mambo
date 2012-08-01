/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 1, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.arguments.Formatter;

import std.exception;

import mambo.arguments.Arguments;
import mambo.arguments.Options;
import mambo.core._;

interface Formatter
{
	@property static Formatter instance (Arguments arguments)
	{
		return new DefaultFormatter(arguments);
	}

	@property string helpText ();
	string errors (char[] delegate (char[] buffer, const(char)[] format, ...) dg);
}

class DefaultFormatter : Formatter
{
	private
	{
		Arguments arguments;
		Option!(int)[] options_;
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

	this (Arguments arguments)
	{
		this.arguments = arguments;
	}

	string errors (char[] delegate (char[] buffer, const(char)[] format, ...) dg)
	{
		auto res = arguments.errors(dg);
		string result = res.assumeUnique;
		char[256] buffer;
		auto msg = errorMessages;
		auto posArgs = arguments.positionalArguments;
		posArgs.sort!((a, b) => a.position < b.position)();

		foreach (arg ; posArgs)
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

	@property string helpText ()
	{
		string help;
		auto len = lengthOfLongestOption;
		auto indentation = "    ";
		auto numberOfIndentations = 1;

		foreach (option ; options)
		{
			auto text = option.helpText ~ '.';
			auto name = option.name;

			if (option.min == 1)
				name ~= " <arg>";

			else if (option.min > 1)
				name ~= " <arg0>";

			if (option.max > 1)
				name ~= " .. <arg" ~ option.max.toString ~ '>';

			if (option.name.count == 0 && shortOption(option) == char.init)
				help ~= format("{}\n", option.helpText);

			else if (shortOption(option) == char.init)
				help ~= format("{}--{}{}{}{}\n",
							indentation ~ indentation,
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							option.helpText);

			else
				help ~= format("{}-{}, --{}{}{}{}\n",
							indentation,
							shortOption(option),
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							option.helpText);
		}

		return help;
	}

private:

	@property Option!(int)[] options ()
	{
		return options_.any ? options_ : options_ = arguments.options;
	}

	@property char shortOption (Option!(int) option)
	{
		return option.aliases.any ? option.aliases[0] : char.init;
	}

	@property size_t lengthOfLongestOption ()
	{
		return options.reduce!((a, b) => a.name.count > b.name.count ? a : b).name.count;
	}
}