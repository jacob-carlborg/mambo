#!/bin/sh

set -e

if [ -s "$HOME/.dvm/scripts/dvm" ] ; then
    . "$HOME/.dvm/scripts/dvm" ;
    dvm use 2.066.1
fi

function all_files () {
	find $1 -name '*.d' -exec echo -n '{} ' \;
}

mambo=`all_files mambo`
dspec=`all_files dspec`
specs=`all_files spec`
tango_path=~/.dub/packages/tango-1.0.0_2.066

dmd -I$tango_path -I. -L-L$tango_path -L-ltango -unittest -ofspec_bin $mambo $dspec $specs
./spec_bin