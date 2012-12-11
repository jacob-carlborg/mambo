/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Dec 11, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 * 
 */
module spec.core.Array;

import dspec.Dsl;
import mambo.core.Array;
import mambo.core.io;

unittest
{
println("asd");

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
	// T[] insert (T, RangeOrElement...) (T[] arr, size_t index, RangeOrElement r)
	// {
	// 	auto copy = arr.dup;
	// 	stdArray.insertInPlace(copy, index, r);
	// 	return copy;
	// }

describe! "Array" in {
	it! "insert a value into an array at a given index" in {
		auto arr = [1, 2, 3];
		arr.insert(1, 4);

		assert(arr == [1, 4, 2, 3]);
	};
};

}