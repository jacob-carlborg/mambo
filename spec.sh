#!/bin/sh

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
    . "$HOME/.dvm/scripts/dvm" ;
    dvm use 2.063.2
fi

function all_files () {
	find $1 -name '*.d' -exec echo -n '{} ' \;
}

mambo=`all_files mambo`
dspec=`all_files dspec`
specs=`all_files spec`

dmd -I. -L-ltango -unittest -ofspec_bin $mambo $dspec $specs

if [ "$?" = 0 ] ; then
  ./spec_bin
fi