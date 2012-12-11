#!/bin/sh

function all_files () {
	find $1 -name '*.d' -exec echo -n '{} ' \;
}

mambo=`all_files mambo`
dspec=`all_files dspec`
specs=`all_files spec`

dmd -I. -m32 -L-ltango -unittest -ofspec_bin $mambo $dspec $specs

if [ "$?" = 0 ] ; then
  ./spec_bin
fi