/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Mar 3, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.core.core;

import std.regex;

import mambo.core.Array;
import mambo.core.AssociativeArray;
import mambo.util.Traits;

/**
 * Returns true if the given value is blank. A string is considered blank if any of
 * the following conditions are true:
 * 
 * $(UL
 * 	$(LI The string is null)
 * 	$(LI The length of the string is equal to 0)
 * 	$(LI The string only contains blank characters, i.e. space, newline or tab)
 * )
 * 
 * Params:
 *     str = the string to test if it's blank
 *     
 * Returns: $(D_KEYWORD true) if any of the above conditions are met
 * 
 * See_Also: isPresent 
 */
@property bool isBlank (T) (T t)
{
	static if (isString!(T))
	{
		if (t.length == 0)
			return true;
		
		return match(t, regex(`\S`, "g")).empty;
	}
	
	static if (__traits(compiles, t.isEmpty))
		return t.isEmpty;
		
	else static if (isPrimitive!(T) || isStruct!(T) || isUnion!(T))
		return false;

	return T.init == t;
}

@property bool isPresent (T) (T t)
{
	return !isBlank(t);
}