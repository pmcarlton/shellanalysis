#!/bin/sh
gpname=/tmp/gp`date +%s`.plt
count=0
for txtname in "$@"
do
    ttl=`echo $txtname | rev | cut -c 11- | rev`
    count=$((${count}+1));
    echo $txtname
echo "set terminal wxt ${count}; set title \"$ttl\"; plot \"${txtname}\" u 1:2:3 w yerrorlines t 'wav1', \"${txtname}\" u 4:5:6 w yerrorlines t 'wav2', \"${txtname}\" u 7:8:9 w yerrorlines t 'wav3', \"${txtname}\" u 10:11:12 w yerrorlines t 'wav4'" >> ${gpname}
done
/usr/local/bin/gnuplot -persist ${gpname} 2>/dev/null &

