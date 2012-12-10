/**
 * Copyright: Copyright (c) 2009 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: May 18, 2009
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.xml.SimpleXML;


import tango.io.device.File;
import tango.text.xml.Document;
import tango.text.xml.DocPrinter;
import tango.text.xml.PullParser;
import Convert = tango.util.Convert;

/**
 * XML documents. The tradeoff with such a scheme is that copying
 * 
 * 
 * Implements an easy to use interface on top of a DOM Document.
 * 
 * Parse example:
 * ---
 * auto doc = new SimpleXML!(char)(content);
 * Stdout(doc).newline;
 * ---
 * 
 * API example:
 * ---
 * auto doc = new SimpleXML!(char);
 * 	
 * // attach an xml header
 * doc.header;
 *
 * // attach an element with some attributes, plus 
 * // a child element with an attached data value
 * doc ~ "element" 
 * 	~ doc.Attribute("attrib1", "value")
 * 	~ doc.Attribute("attrib2")
 * 	~ doc.Element("child", "value");
 *
 * // attach a single child element to the root element
 * // and a single attribute to the root element
 * doc ~= "element2";
 * doc.attribute ~= "attri3";
 * ---
 * 
 * X-Path example:
 * ---
 * auto doc = new SimpleXML!(char);
 * 
 * // attach an xml header
 * doc.header;
 * 
 * // attach an element with some attributes, plus 
 * // a child element with an attached data value
 * doc ~ "element" 
 * 	~ doc.Attribute("attrib1", "value")
 * 	~ doc.Attribute("attrib2")
 * 	~ doc.Element("child", "value");
 * 
 * // select named-element
 * auto set = doc["child"];
 * 
 * // select the first attribute named "
 * // attrib2" in the root element
 * auto att = doc.attribute("attrib2");
 * 
 * // get the value of the first attribute 
 * // named attrib1 in the root element
 * char[] value = doc.attribute["attrib1"];
 * ---
 */
class SimpleXML (T) : Document!(T)
{	
	private DocPrinter!(T) printer;
	
	/**
	 * XML documents. The tradeoff with such a scheme is that copying
	 * 
	 * Constructs a SimpleXML instance.
	 * 
	 * Params:
	 *     nodes = the initial number of nodes assigned to the freelist
	 */
	this (uint nodes = 1000)
	{
		super(nodes);
		printer = new DocPrinter!(char);
		
		if (elements)
			attribute.node = elements;
		
		else
			attribute.node = tree;
	}
	
	/**
	 * Constructs a SimpleXML instance and parses the given content.
	 * 
	 * Params:
	 *     xml = the content to parse
	 */
	this (T[] xml)
	{
		this();
		parse(xml);
	}
	
	/**
	 * Prepend an XML header to the document tree.
	 * 
	 * Params:
	 *     encoding = the encoding of the XML header
	 *     
	 * Returns: this
	 */
	final SimpleXML header (T[] encoding = null)
	{
		super.header = encoding;
		return this;
	}
	
	/**
	 * Returns the first child element of the root element, which
	 * matches the given name.
	 * 
	 * Params:
	 *     name = the name of the child element
	 *     
	 * Returns: the child element or null
	 */
	final Node opIndex (T[] name)
	{
		if (!elements)
			return Node.init;
		
		auto set = elements.query[name];
		
		if (set.count > 0)
			return Node(set.nodes[0]);
		
		return Node.init;
	}
	
	/**
	 * Finds the first child element of the root element with the given 
	 * name and sets it's value to the given value. If the element
	 * could not be found it's created and the give value is set. 
	 * 
	 * Params:
	 *     value = the value to set
	 *     name = the name of the element
	 */
	final void opIndexAssign (T2) (T2 value, T[] name)
	{
		auto node = this[name];
		T[] v;
		
		static if (is(T2 : T[]))
			v = value;
		
		else static if (is(T2 == bool))
			T[] v = value ? "1" : "0";
		
		else static if (is(T2 : long))
			T[] v = Convert.to!(T[])(value);
		
		if (node.node)
			node.value = value;
		
		else
		{
			if (elements)
				elements.element(null, name, value);
			
			else
				tree.element(null, name, value);
		}
	}
	
	/**
	 * Iterates over the children of the root node
	 * 
	 * Params:
	 *     dg = the node and the value of the node will be passed to this for every iteration
	 *     
	 * Returns:
	 */
	final int opApply (int delegate(ref Node) dg)
    {
		if (!elements)
			return 0;
			
    	int result;
            
    	foreach (n ; elements.children)
    		if (n.type == XmlNodeType.Element && (result = dg(Node(n))) != 0)
    			break;

    	return result;
    }
	
