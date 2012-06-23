/**
 * Copyright: Copyright (c) 2008-2012 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: 2008
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.core.AssociativeArray;

import tango.core.Exception : NoSuchElementException;

import mambo.util.Traits;

/**
 * Returns the value to which the specified key is mapped,
 * or ($D_CODE null) if this associative array contains no mapping for the key.
 * 
 * $(P More formally, if the specified associative array contains a mapping from a key
 * $(D_CODE k) to a value $(D_CODE v) such that $(D_CODE (key==null ? k==null :
 * key.equals(k))), then this method returns $(D_CODE v); otherwise
 * it returns $(D_CODE null).  (There can be at most one such mapping.))
 * 
 * Params:
 *     aa = the associative array to get the value from
 *     key = the key whose associated value is to be returned
 *     
 *     
 * Returns: the value to which the specified key is mapped, or
 * 			$(D_CODE null) if this map contains no mapping for the key
 * 
 * Throws: AssertException if any paramter is invalid
 * 		   NoSuchElementException if the given key could not be found
 */
V get (K, V) (V[K] aa, K key)
in
{
	assert(aa.length > 0, "mambo.collection.AssociativeArray.get: The length of the associative array was 0");
}
body
{
	if (key in aa)
		return aa[key];
	
	else
		throw new NoSuchElementException("The give key could not be found", __FILE__, __LINE__);
}

/**
 * Associates the specified value with the specified key in the specified 
 * associative array. If the associative array previously contained a mapping for
 * the key, the old value is replaced by the specified value.  (An associative array
 * <tt>aa</tt> is said to contain a mapping for a key <tt>k</tt> if and only
 * if $(LINK2 #containsKey(Object), m.containsKey(k)) would return
 * <tt>true</tt>.)
 * 
 * Params:
 *     aa = the associative array to add the key/value pair to
 *     key = key with which the specified value is to be associated
 *     value = value to be associated with the specified key
 *     
 * Returns: the previous value associated with <tt>key</tt>, or
 *          or the newly associated value.
 */
V put (K, V) (V[K] aa, K key, V value)
{
	if (key in aa)
	{
		V prevValue = aa[key];
		aa[key] = value;
		
		return prevValue;
	}
	
	return aa[key] = value;
}

/**
 * Associates the specified value with the specified key in the specified 
 * associative array. If the associative array previously contained a mapping for
 * the key, the existing value associated for the given key will be return and the
 * associative array is unchanged. (An associative array <tt>aa</tt> is said
 * to contain a mapping for a key <tt>k</tt> if and only if
 * $(LINK2 #containsKey(Object), m.containsKey(k)) would return <tt>true</tt>.)
 * 
 * Params:
 *     aa = the associative array to add the key/value pair to
 *     key = key with which the specified value is to be associated
 *     value = value to be associated with the specified key
 *     
 * Returns: the previous value associated with <tt>key</tt>, or
 *          or the newly associated value.
 */
V insert (K, V) (V[K] aa, K key, V value)
{
	if (key in aa)
		return aa[key];
	
	return aa[key] = value;
}

/**
 * Associates the specified value with the specified key in the specified 
 * multimap. If the multimap previously contained a mapping for
 * the key, the existing value associated for the given key will be return and the
 * multimap is unchanged. (An multimap <tt>mm</tt> is said
 * to contain a mapping for a key <tt>k</tt> if and only if
 * $(LINK2 #containsKey(Object), m.containsKey(k)) would return <tt>true</tt>.)
 * 
 * Params:
 *     mm = the multimap to add the key/value pair to
 *     key = key with which the specified value is to be associated
 *     value = value to be associated with the specified key
 *     
 * Returns: the previous value associated with <tt>key</tt>, or
 *          or the newly associated value.
 */
V insert (K, V) (V[][K] mm, K key, V value)
{
	if (key in aa)
		return aa[key];
	
	return aa[key] ~= value;
}

/**
 * Removes the mapping for a key from the specified 
 * associative array if it is present. More formally, 
 * if the associative array contains a mapping
 * from key <tt>k</tt> to value <tt>v</tt> such that
 * $(D_CODE (key==null ?  k==null : key.equals(k))), that mapping
 * is removed.  (The associative array can contain at most one such mapping.)
 *
 * $(P Returns the value to which the associative array previously associated the key,
 * or <tt>null</tt> if the map contained no mapping for the key.)
 * 
 * Params:
 *     aa = the associative array to remove the key/value pair from
 *     key = key whose mapping is to be removed from the associative array
 *     
 * Returns:
 */
V remove (K, V) (V[K] aa, K key)
{
	if (key in aa)
	{
		V v = aa[key];
		aa.remove(k);
		
		return v;
	}
	
	else
		throw new NoSuchElementException("The give key could not be found", __FILE__, __LINE__);		
}

