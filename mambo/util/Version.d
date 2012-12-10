/**
 * Copyright: Copyright (c) 2009 Jacob Carlborg.
 * Authors: Jacob Carlborg
 * Version: Initial created: Mar 28, 2009
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module mambo.util.Version;

template Version (char[] V)
{
	mixin(
	"version(" ~ V ~ ")
	{
		enum bool Version = true;
	}
	else
	{
		enum bool Version = false;
	}");
}

version (GNU)
{
	version (darwin)
		version = OSX;
	
	static if ((void*).sizeof > int.sizeof)
		version = D_LP64;
}

version (DigitalMars)
	version (OSX)
		version = darwin;

//Compiler Vendors
version (DigitalMars) enum bool DigitalMars = true;
else enum bool DigitalMars = false;

version (GNU) enum bool GNU = true;
else enum bool GNU = false;

version (LDC) enum bool LDC = true;
else enum bool LDC = false;

version (LLVM) enum bool LLVM = true;
else enum bool LLVM = false;

version (D_Version2) enum bool D_Version2 = true;
else enum bool D_Version2 = false;



//Processors 
version (PPC) enum bool PPC = true;
else enum bool PPC = false;

version (PPC64) enum bool PPC64 = true;
else enum bool PPC64 = false;

version (SPARC) enum bool SPARC = true;
else enum bool SPARC = false;

version (SPARC64) enum bool SPARC64 = true;
else enum bool SPARC64 = false;

version (X86) enum bool X86 = true;
else enum bool X86 = false;

version (X86_64) enum bool X86_64 = true;
else enum bool X86_64 = false;



//Operating Systems
version (aix) enum bool aix = true;
else enum bool aix = false;

version (cygwin) enum bool cygwin = true;
else enum bool cygwin = false;

version (darwin) enum bool darwin = true;
else enum bool darwin = false;

version (OSX) enum bool OSX = true;
else enum bool OSX = false;

version (freebsd) enum bool freebsd = true;
else enum bool freebsd = false;

version (linux) enum bool linux = true;
else enum bool linux = false;

version (solaris) enum bool solaris = true;
else enum bool solaris = false;

version (Unix) enum bool Unix = true;
else enum bool Unix = false;

version (Win32) enum bool Win32 = true;
else enum bool Win32 = false;

version (Win64) enum bool Win64 = true;
else enum bool Win64 = false;

version (Windows) enum bool Windows = true;
else enum bool Windows = false;



//Rest
version (BigEndian) enum bool BigEndian = true;
else enum bool BigEndian = false;

version (LittleEndian) enum bool LittleEndian = true;
else enum bool LittleEndian = false;

version (D_Coverage) enum bool D_Coverage = true;
else enum bool D_Coverage = false;

version (D_Ddoc) enum bool D_Ddoc = true;
else enum bool D_Ddoc = false;

version (D_InlineAsm_X86) enum bool D_InlineAsm_X86 = true;
else enum bool D_InlineAsm_X86 = false;

version (D_InlineAsm_X86_64) enum bool D_InlineAsm_X86_64 = true;
else enum bool D_InlineAsm_X86_64 = false;

version (D_LP64) enum bool D_LP64 = true;
else enum bool D_LP64 = false;

version (D_PIC) enum bool D_PIC = true;
else enum bool D_PIC = false;

version (GNU_BitsPerPointer32) enum bool GNU_BitsPerPointer32 = true;
else enum bool GNU_BitsPerPointer32 = false;

version (GNU_BitsPerPointer64) enum bool GNU_BitsPerPointer64 = true;
else enum bool GNU_BitsPerPointer64 = false;

version (all) enum bool all = true;
else enum bool D_InlineAsm_X86_64 = false;

version (none) enum bool D_InlineAsm_X86_64 = true;
else enum bool none = false;

version (Tango)
{
	enum bool Tango = true;
	enum bool Phobos = false;
	
	version (PhobosCompatibility) enum bool PhobosCompatibility = true;
	else enum bool PhobosCompatibility = false;	
}

else
{
	enum bool Tango = false;
	enum bool Phobos = true; 
	enum bool PhobosCompatibility = false;
}