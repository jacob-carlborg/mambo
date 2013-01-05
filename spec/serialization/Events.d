/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 7, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module spec.serialization.Events;

import dspec.Dsl;

import mambo.core._;
import mambo.serialization.Serializer;
import mambo.serialization.Events;
import mambo.serialization.archives.XmlArchive;
import spec.serialization.Util;

Serializer serializer;
XmlArchive!(char) archive;

int b;
int c;

class Events
{
	int a;
	int d;
	
	void serializing ()
	{
		a = 3;
	}
	
	mixin OnSerializing!(serializing);
	
	void serialized ()
	{
		b = 4;
	}
	
	mixin OnSerialized!(serialized);
	
	void deserializing ()
	{
		c = 5;
	}
	
	mixin OnDeserializing!(deserializing);
	
	void deserialized ()
	{
		d = 6;
	}
	
	mixin OnDeserialized!(deserialized);
}

Events events;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);
	
	events = new Events;
	
	describe("serialize a class with event handlers") in {
		it("should return serialized class with the correct values set by the event handlers") in {
			serializer.reset;
			serializer.serialize(events);
	
			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().containsXmlTag("object", `runtimeType="tests.Events.Events" type="tests.Events.Events" key="0" id="0"`));
			assert(archive.data().containsXmlTag("int", `key="a" id="1"`, "3"));
			assert(archive.data().containsXmlTag("int", `key="d" id="2"`, "0"));
			
			assert(b == 4);
		};
	};
	
	describe("deserialize class with a base class") in {
		it("should return a deserialized string equal to the original string") in {
			auto eventsDeserialized = serializer.deserialize!(Events)(archive.untypedData);
	
			assert(eventsDeserialized.a == 3);
			assert(eventsDeserialized.d == 6);
			
			assert(c == 5);
		};
	};
}