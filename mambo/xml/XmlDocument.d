/**
 * Copyright: Copyright (c) 2010-2011 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Jun 26, 2010
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.xml.XmlDocument;

import std.exception;

import tango.text.xml.DocPrinter;
import tango.text.xml.Document;
import tango.io.Stdout;

import mambo.core._;

/**
 * Evaluates to $(D_PARAM T) if $(D_PARAM T) is a character type. Otherwise this
 * template will not compile.
 */
template Char (T)
{
	static if (is(T == char) || is(T == wchar) || is(T == dchar))
		alias T Char;

	else
		static assert(false, `The given type "` ~ T.stringof ~ `" is not a vaild character type, valid types are "char", "wchar" and "dchar".`);
}

/// This class represents an exception thrown by XmlDocument.
class XMLException : Exception
{
	this (string message, string file = null, size_t line = 0)
	{
		super(message, file, line);
	}
}

/**
 * This class represents an XML DOM document. It provides a common interface to the XML
 * document implementations available in Phobos and Tango.
 */
final class XmlDocument (T = char)
{
	/// The type of the document implementation.
	alias Document!(T) Doc;
	
	/// The type of the node implementation.
	alias Doc.Node Node;

	/// The type of the query node implementation.
	//alias XmlPath!(T).NodeSet QueryNode;
	
	///
	alias const(T)[] tstring;
	
	/// The type of the visitor type implementation.
	alias Doc.Visitor VisitorType;

	/// Set this to true if there should be strict errro checking.
	bool strictErrorChecking;
	
	/// The number of spaces used for indentation used when printing the document.
	uint indentation = 4;
	
	private Doc doc;	
	private DocPrinter!(T) printer;
	
	/**
	 * Creates a new instance of this class
	 * 
	 * Examples:
	 * ---
	 * auto doc = new XmlDocument!();
	 * ---
	 * 
	 * Params:
	 *     strictErrorChecking = true if strict errro checking should be enabled
	 */
	this (bool strictErrorChecking = true)
	{
		doc = new Doc;
		this.strictErrorChecking = strictErrorChecking;
	}
	
	/**
	 * Attaches a header to the document.
	 * 
	 * Examples:
	 * ---
	 * auto doc = new XmlDocument!();
	 * doc.header("UTF-8");
	 * // <?xml version="1.0" encoding="UTF-8"?>
	 * ---
	 * 
	 * Params:
	 *     encoding = the encoding that should be put in the header
	 *      
	 * Returns: the receiver
	 */
	XmlDocument header (tstring encoding = null)
	{
		doc.header(encoding);

		return this;
	}
	
	/// Rests the reciver. Allows to parse new content.
	XmlDocument reset ()
	{
		doc.reset;

		return this;
	}
	
	/// Return the root document node, from which all other nodes are descended.
	Node tree ()
	{
		return doc.tree;
	}
	
	/**
	 * Parses the given string of XML.
	 * 
	 * Params:
	 *     xml = the XML to parse
	 */
	void parse (tstring xml)
	{
		doc.parse(xml);
	}
	
	/// Return an xpath handle to query this document. This starts at the document root.
	auto query ()
	{
		return doc.tree.query;
		//return QueryProxy(doc.tree.query);
	}
	
	/// Pretty prints the document.
	override string toString ()
	{
		if (!printer)
			printer = new DocPrinter!(T);

		printer.indent = indentation;
		auto str = printer.print(doc);

		return assumeUnique(str);
	}
	
	/**
	 * Attaches a new node to the docuement.
	 * 
	 * Params:
	 *     name = the name of the node
	 *     value = the vale of the node
	 *     
	 * Returns: returns the newly created node
	 */
	Node createNode (tstring name, tstring value = null)
	{
		return tree.element(null, name, value).detach;
	}
}