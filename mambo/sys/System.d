/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 3, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.sys.System;

import core.stdc.stdlib : EXIT_SUCCESS, EXIT_FAILURE;

enum ExitCode
{
	success = EXIT_SUCCESS,
	failure = EXIT_FAILURE
}
