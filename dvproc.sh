#!/bin/bash
OCTPRG="/usr/local/bin/octave -q";
BORDER=24
for datafilename in "$@"
do
tmpf="/tmp/dv-proc-`date +%Y%m%d%H%M%S`.txt"
zsname="${datafilename}.zs"

if [ ! -f $zsname ]
then
nice /opt/bin/chromatic-shift "${datafilename}" > $tmpf
sh ${tmpf}
fi

tmpf="/tmp/dv-proc2-`date +%Y%m%d%H%M%S`.txt"
octzsname=\"$zsname\"
polyfilename="${zsname}.pol"
ZS=`/opt/bin/find-midsection.sh "$zsname" | tail -n 1`;
Z=`echo $ZS|cut -d " " -f 1`;
THRS=`${OCTPRG} --eval "aa=mrcreadsec($octzsname,$Z);am=uint8(floor(nrm2d(aa).*256));at=graythresh(am);printf(\"%.4f\",at*max(aa(:)));"`
nice Threshold $zsname ${zsname}.thr -z1=$Z -w1=0 -not_below=$THRS -result=mask;
nice 2DObjFinder ${zsname}.thr -poly=$polyfilename -border=$BORDER -spacing=4 \
    -minpts=300 -exclude_edge -outer_only
nice perl /opt/bin/copyObjsFromPerims.pl "${zsname}" "${polyfilename}" $BORDER > $tmpf
sh ${tmpf}

BD=`dirname "${zsname}"`

nice /opt/bin/get-peripheral-intensity.sh ${zsname}.*sbs
#/opt/bin/plot-errorbars.sh ${zsname}*NEint.txt
/opt/bin/plot-normal.sh ${zsname}*NEint.csv

done
