/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 26, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.text.ConfigMap;

import mambo.core._;

template ConfigMapMixin ()
{
	private Value[string] map;

	@property ref Value opDispatch (string name) ()
	{
		if (auto v = name in map)
			return *v;

		else
		{
			map[name] = Value();
			return map[name];
		}
	}

	@property ref Value opDispatch (string name) (string value)
	{
		map[name] = Value(value);
		return map[name];
	}
}

struct ConfigMap
{
	mixin ConfigMapMixin;
	alias map this;
}

struct Value
{
	string value;
	alias value this;

	private Value[string] map;

	@property auto opDispatch (string name) ()
	{
		static if (__traits(compiles, mixin("{ value." ~ name ~ "();}")))
			mixin("return value." ~ name ~ "();");

		else
		{
			if (auto v = name in map)
				return *v;

			else
			{
				map[name] = Value();
				return map[name];
			}
		}
	}

	@property auto opDispatch (string name) (string value)
	{
		static if (__traits(compiles, mixin("{ this.value." ~ name ~ "(value);}")))
			mixin("return this.value." ~ name ~ "(value);");

		else
		{
			map[name] = Value(value);
			return map[name];
		}
	}

	string toString () const
	{
		return isSet ? value : map.toString;
	}

	@property bool isSet () const
	{
		return value.any;
	}
}
