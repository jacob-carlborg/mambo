/**
 * Copyright: Copyright (c) 2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Nov 7, 2012
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module spec.serialization.NonMutable;

import dspec.Dsl;

import mambo.core._;
import mambo.serialization.Serializer;
import mambo.serialization.archives.XmlArchive;

import spec.support.XmlMatcher;

Serializer serializer;
XmlArchive!(char) archive;

class B
{
	int a;

	this (int a)
	{
		this.a = a;
	}

	override equals_t opEquals (Object other)
	{
		if (auto o = cast(B) other)
			return a == o.a;

		return false;
	}
}

class A
{
	const int a;
	immutable int b;
	immutable string c;
	immutable B d;
	immutable(int)* e;

	this (int a, int b, string c, immutable B d, immutable(int)* e)
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.e = e;
	}

	override equals_t opEquals (Object other)
	{
		if (auto o = cast(A) other)
			return a == o.a &&
				b == o.b &&
				c == o.c &&
				d == o.d &&
				*e == *o.e;

		return false;
	}
}

A a;
immutable int ptr = 3;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	a = new A(1, 2, "str", new immutable(B)(3), &ptr);

	describe("serialize object with immutable and const fields") in {
		it("should return a serialized object") in {
			serializer.reset;
			serializer.serialize(a);

			version (D_Version2) string stringElementType = "immutable(char)";
			else string stringElementType = "char";

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().contains(`<object runtimeType="spec.serialization.NonMutable.A" type="spec.serialization.NonMutable.A" key="0" id="0">`));

			assert(archive.data().containsXmlTag("int", `key="a" id="1"`, "1"));
			assert(archive.data().containsXmlTag("int", `key="b" id="2"`, "2"));
			assert(archive.data().containsXmlTag("string", `type="` ~ stringElementType ~ `" length="3" key="c" id="3"`, "str"));

			assert(archive.data().contains(`<object runtimeType="spec.serialization.NonMutable.B" type="immutable(spec.serialization.NonMutable.B)" key="d" id="4">`));

			assert(archive.data().containsXmlTag("pointer", `key="e" id="6"`));
			assert(archive.data().containsXmlTag("int", `key="1" id="7"`, "3"));
		};
	};
	
	describe("deserialize object") in {
		it("should return a deserialized object equal to the original object") in {
			auto aDeserialized = serializer.deserialize!(A)(archive.untypedData);
			assert(a == aDeserialized);
		};
	};
}