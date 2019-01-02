#!/usr/my/bin/perl
#定数定義／数学関数スクリプト version 0.021p at 2003/08/30
#(c) 1999-2001 Yoshihiro Sakai & Sakai Institute of Astrology

$PI = 3.141592653589793;
$Deg2Rad = $PI / 180.0;

sub sin4deg{
	my($X) = @_;
	my($sn) = sin($X * $Deg2Rad);
	$sn;
}

sub cos4deg{
	my($X) = @_;
	my($cs) = cos($X * $Deg2Rad);
	$cs;
}

sub tan4deg{
	my($X) = @_;
	my($tn) = 0.0;
	my($sn) = sin($X * $Deg2Rad);
	my($cs) = cos($X * $Deg2Rad);

	if(abs($cs) >= 1.0e-08){
		$tn = $sn / $cs;
	} else {
		$tn = 9.999999999999999e+99 * &sgn($sn);
	}
	$tn;
}

sub asin4deg{
	my($X) = @_;
	my($Xt) = 0.0;
	my($res) = 0.0;

	if(abs($X) < 1.0){
		$Xt  = $X / sqrt(1.0 - $X * $X);
		$res = &atan4deg($Xt);
	} else {
		$res = ($X > 0) ? 90.0 : 270.0;
	}

	$res;
}

sub acos4deg{
	my($X) = @_;
	my($Xt) = 0.0;
	my($res) = 0.0;

	if(abs($X) < 1.0){
		$Xt  = $X / sqrt(1.0 - $X * $X);
		$res = 90.0 - &atan4deg($Xt);
	} else {
		$res = ($X > 0) ? 0.0 : 180.0;
	}

	$res;
}

sub atan4deg{
	my($y, $xr, $xd) = @_;
	$xr = atan2($y, 1.0); #ごまかしてます(^^;
	$xd = $xr / $Deg2Rad;
	$xd;
}

sub atan24deg{
	my($y, $x) = @_;
	my($xr, $xd);
	if(abs($x) < 1.0e-13){
		$xd = (($y > 0) ? 90.0 : 270.0);
	} elsif(abs($y) < 1.0e-13) {
		$xd = (($x > 0) ?  0.0 : 180.0);
	} else {
		$xr = atan2($y, $x);
		$xd = $xr / $Deg2Rad;
		$xd = &mod360($xd);
	}
	$xd;
}

sub sgn{
	my($X) = @_;
	my($sgn) = ($X > 0) - ($X < 0);
	$sgn;
}

sub fmod{
	my($X, $t) = @_;
	my($res) = 0.0;
	$res  = $X - int($X / $t) * $t;
	$res += $t if($res < 0.0);
	$res;
}

sub mod360{
	my($X) = @_;
	my($res) = $X - &floor($X / 360.0) * 360.0;
	$res;
}

sub floor{
	my($x) = @_;
	my($res) = int($x);
	$res-- if($x < 0 && $x != $res);
	$res;
}

sub ceil{
	my($x) = @_;
	my($res) = int($x);
	$res++ if($x > 0 && $x != $res);
	$res;
}

1;