	/**
	 * Adds a new element to the root element of the document.
	 * 
	 * Params:
	 *     name = the name of the element
	 *     value = the value of the element
	 *     
	 * Returns:a reference to the element
	 */
	final Node add (T[] name, T[] value = null)
	{
		if (elements)
			return Node(elements.element(null, name, value));
		
		Node node = Node(tree.element(null, name, value));
		attribute.node = node.node;
		
		return node;
	}
	
	/**
	 * Adds a new element to the root element of the document.
	 * 
	 * Params:
	 *     name = the name of the element
	 *     value = the value of the element
	 *     
	 * Returns:a reference to the element
	 */
	final Node add (Element element)
	{
		if (elements)
			return Node(elements.element(null, element.name, element.value));
		
		Node node = Node(tree.element(null, element.name, element.value));
		attribute.node = node.node;
		
		return node;
	}
	
	/**
	 * Adds the given attribute to the root element of the document.
	 * 
	 * Params:
	 *     element = the element to add
	 *     
	 * Returns: a reference to the element
	 */
	final Node add (Attribute attribute)
	{
		if (elements)
			return Node(elements.attribute(null, attribute.name, attribute.value));
		
		Node node = Node(tree.attribute(null, attribute.name, attribute.value));
		SimpleXML.attribute.node = node.node;
		
		return node;
	}
	
	///
	alias add opCat;
	
	///
	alias add opCatAssign;
	
	/**
	 * Returns a string representation of the document. It will return
	 * the whole tree as a string.
	 * 
	 * Returns: a string representation of the document
	 */
	char[] toString ()
	{
		return printer.print(this);
	}	
	
	/**
	 * This struct represents a node in the tree
	 */
	static struct Node
	{				
		private Document!(T).Node node;
		
		/**
		 * This is an attribute proxy allowing to perform attribute
		 * operations on all the attributes in this element.
		 */
		AttributeProxy attribute;
		
		/**
		 * Creates a new Node.
		 * 
		 * Params:
		 *     node = the internal node implementation
		 *     
		 * Returns: the newly create node
		 */
	   	static Node opCall (Document!(T).Node node)
	    {
	    	Node n;
	    	n.node = node;
	    	n.attribute.node = node;
	    	
	    	return n;
	    }
	   	
	   	/**
	   	 * Gets the name of the node.
	   	 * 
	   	 * Returns: the name of the node
	   	 */
	   	T[] name ()
	   	{
	   		return node.name;
	   	}
	   	
	   	/**
	   	 * Sets the name of the node.
	   	 * 
	   	 * Params:
	   	 *     name = the name to set
	   	 *     
	   	 * Returns: the name of the node
	   	 */
	   	T[] name (T[] name)
	   	{
	   		node.name = name;
	   		return node.name;
	   	}	   	
	   	
	   	/**
	   	 * Gets the value of the node.
	   	 * 
	   	 * Returns: the value of the node
	   	 */
	   	T[] value ()
	   	{
	   		return node.value;
	   	}
	   	
	   	/**
	   	 * Sets the value of the node.
	   	 * 
	   	 * Params:
	   	 *     value = the value to set
	   	 *      
	   	 * Returns: the value of the noe
	   	 */
	   	T[] value (T[] value)
	   	{
	   		node.value = value;
	   		return node.value;
	   	}
		
		/**
		 * Returns the first child element of the node, which matches the
		 * given name.
		 * 
		 * Params:
		 *     name = the name of the element
		 *      
		 * Returns: the child element or this
		 */
		Node opIndex (T[] name)
		{
			auto set = node.query[name];
			
			if (set.count > 0)
				return Node(set.nodes[0]);
			
			return *this;
		}
		
		/**
		 * Iterates over the children of the node
		 * 
		 * Params:
		 *     dg = the node and the value of the node will be passed to this for every iteration
		 *     
		 * Returns:
		 */
		int opApply (int delegate(ref Node) dg)
	    {
			if (!node)
				return 0;
			
	    	int result;
	            
	    	foreach (n ; node.children)
	    		if (n.type == XmlNodeType.Element && (result = dg(Node(n))) != 0)
	    			break;

	    	return result;
	    }
		
		/**
		 * Adds a new element to this element.
		 * 
		 * Params:
		 *     name = the name of the element
		 *     value = the value of the element
		 *     
		 * Returns:
		 */
		Node add (T[] name, T[] value = null)
		{
			return Node(node.element(null, name, value));
		}
		
		/**
		 * Adds a new element to this element.
		 * 
		 * Params:
		 *     name = the name of the element
		 *     
		 * Returns: a reference to the element
		 */
	   	Node add (SimpleXML.Element element)
	    {
	    	return Node(node.element(null, element.name, element.value));
	    }
	   	
