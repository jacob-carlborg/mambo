/**
 * Copyright: Copyright (c) 2009-2011 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Oct 5, 2009
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.util.Reflection;

import mambo.core.string;
import mambo.util.Ctfe;

/**
 * Returns the name of the given function
 *
 * Params:
 *     func = the function alias to get the name of
 *
 * Returns: the name of the function
 */
template functionNameOf (alias func)
{
	version(LDC)
		enum functionNameOf = (&func).stringof[1 .. $];

	else
		enum functionNameOf = (&func).stringof[2 .. $];
}

/**
 * Returns the parameter names of the given function
 *
 * Params:
 *     func = the function alias to get the parameter names of
 *
 * Returns: an array of strings containing the parameter names
 */
template parameterNamesOf (alias func)
{
	enum parameterNamesOf = parameterNamesOfImpl!(func);
}

/**
 * Returns the parameter names of the given function
 *
 * Params:
 *     func = the function alias to get the parameter names of
 *
 * Returns: an array of strings containing the parameter names
 */
private string[] parameterNamesOfImpl (alias func) ()
{
	string funcStr = typeof(&func).stringof;

	auto start = funcStr.indexOf('(');
	auto end = funcStr.indexOf(')');

	enum firstPattern = ' ';
	enum secondPattern = ',';

	funcStr = funcStr[start + 1 .. end];

	if (funcStr == "")
		return null;

	funcStr ~= secondPattern;

	string token;
	string[] arr;

	foreach (c ; funcStr)
	{
		if (c != firstPattern && c != secondPattern)
			token ~= c;

		else
		{
			if (token)
				arr ~= token;

			token = null;
		}
	}

	if (arr.length == 1)
		return arr;

	string[] result;
	bool skip = false;

	foreach (str ; arr)
	{
		skip = !skip;

		if (skip)
			continue;

		result ~= str;
	}

	return result;
}

/**
 * Helper function for callWithNamedArguments
 *
 * Returns:
 */
private string buildFunction (alias func, string args) ()
{
	enum str = split(args);
	string[] params;
	string[] values;
	auto mixinString = functionNameOf!(func) ~ "(";

	foreach (s ; str)
	{
		auto index = s.indexOf('=');
		params ~= s[0 .. index];
		values ~= s[index + 1 .. $];
	}

	enum parameterNames = parameterNamesOf!(func);

	foreach (i, s ; parameterNames)
	{
		auto index = params.indexOf(s);

		if (index != params.length)
			mixinString ~= values[index] ~ ",";
	}

	return mixinString[0 .. $ - 1] ~ ");";
}

/**
 * Calls the given function with named arguments
 *
 * Params:
 *     func = an alias to the function to call
 *     args = a string containing the arguments to call using this syntax: `arg2=value,arg1="value"`
 */
void callWithNamedArguments (alias func, string args) ()
{
	mixin(buildFunction!(func, args));
}

/**
 * Evaluates to true if T has a instance method with the given name
 *
 * Params:
 * 		T = the type of the class/struct
 * 		method = the name of the method
 */
template hasInstanceMethod (T, string method)
{
	enum hasInstanceMethod = is(typeof({
		T t;
		mixin("auto f = &t." ~ method ~ ";");
	}));
}

/**
 * Evaluates to true if T has a class method with the given name
 *
 * Params:
 * 		T = the type of the class/struct
 * 		method = the name of the method
 */
template hasClassMethod (T, string method)
{
	enum hasClassMethod = is(typeof({
		mixin("auto f = &T." ~ method ~ ";");
	}));
}

/**
 * Evaluates to true if T has a either a class method or a instance method with the given name
 *
 * Params:
 * 		T = the type of the class/struct
 * 		method = the name of the method
 */
template hasMethod (T, string method)
{
	enum hasMethod = hasClassMethod!(T, method) || hasInstanceMethod!(T, method);
}

/**
 * Evaluates to true if T has a field with the given name
 *
 * Params:
 * 		T = the type of the class/struct
 * 		field = the name of the field
 */
template hasField (T, string field)
{
	enum hasField = hasFieldImpl!(T, field, 0);
}

private template hasFieldImpl (T, string field, size_t i)
{
	static if (T.tupleof.length == i)
		enum hasFieldImpl = false;

	else static if (nameOfFieldAt!(T, i) == field)
		enum hasFieldImpl = true;

	else
		enum hasFieldImpl = hasFieldImpl!(T, field, i + 1);
}

/**
 * Evaluates to an array of strings containing the names of the fields in the given type
 */
template fieldsOf (T)
{
	enum fieldsOf = fieldsOfImpl!(T, 0);
}

/**
 * Implementation for fieldsOf
 *
 * Returns: an array of strings containing the names of the fields in the given type
 */
template fieldsOfImpl (T, size_t i)
{
	static if (T.tupleof.length == 0)
		enum fieldsOfImpl = [""];

	else static if (T.tupleof.length - 1 == i)
		enum fieldsOfImpl = [nameOfFieldAt!(T, i)];

	else
		enum fieldsOfImpl = nameOfFieldAt!(T, i) ~ fieldsOfImpl!(T, i + 1);
}

/**
 * Evaluates to the type of the field with the given name
 *
 * Params:
 * 		T = the type of the class/struct
 * 		field = the name of the field
 */
template TypeOfField (T, string field)
{
	static assert(hasField!(T, field), "The given field \"" ~ field ~ "\" doesn't exist in the type \"" ~ T.stringof ~ "\"");

	alias TypeOfFieldImpl!(T, field, 0) TypeOfField;
}

