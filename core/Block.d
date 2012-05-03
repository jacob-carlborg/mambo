/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Feb 12, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.core.Block;

struct Block (Args ...)
{
	void delegate (void delegate (Args)) dg;
	
	void opIn (void delegate (Args) dg)
	{
		this.dg(dg);
	}
}