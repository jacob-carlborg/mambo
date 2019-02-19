/**
 * Copyright: Copyright (c) 2010-2011 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 30, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.serialization.SerializationException;

import mambo.core.string;

alias Throwable ExceptionBase;

/**
 * This class represents an exception, it's the base class of all exceptions used
 * throughout this library.
 */
class SerializationException : ExceptionBase
{
	/**
	 * Creates a new exception with the given message.
	 *
	 * Params:
	 *     message = the message of the exception
	 */
	this (string message)
	{
		super(message);
	}

	/**
	 * Creates a new exception with the given message, file and line info.
	 *
	 * Params:
	 *     message = the message of the exception
	 *     file = the file where the exception occurred
	 *     line = the line in the file where the exception occurred
	 */
	this (string message, string file, size_t line)
	{
		super(message, file, line);
	}

	/**
	 * Creates a new exception out of the given exception. Used for wrapping already existing
	 * exceptions as SerializationExceptions.
	 *
	 *
	 * Params:
	 *     exception = the exception exception to wrap
	 */
	this (ExceptionBase exception)
	{
		super(exception.msg, exception.file, exception.line, exception.next);
	}
}
