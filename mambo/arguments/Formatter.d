/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 1, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.arguments.Formatter;

import mambo.arguments.Arguments;
import mambo.arguments.Options;
import mambo.core._;
import mambo.text.Inflections;

abstract class Formatter
{
	protected
	{
		string appName_;
		string appVersion_;
	}

	@property static Formatter instance (Arguments arguments)
	{
		return new DefaultFormatter(arguments);
	}

	@property string appName ()
	{
		return appName_;
	}

	@property string appName (string value)
	{
		return appName_ = value;
	}

	@property string appVersion ()
	{
		return appVersion_;
	}

	@property string appVersion (string value)
	{
		return appVersion_ = value;
	}

	abstract @property string helpText ();
	abstract string errors (char[] delegate (char[] buffer, const(char)[] format, ...) dg);
}

class DefaultFormatter : Formatter
{
	private
	{
		Arguments arguments;
		ArgumentBase[] positionalArguments_;
		ArgumentBase[] commands_;
		Option!(int)[] options_;
		enum indentation = "    ";

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

	override string errors (char[] delegate (char[] buffer, const(char)[] format, ...) dg)
	{
		auto result = arguments.errors(dg).assumeUnique;
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

	override @property string helpText ()
	{
		string[] textSegments;

		if (positionalArguments.any)
			textSegments ~= positionalArgumentsText;

		if (commands.any)
			textSegments ~= commandsText;

		if (options.any)
			textSegments ~= optionsText;

		return format("{}\n\n{}\n{}", header, textSegments.join("\n"), footer);
	}

	@property string optionsText ()
	{
		string help = "Option:\n";
		const optionNames = generateOptionNames();
		immutable len = lengthOfLongestOption(optionNames);
		enum numberOfIndentations = 1;

		assert(options.length == optionNames.length);

		foreach (i, option ; options)
		{
			auto text = option.helpText ~ '.';
			auto name = optionNames[i];

			if (option.name.count == 0 && shortOption(option) == char.init)
				help ~= format("{}\n", text);

			else if (shortOption(option) == char.init)
				help ~= format("{}--{}{}{}{}\n",
							indentation ~ indentation,
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							text);

			else
				help ~= format("{}-{}, --{}{}{}{}\n",
							indentation,
							shortOption(option),
							name,
							" ".repeat(len - name.count),
							indentation.repeat(numberOfIndentations),
							text);
		}

		return help;
	}

	@property string commandsText ()
	{
		immutable len = lengthOfLongest(commands);
		auto str = "Commands:\n";
		enum numberOfIndentations = 1;

		foreach (arg ; commands)
		{
			immutable text = arg.helpText ~ '.';

			str ~= format("{}{}{}{}{}\n",
				indentation,
				arg.name,
				" ".repeat(len - arg.name.count),
				indentation.repeat(numberOfIndentations),
				text);
		}

		return str;
	}

	@property Option!(int)[] options ()
	{
		return options_ = options_.any ? options_ : arguments.options;
	}

	@property char shortOption (Option!(int) option)
	{
		return option.aliases.any ? option.aliases[0] : char.init;
	}

	@property size_t lengthOfLongestOption (const string[] names)
	{
		return names.reduce!((a, b) => a.count > b.count ? a : b).count;
	}

	@property ArgumentBase[] positionalArguments ()
	{
		return positionalArguments_.any ? positionalArguments_ : positionalArguments_ = arguments.positionalArguments;
	}

	@property ArgumentBase[] commands ()
	{
		return commands_.any ? commands_ : commands_ = arguments.commands;
	}

	@property string header ()
	{
		string str = "Usage: " ~ appName;

		if (commands.any)
			str ~= " <command>";

		if (options.any)
			str ~= " [options]";

		if (positionalArguments.any)
			str ~= format(" <{}>", "arg".pluralize(positionalArguments.length));

		str ~= "\nVersion " ~ appVersion;

		return str;
	}

	@property string footer ()
	{
		return "Use the `-h' flag for help.";
	}

	@property string positionalArgumentsText ()
	{
		immutable len = lengthOfLongest(positionalArguments);
		auto str = "Positional Arguments:\n";
		enum numberOfIndentations = 1;

		foreach (arg ; positionalArguments)
		{
			immutable text = arg.helpText ~ '.';

			str ~= format("{}{}{}{}{}\n",
				indentation,
				arg.name,
				" ".repeat(len - arg.name.count),
				indentation.repeat(numberOfIndentations),
				text);
		}

		return str;
	}

	@property size_t lengthOfLongest (ArgumentBase[] arguments)
	{
		return arguments.reduce!((a, b) => a.name.count > b.name.count ? a : b).name.count;
	}

    string[] generateOptionNames ()
    {
		return options.map!((option) {
			string name = option.name;

			if (option.min == 1)
				name ~= " <arg>";

			else if (option.min > 1)
				name ~= " <arg0>";

			if (option.max > 1)
				name ~= " .. <arg" ~ option.max.toString ~ '>';

			return name;
		}).toArray;
    }
}