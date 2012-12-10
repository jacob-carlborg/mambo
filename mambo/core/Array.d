/**
 * Copyright: Copyright (c) 2008-2009 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module mambo.core.Array;

import stdString = std.string;
import stdArray = std.array;
import algorithm = std.algorithm;
import stdRange = std.range;

static import tango.core.Array;
import tango.stdc.string : memmove;
static import tango.text.Util;

import mambo.core.AssociativeArray;
import mambo.core.core;
import mambo.util.Traits;

alias algorithm.array toArray;
alias algorithm.canFind contains;
alias algorithm.count count;
alias algorithm.countUntil indexOf;
alias algorithm.filter filter;
alias algorithm.join join;
alias algorithm.sort sort;
alias algorithm.startsWith startsWith;
alias algorithm.uniq unique;

alias stdRange.chain append;

/**
 * Inserts the given element(s) or range at the given position into the array. Shifts the
 * element currently at that position (if any) and any subsequent elements to the right.
 * 
 * Params:
 *     arr = the array to insert the element(s) or range into
 *     index = the index at which the specified element(s) or range is to be inserted to
 *     r = the element(s) or range to be inserted 
 *     
 * Returns: a copy of the given array with the element(s) or range inserted
 */
T[] insert (T, RangeOrElement...) (T[] arr, size_t index, RangeOrElement r)
{
	auto copy = arr.dup;
	stdArray.insertInPlace(copy, index, r);
	return copy;
}

/**
* Inserts the given element(s) or range, in place, at the given position into the array.
* Shifts the element currently at that position (if any) and any subsequent elements to the
* right.
* 
* This will modify the given array in place.
* 
* Params:
*     arr = the array to insert the element(s) or range into
*     index = the index at which the specified element(s) or range is to be inserted to
*     r = the element(s) or range to be inserted
 *     
 * Returns: the modified array with the element(s) or range inserted
 */
T[] insertInPlace (T, RangeOrElement...) (ref T[] arr, size_t index, RangeOrElement r)
{
	stdArray.insertInPlace(arr, index, r);
	return arr;
}

/**
 * Removes the given elements from the given array.
 * 
 * Params:
 *     arr = the array to remove the elements from
 *     elements = the elements to be removed
 *     
 * Returns: the array with the elements removed
 */
T[] remove (T) (T[] arr, T[] elements ...)
{
    return algorithm.remove!((e) => elements.contains(e))(arr);
}

/**
 * Removes the elements with the given indexes from the given range.
 * 
 * Params:
 *     range = the range to remove the elements from
 *     indexes = the index of the elements to be remove
 *     
 * Returns: the range with the indexes removed
 */
Range remove (Range, Index ...) (Range range, Index indexes)
{
	return algorithm.remove(range, indexes);
}

/**
 * Returns $(D_KEYWORD true) if this array contains no elements.
 * 
 * Params:
 *     arr = the array to check if it's empty
 *
 * Returns: $(D_KEYWORD true) if this array contains no elements
 */
@property bool isEmpty (T) (T arr)
    if (__traits(compiles, { auto a = arr.length; }) ||
        __traits(compiles, { bool b = arr.empty; }))
{
    static if (__traits(compiles, { auto a = arr.length; }))
        return arr.length == 0;

    else
        return arr.empty;
}

/**
 * Removes all of the elements from this array. The array will be empty after this call
 * returns.
 * 
 * Params:
 *     arr = the array to clear
 * 
 * Returns: the cleared array
 *
 * Throws: AssertException if length of the return array isn't 0
 */
T[] clear (T) (ref T[] arr)
out (result)
{
	assert(result.length == 0, "mambo.collection.Array.clear: The length of the resulting array was not 0");
}
body
{
	arr.length = 0;
	return arr;
}

/**
 * Returns the index of the last occurrence of the specifed element
 * 
 * Params:
 *     arr = the array to get the index of the element from
 *     element = the element to find the index of
 *     
 * Returns: the index of the last occurrence of the element in the
 *          specified array, or U.max 
 *          if the element does not occur.
 *          
 * Throws: AssertException if the length of the array is 0 
 * Throws: AssertException if the return value is less than -1 or
 * 		   greater than the length of the array - 1.
 */
U lastIndexOf (T, U = size_t) (in T[] arr, T element)
in
{
	assert(arr.length > 0, "mambo.collection.Array.lastIndexOf: The length of the array was 0");
}
body
{
	U index = tango.text.Util.locatePrior(arr, element);

	if (index == arr.length)
		return U.max;

	return index;
}

/**
 * Returns true if a begins with b
 * 
 * Params:
 *     a = the array to
 *     b = 
 *     
 * Returns: true if a begins with b, otherwise false
 */
bool beginsWith (T) (T[] a, T[] b)
{
	return a.length > b.length && a[0 .. b.length] == b;
}

/**
 * Returns true if a ends with b
 * 
 * Params:
 *     a = the array to
 *     b = 
 *     
 * Returns: true if a ends with b, otherwise false
 */
bool endsWith (T) (T[] a, T[] b)
{
	return a.length > b.length && a[$ - b.length .. $] == b;
}

/**
 * Repests $(D_PARAM arr) $(D_PARAM number) of times.
 * 
 * Params:
 *     arr = the array to repeat
 *     number = the number of times to repeat
 *     
 * Returns: a new array containing $(D_PARAM arr) $(D_PARAM number) of times
 */
T[] repeat (T) (T[] arr, int number)
{
	T[] result;

	foreach (_ ; 0 .. number + 1)
		result ~= arr;
	
	return result;
}

/**
 * Returns $(D_KEYWORD true) if this array contains any elements.
 * 
 * Params:
 *     arr = the array to check if it contains elements
 *
 * Returns: $(D_KEYWORD true) if this array contains elements
 */
@property bool any (T) (T arr) if (__traits(compiles, { bool a = arr.isEmpty; }))
{
	return !arr.isEmpty;
}

bool any (alias predicate, Range) (Range range)
{
	static if (isAssociativeArray!(Range))
		return _anyAA!(predicate)(range);

	else
		return algorithm.any!(predicate)(range);
}

/// Returns the first element of the given array.
@property auto first (T) (T[] arr)
{
	return stdArray.front(arr);
}

/// Returns the first element of the given array.
@property auto last (T) (T[] arr)
{
	return stdArray.back(arr);
}

/// Strips all the trailing delimiters from the given array.
T[] strip (T, C) (T[] arr, C delimiter)
{
	if (arr.isEmpty)
		return arr;
	
	auto a = arr;
	auto del = [delimiter];
	
	while (a.last == delimiter)
		a = stdString.chomp(a, del);
	
	return a;
}

auto find (alias predicate, Range) (Range range)
{
	static if (isAssociativeArray!(Range))
		return _findAA!(predicate)(range);

	else
		return algorithm.find!(predicate)(range);
}

auto reduce (alias func, Range) (Range range)
{
	return algorithm.reduce!(func)(range);
}

auto reduce (alias func, Range, Seed) (Range range, Seed seed)
{
	return algorithm.reduce!(func)(seed, range);
}

auto map (alias func, Range) (Range range)
{
	static if (isAssociativeArray!(Range))
		return _mapAA!(func)(range);

	else
		return algorithm.map!(func)(range);
}