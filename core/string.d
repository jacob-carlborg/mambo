/**
 * Copyright: Copyright (c) 2008-2009 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module mambo.core.string;

import std.array;
import std.conv;
static import std.ascii;
import std.string;
import std.utf;

public import mambo.core.Array;
import mambo.util.Version;
import mambo.util.Traits;

private alias std.string.toLower toFold;

alias std.utf.toUTF8 toString;
alias std.utf.toUTF16 toString16;
alias std.utf.toUTF32 toString32;

alias std.string.toStringz toStringz;
alias std.utf.toUTF16z toString16z;

alias to!(string) fromStringz;
alias std.array.replace replace;

alias std.string.join join;

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

	return toFold(toUTF8(str)) == toFold(toUTF8(anotherString));
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

	return toFold(toUTF8(str)) == toFold(toUTF8(anotherString));
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

/**
 * Converts the given string to C-style 0 terminated string.
 * 
 * Params:
 *     str = the string to convert
 *     
 * Returns: the a C-style 0 terminated string.
 */
immutable(dchar)* toString32z (dstring str)
{
	return (str ~ '\0').ptr;
}

/**
 * Converts a C-style 0 terminated string to a wstring
 * 
 * Params:
 *     str = the C-style 0 terminated string
 *     
 * Returns: the converted wstring
 */
wstring fromString16z (wchar* str)
{
	return str[0 .. strlen(str)].idup;
}

/**
 * Converts a C-style 0 terminated string to a dstring
 * Params:
 *     str = the C-style 0 terminated string
 *     
 * Returns: the converted dstring
 */
dstring fromString32z (dchar* str)
{
	return str[0 .. strlen(str)].idup;
}

/**
 * Gets the length of the given C-style 0 terminated string
 * 
 * Params:
 *     str = the C-style 0 terminated string to get the length of
 *     
 * Returns: the length of the string
 */
size_t strlen (wchar* str)
{
	size_t i = 0;
	
	if (str)
		while(*str++)
			++i;
	
	return i;
}

/**
 * Gets the length of the given C-style 0 terminated string
 * 
 * Params:
 *     str = the C-style 0 terminated string to get the length of
 *     
 * Returns: the length of the string
 */
size_t strlen (dchar* str)
{
	size_t i = 0;
	
	if (str)
		while(*str++)
			++i;
	
	return i;
}

/**
 * Returns true if the given string is blank. A string is considered blank if any of
 * the following conditions are true:
 * 
 * $(UL
 * 	$(LI The string is null)
 * 	$(LI The length of the string is equal to 0)
 * 	$(LI The string is equal to the empty string, "")
 * )
 * 
 * Params:
 *     str = the string to test if it's blank
 *     
 * Returns: $(D_KEYWORD true) if any of the above conditions are met
 * 
 * See_Also: isPresent 
 */
@property bool isBlank (T) (T[] str)
{
	return str is null || str.length == 0 || str == "";
}

/**
 * Returns true if the given string is present. A string is conditions present if all
 * of the following conditions are true:
 * 
 * $(UL
 * 	$(LI The string is not null)
 * 	$(LI The length of the string is greater than 0)
 * 	$(LI The string is not equal to the empty string, "")
 * )
 * 
 * The above conditions are basically the opposite of isBlank.
 * 
 * Params:
 *     str = the string to test if it's present
 *     
 * Returns: $(D_KEYWORD true) if all of the above conditions are met
 * 
 * See_Also: isBlank
 */
@property bool isPresent (T) (T[] str)
{
	return !str.isBlank();
}