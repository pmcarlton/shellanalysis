$datafile=shift;
$polyfile=shift;
$pad=shift; #BORDER
#$pad+=1; #to enable re-cutting
open IN,$polyfile;
foreach (<IN>) {
    @F=split;
    if (/polygon/ || /end/)  {
        if ($goflag) {
            $ct=$ct+1;
            $cts=sprintf("%.3i",$ct);
            $x1=$xminacc-$pad;$x2=$xmaxacc+$pad;$y1=$yminacc-$pad;$y2=$ymaxacc+$pad;
            print "CopyRegion $datafile $datafile.$cts.sbs -x=$x1:$x2 -y=$y1:$y2\n";
        }
        $xminacc=0xFFFFFFFF; $yminacc=0xFFFFFFFF; $xmaxacc=(-$xminacc); $ymaxacc=(-$yminacc);
    }
    if (/point/) {
        $goflag=1;
        $x=$F[1];$y=$F[2];
        $xminacc=($xminacc>$x ? $x : $xminacc);
        $yminacc=($yminacc>$y ? $y : $yminacc);
        $xmaxacc=($xmaxacc<$x ? $x : $xmaxacc);
        $ymaxacc=($ymaxacc<$y ? $y : $ymaxacc);
    }
}
close IN;
