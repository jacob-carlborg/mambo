/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 7, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module spec.serialization.Subclass;

import dspec.Dsl;

import mambo.core.string;
import mambo.serialization.Serializer;
import mambo.serialization.archives.XmlArchive;

import spec.support.XmlMatcher;

Serializer serializer;
XmlArchive!(char) archive;

class Base
{
	int a;
}

class Sub : Base
{
	int b;
}

Sub sub;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);

	sub = new Sub;
	sub.a = 3;
	sub.b = 4;

	describe("serialize a subclass") in {
		it("should return serialized subclass") in {
			serializer.reset;
			serializer.serialize(sub);

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().containsXmlTag("object", `runtimeType="spec.serialization.Subclass.Sub" type="spec.serialization.Subclass.Sub" key="0" id="0"`));
			assert(archive.data().containsXmlTag("int", `key="b" id="1"`, "4"));
			assert(archive.data().containsXmlTag("base", `type="spec.serialization.Subclass.Base" key="1" id="2"`));
			assert(archive.data().containsXmlTag("int", `key="a" id="3"`, "3"));
		};
	};
	
	describe("deserialize class with a base class") in {
		it("should return a deserialized string equal to the original string") in {
			auto subDeserialized = serializer.deserialize!(Sub)(archive.untypedData);
	
			assert(sub.a == subDeserialized.a);
			assert(sub.b == subDeserialized.b);
		};
	};
}