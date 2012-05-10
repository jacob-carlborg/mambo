/**
 * Copyright: Copyright (c) 2008-2009 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module mambo.core.string;

import std.array;
static import std.ascii;

static import tango.stdc.stringz;
import tango.text.Unicode : toFold, isDigit;
import tango.text.convert.Utf;
import tango.text.Util;

public import mambo.core.Array;
import mambo.util.Version;
import mambo.util.Traits;

alias tango.stdc.stringz.toStringz toStringz;
alias tango.stdc.stringz.toString16z toString16z;
alias tango.stdc.stringz.toString32z toString32z;

alias tango.stdc.stringz.fromStringz fromStringz;
alias tango.stdc.stringz.fromString16z fromString16z;
alias tango.stdc.stringz.fromString32z fromString32z;

alias tango.text.convert.Utf.toString16 toString16;
alias tango.text.convert.Utf.toString32 toString32;

alias std.array.replace replace;
alias std.ascii.isHexDigit isHexDigit;

/**
 * Compares the $(D_PSYMBOL string) to another $(D_PSYMBOL string), ignoring case
 * considerations.  Two strings are considered equal ignoring case if they are of the
 * same length and corresponding characters in the two strings  are equal ignoring case.
 * 
 * Params:
 *     str = The $(D_PSYMBOL string) first string to compare to
 *     anotherString = The $(D_PSYMBOL string) to compare the first $(D_PSYMBOL string) with
 *     
 * Returns: $(D_KEYWORD true) if the arguments is not $(D_KEYWORD null) and it
 *          represents an equivalent $(D_PSYMBOL string) ignoring case; $(D_KEYWORD false) otherwise
 *          
 * Throws: AssertException if the length of any of the strings is 0
 *          
 * See_Also: opEquals(Object)
 */
bool equalsIgnoreCase (string str, string anotherString)
in
{
	assert(str.length > 0, "mambo.string.equalsIgnoreCase: The length of the first string was 0");
	assert(anotherString.length > 0, "mambo.string.equalsIgnoreCase: The length of the second string was 0");
}
body
{	
	if (str == anotherString)
		return true;

	return toFold(str) == toFold(anotherString);
}

/**
 * Compares the $(D_PSYMBOL wstring) to another $(D_PSYMBOL wstring), ignoring case
 * considerations. Two wstrings are considered equal ignoring case if they are of the
 * same length and corresponding characters in the two wstrings are equal ignoring case.
 * 
 * Params:
 *     str = The $(D_PSYMBOL wstring) first string to compre to
 *     anotherString = The $(D_PSYMBOL wstring) to compare the first $(D_PSYMBOL wstring) against
 *     
 * Returns: $(D_KEYWORD true) if the argument is not $(D_KEYWORD null) and it
 *          represents an equivalent $(D_PSYMBOL wstring) ignoring case; (D_KEYWORD
 *          false) otherwise
 *          
 * Throws: AssertException if the length of any of the wstrings is 0
 *          
 * See_Also: opEquals(Object)
 */
bool equalsIgnoreCase (wstring str, wstring anotherString)
in
{
	assert(str.length > 0, "mambo.string.equalsIgnoreCase: The length of the first string was 0");
	assert(anotherString.length > 0, "mambo.string.equalsIgnoreCase: The length of the second string was 0");
}
body
{
	if (str == anotherString)
		return true;

	return toFold(str) == toFold(anotherString);
}

/**
 * Compares the $(D_PSYMBOL dstring) to another $(D_PSYMBOL dstring), ignoring case
 * considerations. Two wstrings are considered equal ignoring case if they are of the
 * same length and corresponding characters in the two wstrings are equal ignoring case.
 * 
 * Params:
 *     str = The $(D_PSYMBOL dstring) first string to compare to
 *     anotherString = The $(D_PSYMBOL wstring) to compare the first $(D_PSYMBOL dstring) against
 *     
 * Returns: $(D_KEYWORD true) if the argument is not $(D_KEYWORD null) and it
 *          represents an equivalent $(D_PSYMBOL dstring) ignoring case; $(D_KEYWORD false) otherwise
 *          
 * Throws: AssertException if the length of any of the dstrings are 0
 *          
 * See_Also: opEquals(Object)
 */
