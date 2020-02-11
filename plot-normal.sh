#!/bin/sh
gpname=/tmp/gp`date +%s`.plt
count=0
echo "set datafile separator \",\"" > $gpname
for txtname in "$@"
do
    ttl=`echo $txtname | rev | cut -c 11- | rev`
    count=$((${count}+1));
    echo $txtname
echo "set terminal wxt ${count} font 'Century Schoolbook L,12'; set title \"$ttl\";set xlabel \"Shell distance (microns)\"; set ylabel \"Mean intensity\"; plot \"${txtname}\" u 1:2 w lp pt 7 t 'wav1', \"${txtname}\" u 4:5 w lp pt 7 t 'wav2', \"${txtname}\" u 7:8 w lp pt 7 t 'wav3', \"${txtname}\" u 10:11 w lp pt 7 t 'wav4'" >> ${gpname}
done
nohup /usr/local/bin/gnuplot -persist ${gpname} 2>/dev/null &