private template TypeOfFieldImpl (T, string field, size_t i)
{
	static if (nameOfFieldAt!(T, i) == field)
		alias typeof(T.tupleof[i]) TypeOfFieldImpl;

	else
		alias TypeOfFieldImpl!(T, field, i + 1) TypeOfFieldImpl;
}

/**
 * Evaluates to a string containing the name of the field at given position in the given type.
 *
 * Params:
 * 		T = the type of the class/struct
 * 		position = the position of the field in the tupleof array
 */
template nameOfFieldAt (T, size_t position)
{
    static assert (position < T.tupleof.length, format!(`The given position "`, position, `" is greater than the number of fields (`, T.tupleof.length, `) in the type "`, T, `"`));

	enum nameOfFieldAt = __traits(identifier, T.tupleof[position]);
}

/**
 * Sets the given value to the filed with the given name
 *
 * Params:
 *     t = an instance of the type that has the field
 *     value = the value to set
 */
void setValueOfField (T, U, string field) (ref T t, U value)
in
{
	static assert(hasField!(T, field), "The given field \"" ~ field ~ "\" doesn't exist in the type \"" ~ T.stringof ~ "\"");
}
body
{
	enum len = T.stringof.length;

	foreach (i, dummy ; typeof(T.tupleof))
	{
		static if (f == nameOfFieldAt!(T, i))
		{
			t.tupleof[i] = value;
			break;
		}
	}
}

/**
 * Gets the value of the field with the given name
 *
 * Params:
 *     t = an instance of the type that has the field
 *
 * Returns: the value of the field
 */
U getValueOfField (T, U, string field) (T t)
in
{
	static assert(hasField!(T, field), "The given field \"" ~ field ~ "\" doesn't exist in the type \"" ~ T.stringof ~ "\"");
}
body
{
	enum len = T.stringof.length;

	foreach (i, dummy ; typeof(T.tupleof))
	{
		static if (field == nameOfFieldAt!(T, i))
			return t.tupleof[i];
	}

	assert(0);
}

/**
 * Gets all the class names in the given string of D code
 *
 * Params:
 *     code = a string containg the code to get the class names from
 *
 * Returns: the class names
 */
string[] getClassNames (string code) ()
{
	enum fileContent = code;
	enum classString = "class";
	bool foundPossibleClass;
	bool foundClass;
	string[] classNames;
	string className;

	for (size_t i = 0; i < fileContent.length; i++)
	{
		final c = fileContent[i];

		if (foundPossibleClass)
		{
			if (c == ' ' || c == '\n')
				foundClass = true;

			foundPossibleClass = false;
		}

		else if (foundClass)
		{
			if (c == '{')
			{
				classNames ~= className;
				foundClass = false;
				className = "";
			}

			else if (c != ' ' && c != '\n')
				className ~= c;
		}

		else
		{
			if (i + classString.length < fileContent.length)
			{
				if (fileContent[i .. i + classString.length] == classString)
				{
					if (i > 0)
					{
						if (fileContent[i - 1] == ' ' || fileContent[i - 1] == '\n' || fileContent[i - 1] == ';' || fileContent[i - 1] == '}')
						{
							foundPossibleClass = true;
							i += classString.length - 1;
							continue;
						}
					}

					else
					{
						foundPossibleClass = true;
						i += classString.length - 1;
						continue;
					}
				}
			}
		}
	}

	return classNames;
}

/**
 * Creates a new instance of class with the given name
 *
 * Params:
 *     name = the fully qualified name of the class
 *     args = the arguments to the constructor
 *
 * Returns: the newly created instance or null
 */
T factory (T) (string name)
{
	auto classInfo = ClassInfo.find(name);

	if (!classInfo)
		return null;

	auto object = newInstance(classInfo);

	if (classInfo.flags & 8 && classInfo.defaultConstructor is null)
	{
		auto o = cast(T) object;

		static if (is(typeof(o._ctor(args))))
			return o._ctor(args);

		else
			return null;
	}

	else
	{
		if (classInfo.flags & 8 && classInfo.defaultConstructor !is null)
		{
			Object delegate () ctor;
			ctor.ptr = cast(void*) object;
			ctor.funcptr = cast(Object function()) classInfo.defaultConstructor;

			return cast(T) ctor();
		}

		else
			return cast(T) object;
	}
}

private
{
	version (LDC)
		extern (C) Object _d_allocclass(in ClassInfo);

	else
		extern (C) Object _d_newclass(in ClassInfo);
}

/**
 * Returns a new instnace of the class associated with the given class info.
 *
 * Params:
 *     classInfo = the class info associated with the class
 *
 * Returns: a new instnace of the class associated with the given class info.
 */
Object newInstance (in ClassInfo classInfo)
{
	version (LDC)
	{
		Object object = _d_allocclass(classInfo);
        (cast(byte*) object)[0 .. classInfo.init.length] = classInfo.init[];

        return object;
	}

	else
		return _d_newclass(classInfo);
}

/**
 * Return a new instance of the class with the given name.
 *
 * Params:
 *     name = the fully qualified name of the class
 *
 * Returns: a new instance or null if the class name could not be found
 */
Object newInstance (string name)
{
	auto classInfo = ClassInfo.find(name);

	if (!classInfo)
		return null;

	return newInstance(classInfo);
}
