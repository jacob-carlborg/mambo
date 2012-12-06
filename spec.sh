#!/bin/sh

dmd -I../ -m32 -L-ltango -unittest -ofspec `find . -name '*.d'`

if [ "$?" = 0 ] ; then
  ./spec
fi