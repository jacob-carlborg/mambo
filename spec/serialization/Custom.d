/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 17, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module spec.serialization.Custom;

import dspec.Dsl;

import mambo.core._;
import mambo.serialization.Serializer;
import mambo.serialization.archives.XmlArchive;
import spec.serialization.Util;

Serializer serializer;
XmlArchive!(char) archive;

class Foo
{
	int a;
	int b;
	
	void toData (Serializer serializer, Serializer.Data key)
	{
		i++;
		serializer.serialize(a, "x");
	}

	void fromData (Serializer serializer, Serializer.Data key)
	{
		i++;
		a = serializer.deserialize!(int)("x");
	}
}

class WithString
{
	string b;

	void toData (Serializer serializer, Serializer.Data key)
	{
		j++;
		serializer.serialize(b, "y");
	}

	void fromData (Serializer serializer, Serializer.Data key)
	{
		j++;
		b = serializer.deserialize!(string)("y");
	}
}

Foo foo;
int i;

WithString withString;
int j;

unittest
{
	archive = new XmlArchive!(char);
	serializer = new Serializer(archive);
	
	foo = new Foo;
	foo.a = 3;
	foo.b = 4;
	i = 3;

	withString = new WithString;
	withString.b = "a string";
	j = 3;

	describe! "serialize object using custom serialization methods" in {
		it! "should return a custom serialized object" in {
			serializer.serialize(foo);

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().containsXmlTag("object", `runtimeType="spec.serialization.Custom.Foo" type="spec.serialization.Custom.Foo" key="0" id="0"`));
			assert(archive.data().containsXmlTag("int", `key="x" id="1"`));
			
			assert(i == 4);
		};
	};
	
	describe! "deserialize object using custom serialization methods" in {
		it! "short return a custom deserialized object equal to the original object" in {
			auto f = serializer.deserialize!(Foo)(archive.untypedData);

			assert(foo.a == f.a);
			
			assert(i == 5);
		};
	};

	describe! "serialize object with string using custom serialization" in {
		it! "serailzes the object" in {
			serializer.reset();

			serializer.serialize(withString);

			assert(archive.data().containsDefaultXmlContent());
			assert(archive.data().containsXmlTag("object", `runtimeType="spec.serialization.Custom.WithString" type="spec.serialization.Custom.WithString" key="0" id="0"`));
			assert(archive.data().containsXmlTag("string", `type="immutable(char)" length="8" key="y" id="1"`, "a string"));

			assert(j == 4);
		};
	};

	describe! "deserialize object with string using custom serialization" in {
		it! "returns an object equal to the original object" in {
			auto a = serializer.deserialize!(WithString)(archive.untypedData);

			assert(withString.b == a.b);
			assert(j == 5);
		};
	};
}