bool equalsIgnoreCase (dstring str, dstring anotherString)
in
{
	assert(str.length > 0, "mambo.string.equalsIgnoreCase: The length of the first string was 0");
	assert(anotherString.length > 0, "mambo.string.equalsIgnoreCase: The length of the second string was 0");
}
body
{
	if (str == anotherString)
		return true;

	return toFold(str) == toFold(anotherString);
}

/**
 * Finds the first occurence of sub in str
 * 
 * Params:
 *     str = the string to find in
 *     sub = the substring to find
 *     start = where to start finding
 *     
 * Returns: the index of the substring or size_t.max when nothing was found
 */
size_t find (string str, string sub, size_t start = 0)
{
	size_t index = str.locatePattern(sub, start);
	
	if (index == str.length)
		return size_t.max;
	
	return index;
}

/**
 * Finds the first occurence of sub in str
 * 
 * Params:
 *     str = the string to find in
 *     sub = the substring to find
 *     start = where to start finding
 *     
 * Returns: the index of the substring or size_t.max when nothing was found
 */
size_t find (wstring str, wstring sub, size_t start = 0)
{
	size_t index = str.locatePattern(sub, start);
	
	if (index == str.length)
		return size_t.max;
	
	return index;
}

/**
 * Finds the first occurence of sub in str
 * 
 * Params:
 *     str = the string to find in
 *     sub = the substring to find
 *     start = where to start finding
 *     
 * Returns: the index of the substring or size_t.max when nothing was found
 */
size_t find (dstring str, dstring sub, size_t start = 0)
{
	size_t index = str.locatePattern(sub, start);
	
	if (index == str.length)
		return size_t.max;
	
	return index;
}

/**
 * Compares to strings, ignoring case differences. Returns 0 if the content
 * matches, less than zero if a is "less" than b, or greater than zero
 * where a is "bigger".
 * 
 * Params:
 *     a = the first array 
 *     b = the second array
 *     end = the index where the comparision will end
 *     
 * Returns: Returns 0 if the content matches, less than zero if a is 
 * 			"less" than b, or greater than zero where a is "bigger".
 * 
 * See_Also: mambo.collection.array.compare
 */
int compareIgnoreCase (U = size_t) (string a, string b, U end = U.max)
{
	return a.toFold().compare(b.toFold(), end);
}

/**
 * Compares to strings, ignoring case differences. Returns 0 if the content
 * matches, less than zero if a is "less" than b, or greater than zero
 * where a is "bigger".
 * 
 * Params:
 *     a = the first array 
 *     b = the second array
 *     end = the index where the comparision will end
 *     
 * Returns: Returns 0 if the content matches, less than zero if a is 
 * 			"less" than b, or greater than zero where a is "bigger".
 * 
 * See_Also: mambo.collection.array.compare
 */
int compareIgnoreCase (U = size_t) (wstring a, wstring b, U end = U.max)
{
	return a.toFold().compare(b.toFold(), end);
}

/**
 * Compares to strings, ignoring case differences. Returns 0 if the content
 * matches, less than zero if a is "less" than b, or greater than zero
 * where a is "bigger".
 * 
 * Params:
 *     a = the first array 
 *     b = the second array
 *     end = the index where the comparision will end
 *     
 * Returns: Returns 0 if the content matches, less than zero if a is 
 * 			"less" than b, or greater than zero where a is "bigger".
 * 
 * See_Also: mambo.collection.array.compare
 */
int compareIgnoreCase (U = size_t) (dstring a, dstring b, U end = U.max)
{
	return a.toFold().compare(b.toFold(), end);
}

/// Converts the given value to a string.
string toString (T) (T value)
{
	import std.conv;
	return to!(string)(value);
}