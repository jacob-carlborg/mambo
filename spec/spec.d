/**
 * Copyright: Copyright (c) 2010-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 5, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module spec.spec;

import tango.core.Runtime;

import dspec.ExampleGroup;

shared static this ()
{
	Runtime.moduleUnitTester = &unitTestRunner;
}

/*
 * The tests that test for XML with attributes are not completely
 * reliable, due to the XML module in Phobos saves the XML
 * attributes in an associative array.
 */
bool unitTestRunner ()
{
	foreach (m ; ModuleInfo)
	{
		if (m)
		{
			if (auto fp = m.unitTest)
				fp();
		}
	}

	return ExampleGroup.instance.run();
}

void main ()
{
	// Dummy
}