#!/bin/sh
#
#find-midsection, uses 1st channel, relies on the program meantimesstd which should output to /tmp/secvals${uuid}.txt
FNAME=$1;
OCTPRG="/usr/local/bin/octave -q";
UUID=`uuidgen`;
echo "uuid is $UUID"
SECNAME=\""/tmp/secvals.$UUID.$LOGNAME.txt\""
echo "secnamefile is $SECNAME"
/opt/bin/meantimesstd $FNAME $UUID
echo "did meantimesstd on $FNAME"

MS=`$OCTPRG --eval "aa=load($SECNAME);a=aa(1:end-1);p=polyfit(1:length(a),a',2);b=polyval(p,1:length(a));disp(find(b==max(b))-1);disp(aa(end));"`
echo "just exectuted octave";
echo $MS;