/**
 * Returns <tt>true</tt> if the specified 
 * associative array contains no key-value mappings.
 * 
 * Params:
 *     aa = the associative array to check if it's empty
 *
 * Returns: <tt>true</tt> if the specified 
 * 			associative array contains no key-value mappings
 */
bool isEmpty (K, V) (V[K] aa)
{
	return aa.length == 0;
}


/**
 * Returns a array of the values contained in the 
 * specifed associative array. The array is backed by 
 * the associative array(if it contains classes or pointers),
 * so changes to the associative array are reflected in 
 * the array, and vice-versa. If the associative array is
 * modified while an iteration over the collection is in progress
 * (except through the iterator's own <tt>remove</tt> operation),
 * the results of the iteration are undefined.  The collection
 * supports element removal, which removes the corresponding
 * mapping from the map, via the <tt>Iterator.remove</tt>,
 * <tt>Collection.remove</tt>, <tt>removeAll</tt>,
 * <tt>retainAll</tt> and <tt>clear</tt> operations.  It does not
 * support the <tt>add</tt> or <tt>addAll</tt> operations.
 * 
 * Params:
 *     aa = the associative array to get the values from
 *     
 * Returns: a collection view of the values contained in this map
 */
V[] values (K, V) (V[K] aa)
{
	return aa.values;
}

/**
 * Returns the number of key-value mappings in
 * the specified associative array
 * 
 * Params:
 *     aa = the associative array to get the number of key-value mappings from
 *     
 * Returns: the number of key-value mappings in the associative array
 */
int size (K, V) (V[K] aa)
{
	aa.length;
}

/**
 * Returns value to lower bound
 * 
 * associative array. If the associative array previously contained a mapping for
 * 
 * Returns the value of the key pointing to the first element in the container
 * whose key does not compare less than key, i.e. it is either equal or greater.
 * 
 * Params:
 *     aa = the associative array to get the lower bound of
 *     key = the key to be compared
 *     
 * Returns: the value of the key of the first element in the container whose 
 * 			key does not compare less than key.
 * 
 * Throws: NoSuchElementException if the given key could not be found
 */
V lowerBound (K, V) (V[K] aa, K key)
{
	foreach (k, v ; aa)
		if (!(k < key))
			return v;
	
	throw new NoSuchElementException("The give key could not be found", __FILE__, __LINE__);
}

/**
 * Returns the bounds of a range that includes all the elements in the
 * container with a key that compares equal to key.
 * 
 * In map containers,  where no duplicate keys are allowed, the range
 * will include one element at most. If key does not match any key in
 * the container, the range returned has a length of zero.
 * 
 * Params:
 *     mm = the multimap to get the range from
 *     key = the key value to be compared
 *     
 * Returns: an array containing all the values the matched the key
 */
V[] equalRange (K, V) (V[][K] mm, K key)
{
	if (key in mm)
		return mm[key];

	else
		return [];
}

/**
 * Returns the bounds of a range that includes all the elements in the
 * container with a key that compares equal to key.
 * 
 * In map containers,
 * where no duplicate keys are allowed, the range will include one
 * element at most. If key does not match any key in the container, the range
 * returned has a length of zero.
 * 
 * Params:
 *     aa = the associative array to get the range from
 *     key = the key value to be compared
 *     
 * Returns: an array containing all the values the matched the key
 */
V[] equalRange (K, V) (V[K] aa, K key)
{
	if (key in aa)
		return [aa[key]];
	
	else
		return [];
}

// This is a function private to this package. From some reason it cannot be accessible if
// it's marked with "package".
bool _anyAA (alias predicate, AA) (AA aa)
	if (isAssociativeArray!(AA) && isAssociativeArrayPredicate!(predicate, AA))
{
	foreach (k, v ; aa)
		if (predicate(k, v))
			return true;

	return false;
}

// This is a function private to this package. From some reason it cannot be accessible if
// it's marked with "package".
auto _findAA (alias predicate, AA) (AA aa)
	if (isAssociativeArray!(AA) && isAssociativeArrayPredicate!(predicate, AA))
{
	alias KeyTypeOfAssociativeArray!(AA) K;
	alias ValueTypeOfAssociativeArray!(AA) V;
	alias KeyValue!(K, V) Pair;

	foreach (k, v ; aa)
		if (predicate(k, v))
			return Pair(k, v, false);

	return Pair.init;
}

struct KeyValue (K, V)
{
	K key;
	V value;
	private bool isEmpty_ = true;
	
	alias isEmpty this;

	@property bool isEmpty ()
	{
		return isEmpty_;
	}
}