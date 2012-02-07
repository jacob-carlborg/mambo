/**
 * Copyright: Copyright (c) 2007-2008 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2007
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module mambo.core.io;

import std.stdio;

/**
 * Print to the standard output
 * 
 * Params:
 *     args = what to print
 */
void print (A...)(A args)
{
	write(args);
}

/**
 * Print to the standard output, adds a new line
 * 
 * Params:
 *     args = what to print
 */
void println (A...)(A args)
{
	writeln(args);
}