/*
 * @(#)NullPointerException.java	1.20 05/11/17
 *
 * Copyright 2006 Sun Microsystems, Inc. All rights reserved.
 * SUN PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 * 
 * Port to the D Programming language:
 *     Jacob Carlborg <jacob.carlborg@gmail.com>
 */
module mambo.exception.NullPointerException;

import tango.core.Exception;

import mambo.core.string : string;

/**
 * Thrown when an application attempts to use <code>null</code> in a 
 * case where an object is required. These include: 
 * <ul>
 * <li>Calling the instance method of a <code>null</code> object. 
 * <li>Accessing or modifying the field of a <code>null</code> object. 
 * <li>Taking the length of <code>null</code> as if it were an array. 
 * <li>Accessing or modifying the slots of <code>null</code> as if it 
 *     were an array. 
 * <li>Throwing <code>null</code> as if it were a <code>Throwable</code> 
 *     value. 
 * </ul>
 * <p>
 * Applications should throw instances of this class to indicate 
 * other illegal uses of the <code>null</code> object. 
 *
 * @author  unascribed
 * @version 1.20, 11/17/05
 * @since   JDK1.0
 */
public class NullPointerException : Exception
{

	/**
	 * Constructs a <code>NullPointerException</code> with no detail message.
	 * 
	 * Params:
	 *     file = the file where the exception occurred
	 *     line = the line where the exception occurred
	 */
	public this (string file, size_t line)
	{
		super("Null Pointer Exception");
	}

	/**
	 *
	 * Constructs a <code>NullPointerException</code> with the specified 
	 * detail message. 
	 * 
	 * Params:
	 *     s = the detail message.
	 *     file = the file where the exception occurred
	 *     line = the line where the exception occurred
	 */
	public this (string s, string file, size_t line)
	{
		super(s);
	}
}