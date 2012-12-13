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

describe! "Array" in {
	it! "insert a value into an array at a given index" in {
		auto arr = [1, 2, 3];
		auto r = arr.insert(1, 4);

		assert(r == [1, 4, 2, 3]);
	};
};

}