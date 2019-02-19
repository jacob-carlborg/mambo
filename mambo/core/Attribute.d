/**
 * Copyright: Copyright (c) 2013 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jan 5, 2013
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.core.Attribute;

import tango.core.Tuple;
import std.typetuple : Filter;

import mambo.util.Traits;

/**
 * This s represent a meta attribute. Any declaration that has this attribute attached to
 * itself is to be considered an attribute. That declaration should only be used as an
 * attribute and never on its own.
 */
struct attribute { }

/**
 * Evaluates to true if the given symbol is an attribute. An attribute is any declaration with
 * the "mambo.core.Attribute.attribute" attribute attached.
 */
template isAttribute (alias symbol)
{
	static if (isSymbol!(symbol))
		enum isAttribute = getAttributes!(symbol, true).contains!(attribute);

	else
		enum isAttribute = false;
}

/**
 * Returns a tuple of all attributes attached to the given symbol. By default this will only
 * include actual attributes (see mambo.core.Attribute.isAttribute).
 *
 * Params:
 *     symbol = the symbol to return the attributes for
 *     includeNonAttributes = if true, will return all values. Included those not considered
 * 							   attributes
 */
template getAttributes (alias symbol, bool includeNonAttributes = false)
{
	alias Tuple!(__traits(getAttributes, symbol)) Attrs;

	static if (includeNonAttributes)
		alias Attrs FilteredAttrs;

	else
		alias Filter!(isAttribute, Attrs) FilteredAttrs;

	alias Attributes!(symbol, FilteredAttrs) getAttributes;
}

/// This struct represent a tuple of attributes attached to the symbol.
struct Attributes (alias sym, Attrs ...)
{

static:

	/// The symbol these attributes originated from
	alias sym symbol;

	/// Returns true if these attributes contain the given symbol
	bool contains (alias symbol) ()
	{
		return any ? IndexOf!(symbol, Attrs) != -1 : false;
	}

	/// Returns true if the attributes are empty.
	bool isEmpty ()
	{
		return length == 0;
	}

	/// Returns the length of the attributes.
	size_t length ()
	{
		return Attrs.length;
	}

	/// Returns true if there are any attributes.
	bool any ()
	{
		return !isEmpty;
	}
}