		/**
		 * Adds a new attribute to this element.
		 * 
		 * Params:
		 *     attribute = the attribute
		 *     
		 * Returns: a reference to the element
		 */
	   	Node add (Attribute attribute)
	    {
	    	return Node(node.attribute(null, attribute.name, attribute.value));
	    }
	   	
	   	///
	   	alias add opCat;
	   	
	   	///
	   	alias add opCatAssign;
	   	
		/**
		 * Finds the first child element of this element with the given 
		 * name and sets it's value to the given value. If the element
		 * could not be found it's created and the give value is set. 
		 * 
		 * Params:
		 *     value = the value to set
		 *     name = the name of the element
		 */
   		void opIndexAssign (T2) (T2 value, T[] name)
   		{
   			static if (is(T2 : T[]))
   			{
   				if (auto node = node.attributes.name(null, name))
   					node.value = value;
   				
   				else
   					node.attribute(null, name, value);
   			}	   				
   			
   			else static if (is(T2 == bool))
   			{
   				T[] v = value ? "1" : "0";
   				
   				if (auto n = node.attributes.name(null, name))
   					n.value = v;
   				
   				else
   					node.attribute(null, name, v);
   			}
   			
   			else static if (is(T2 : long))
   			{
   				T[] v = Convert.to!(T[])(value);
   				
   				if (auto n = node.attributes.name(null, name))
   					n.value = v;
   				
   				else
   					node.attribute(null, name, v);
   			}
   		}
	   	
   		/**
   		 * Returns a string representation of this object which is the
   		 * value of the node
   		 * 
   		 * Returns: a string representation (the value)
   		 */
	   	T[] toString ()
	   	{
	   		return value;
	   	}

	   	/**
	   	 * This struct represents an attribute proxy. This is the type
	   	 * that is returned when calling Node.attribute and lets you 
	   	 * perform operations on attributes.
	   	 */
	   	static struct AttributeProxy
	   	{	
	   		private Document!(T).Node node;
	   		
			/**
			 * Finds the attribute with the given name in the element of 
			 * which this attribute proxy was returned.
			 * 
			 * Params:
			 *     name = the name of the attribute
			 *     
			 * Returns: an attribute proxy
			 */
	   		AttributeProxy opCall (T[] name)
	   		{
	   			AttributeProxy a;
	   			a.node = node.attributes.name(null, name);
	   			
	   			return a;
	   		}
	   		
	   		/**
	   		 * Gets the name of the attribute
	   		 * 
	   		 * Returns: the name of the attribute
	   		 */
		   	T[] name ()
		   	{
		   		return node.name;
		   	}
		  		   	
		   	/**
		   	 * Sets the name of the attribute 
		   	 * 
		   	 * Params:
		   	 *     name = the name of the attribute
		   	 *      
		   	 * Returns: the name of the attribute
		   	 */
		   	T[] name (T[] name)
		   	{
		   		node.name = name;
		   		return node.name;
		   	}
		   	
		   	/**
	   		 * Gets the value of the attribute
	   		 * 
	   		 * Returns: the value of the attribute
	   		 */
		   	T[] value ()
		   	{
		   		return node.value;
		   	}
		   	
		   	/**
		   	 * Sets the value of the attribute 
		   	 * 
		   	 * Params:
		   	 *     value = the value of the attribute
		   	 *      
		   	 * Returns: the value of the attribute
		   	 */
		   	T[] value (T[] value)
		   	{
		   		node.value = value;
		   		return node.value;
		   	}
	   		
		   	/**
		   	 * Returns the value of the attribute with the given name
		   	 * 
		   	 * Params:
		   	 *     name = the name of the attribute
		   	 *      
		   	 * Returns: the value of the attribute of null
		   	 */
	   		T[] opIndex (T[] name)
	   		{
	   			if (auto node = node.attributes.name(null, name))
	   				return node.value;
	   			
	   			return null;
	   		}
	   		
			/**
			 * Finds the attribute with the given name in the element of which
			 * this proxy object was received name and sets it's value to the
			 * given value. If the element could not be found it's created and
			 * the give value is set.
			 * 
			 * Params:
			 *     value = the value to set
			 *     name = the name of the element
			 */
	   		void opIndexAssign (T2) (T2 value, T[] name)
	   		{
	   			static if (is(T2 : T[]))
	   			{
	   				if (auto node = node.attributes.name(null, name))
	   					node.value = value;
	   				else
	   					node.attribute(null, name, value);
	   			}	   				
	   			
	   			else static if (is(T2 == bool))
	   			{
	   				T[] v = value ? "1" : "0";
	   				
	   				if (auto n = node.attributes.name(null, name))
	   					n.value = v;
	   				
	   				else
	   					node.attribute(null, name, v);
	   			}
	   			
	   			else static if (is(T2 : long))
	   			{
	   				T[] v = Convert.to!(T[])(value);
	   				
	   				if (auto n = node.attributes.name(null, name))
	   					n.value = v;
	   				
	   				else
	   					node.attribute(null, name, v);
	   			}				
	   		}	   		
	   		
