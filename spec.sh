#!/bin/sh

dmd -I../ -m32 -L-ltango -unittest -ofspec_bin `find spec -name '*.d'`

if [ "$?" = 0 ] ; then
  ./spec_bin
fi