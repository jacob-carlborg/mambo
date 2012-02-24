/**
 * Copyright: Copyright (c) 2008-2009 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module mambo.string;

public import mambo.core.Array;
import mambo.util.Version;
import mambo.util.Traits;

static import tango.stdc.stringz;
import tango.text.Unicode : toFold, isDigit;
import tango.text.convert.Utf;
import tango.text.Util;

alias tango.stdc.stringz.toStringz toStringz;
alias tango.stdc.stringz.toString16z toString16z;
alias tango.stdc.stringz.toString32z toString32z;

alias tango.stdc.stringz.fromStringz fromStringz;
alias tango.stdc.stringz.fromString16z fromString16z;
alias tango.stdc.stringz.fromString32z fromString32z;

alias tango.text.convert.Utf.toString16 toString16;
alias tango.text.convert.Utf.toString32 toString32;

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

/**
 * Checks if the given character is a hexdecimal digit character.
 * Hexadecimal digits are any of: 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F
 * 
 * Params:
 *     ch = the character to be checked
 *     
 * Returns: true if the given character is a hexdecimal digit character otherwise false
 */
bool isHexDigit (dchar ch)
{
	switch (ch)
	{
		case 'A': return true;				
		case 'B': return true;
		case 'C': return true;
		case 'D': return true;
		case 'E': return true;
		case 'F': return true;
		
		case 'a': return true;
		case 'b': return true;
		case 'c': return true;
		case 'd': return true;
		case 'e': return true;
		case 'f': return true;
		
		default: break;
	}
	
	if (isDigit(ch))
		return true;
		
	return false;
}

T[] replace (T) (T[] source, dchar match, dchar replacement)
{
	static assert(isChar!(T), `The type "` ~ T.stringof ~ `" is not a valid type for this function only strings are accepted`);
	
	dchar endOfCodeRange;
	
	static if (is(T == wchar))
	{
		const encodedLength = 2;
		endOfCodeRange = 0x00FFFF;
	}
	
	else static if (is(T == char))
	{
		const encodedLength = 4;
		endOfCodeRange = '\x7F';
	}
	
	if (replacement <= endOfCodeRange && match <= endOfCodeRange)
	{
		foreach (ref c ; source)
			if (c == match)
				c = replacement;
		
		return source;
	}
	
	else
	{
		static if (!is(T == dchar))
		{
			T[encodedLength] encodedMatch;
			T[encodedLength] encodedReplacement;

			return source.substitute(encode(encodedMatch, match), encode(encodedReplacement, replacement));
		}
	}
	
	return source;
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