	   		/** 
	   		 * Returns the value of the first attribute in the element of which 
	   		 * this proxy object was received, which matches the given name.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     aDefault = the default return value
	   		 *     
	   		 * Returns: true if the attribute was found and it's value was 1, otherwise aDefault
	   		 */
	   		bool getBool (T[] name, bool aDefault = false)
	   		{
	   			return (*this)[name] == "1" ? true : aDefault;
	   		}
	   		
	   		/** 
	   		 * Returns the value of the first attribute in the element of which 
	   		 * this proxy object was received, which matches the given name.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     aDefault = the default return value
	   		 *     
	   		 * Returns: the value of the attribute if it was found and could be
	   		 * 			converted to a long, otherwise aDefault.
	   		 */
	   		long getLong (T[] name, long aDefault = 0)
	   		{
	   			return Convert.to!(long)((*this)[name], aDefault);
	   		}
	   		
	   		/** 
	   		 * Returns the value of the first attribute in the element of which 
	   		 * this proxy object was received, which matches the given name.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     aDefault = the default return value
	   		 *     
	   		 * Returns: the value of the attribute if it was found and could be
	   		 * 			converted to an int, otherwise aDefault.
	   		 */
	   		int getInt (T[] name, int aDefault = 0)
	   		{
	   			return Convert.to!(int)((*this)[name], aDefault);
	   		}
	   		
	   		/**
	   		 * Adds a new attribute to the element the element of which this
	   		 * proxy object was received.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     value = the value of the attribute
	   		 *     
	   		 * Returns: the element this attribute was added
	   		 */
	   		Node add (T[] name, T[] value = null)
	   		{
	   			return Node(node.attribute(null, name, value));
	   		}
	   		
			/**
			 * Adds a new attribute to the element the element of which this
	   		 * proxy object was received.
			 * 
			 * Params:
			 *     name = the name of the element
			 *     
			 * Returns: the element this attribute was added
			 */
	   		Node add (Attribute attribute)
	   		{
	   			return Node(node.attribute(null, attribute.name, attribute.value));
	   		}
	   		
	   		
	   		/**
	   		 * Adds a new attribute to the element the element of which this
	   		 * proxy object was received.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     value = the value of the attribute
	   		 *     
	   		 * Returns: the element this attribute was added
	   		 */
	   		Node add (T[] name, bool value)
	   		{
	   			return Node(node.attribute(null, name, value ? "1" : "0"));
	   		}
	   		
	   		/**
	   		 * Adds a new attribute to the element the element of which this
	   		 * proxy object was received.
	   		 * 
	   		 * Params:
	   		 *     name = the name of the attribute
	   		 *     value = the value of the attribute
	   		 *     
	   		 * Returns: the element this attribute was added
	   		 */
	   		Node add (T[] name, int value)
	   		{
	   			return Node(node.attribute(null, name, Convert.toString(value)));
	   		}
	   		
	   		///
	   		//alias add opCat;
	   		
	   		///
	   		//alias add opCatAssign;
	   		
	   		Node opCatAssign (T[] name)
	   		{
	   			return Node(node.attribute(null, name, null));
	   		}
	   		
	   		/**
	   		 * Iterates over the children of the root node
	   		 * 
	   		 * Params:
	   		 *     dg = the attribute proxy be passed to this for every iteration
	   		 *     
	   		 * Returns:
	   		 */
			int opApply (int delegate(ref AttributeProxy) dg)
		    {
				if (!node)
					return 0;
				
		    	int result;		    	
		    	
		    	foreach (n ; node.attributes)
		    	{
		    		AttributeProxy a;
		    		a.node = n;
		    		
		    		if (n.type == XmlNodeType.Attribute && (result = dg(a)) != 0)
		    			break;
		    	}

		    	return result;
		    }
			
	   		/**
	   		 * Returns a string representation of this object which is the
	   		 * value of the attribute.
	   		 * 
	   		 * Returns: a string representation (the value)
	   		 */
		   	T[] toString ()
		   	{
		   		return value;
		   	}
	   	}
	}
	
	/**
	 * This is an attribute proxy allowing to perform attribute
	 * operations on all the attributes in the root element of this
	 * document.
	 */
	Node.AttributeProxy attribute;
   	
	/// This is a name-value pair representing an attribute
	struct Attribute
	{
		/// The name of this attribute
		T[] name;
		
		/// The value of this attribute
		T[] value;
	}
   	
	/// This is a name-value pair representing an element
	struct Element
	{
		/// The name of this element
		T[] name;
		
		/// The value of this element
		T[] value;
	}
}