#!/usr/local/bin/perl
 
#input: an mrc file with N wavelengths
#output: header info as needed
#20130213pmc

@dtypes=('Byte(uchar)','Short(int16)','Float(float32)','Short(int16)','Float/(float32)','Short/(int16)','UShort/(uint16)','Long/(int32)');

$finname=shift;
$inname=qx(basename $finname);
chomp($inname);

#$rmflag=shift;
$rmflag=1;

$outname=$finname."zs";

open IN,$finname or die "Couldn't find $finname !";

$br=read(IN,$hdr,1024);
close IN;

if($br != 1024){die "jacked!!!";}

$endi = "undefined";
($ncol, $nrow, $nsecs, $pixtype, $mxst, $myst, $mzst, $mx, $my, $mz,
  $dx,$dy,$dz,$alpha,$beta,$gamma,$colax,$rowax,$secax,$min,$max,$mean,
  $nspg, $next, $dvid, $nblank, $ntst, $blank, $numints, $numfloats, $sub,
  $zfac, $min2, $max2, $min3, $max3, $min4, $max4, $imtype, $lensnum,
  $n1, $n2, $v1, $v2, $min5, $max5, $ntimes, $imgseq, $xtilt, $ytilt, $ztilt,
  $nwaves, $wv1, $wv2, $wv3, $wv4, $wv5, $z0, $x0, $y0, $ntitles,
  $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10) = unpack (
  "l>l>l>l>l>l>l>l>l>l>f>f>f>f>f>f>l>l>l>f>f>f>l>l>s>s>l>A24s>s>s>s>f>f>f>f>f>f>s>s>s>s>s>s>f>f>s>s>f>f>f>s>s>s>s>s>s>f>f>f>l>A80A80A80A80A80A80A80A80A80A80",$hdr);

if($pixtype >=0 && $pixtype<7) {$endi="ieee-be";}

else {
#    print ("trying little-endian...");
($ncol, $nrow, $nsecs, $pixtype, $mxst, $myst, $mzst, $mx, $my, $mz,
  $dx,$dy,$dz,$alpha,$beta,$gamma,$colax,$rowax,$secax,$min,$max,$mean,
  $nspg, $next, $dvid, $nblank, $ntst, $blank, $numints, $numfloats, $sub,
  $zfac, $min2, $max2, $min3, $max3, $min4, $max4, $imtype, $lensnum,
  $n1, $n2, $v1, $v2, $min5, $max5, $ntimes, $imgseq, $xtilt, $ytilt, $ztilt,
  $nwaves, $wv1, $wv2, $wv3, $wv4, $wv5, $z0, $x0, $y0, $ntitles,
  $t1, $t2, $t3, $t4, $t5, $t6, $t7, $t8, $t9, $t10) = unpack (
  "l<l<l<l<l<l<l<l<l<l<f<f<f<f<f<f<l<l<l<f<f<f<l<l<s<s<l<A24s<s<s<s<f<f<f<f<f<f<s<s<s<s<s<s<f<f<s<s<f<f<f<s<s<s<s<s<s<f<f<f<l<A80A80A80A80A80A80A80A80A80A80",$hdr);
if($pixtype >=0 && $pixtype<7) {$endi="ieee-le";}
else {die ("failed: pixtype is $pixtype, and endian is $endi")};
}

#print "Read success: pixtype is $dtypes[$pixtype], endian is $endi\n";
print "nwaves dx:\n";
print "$nwaves $dx\n";
