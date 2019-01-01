#!/usr/my/bin/perl
# 天文計算関係スクリプト version 0.18 at 2018/06/16
# (c) 1999-2001, 2004, 2005, 2018 Yoshihiro Sakai & Sakai Institute of Astrology
# 2017/09/15[0.17j] ΔＴの計算式を見直すついでに出典を書く
# 2017/10/08[0.18p] ケプラー方程式の逐次近似法見直し
require 'math.pl';

#グレゴリオ暦専用！
sub CnvCalendar{
	my($JD) = @_;

	$JD += 0.5;
	my($Z) = int($JD);
	my($F) = $JD - $Z;

	my($A) = 0;
	if($Z >= 2299161){
		my($alpha) = int(($Z - 1867216.25) / 36524.25);
		$A = $Z + 1 + $alpha - int($alpha / 4);
	} else {
		$A = $Z;
	}

	my($B) = $A + 1524;
	my($C) = int(($B - 122.1) / 365.25);
	my($D) = int(365.25 * $C);
	my($E) = int(($B - $D) / 30.6001);

	my($da) = $B - $D - int(30.6001 * $E);
	my($mo) = ($E < 13.5) ? ($E - 1) : ($E - 13);
	my($ye) = ($mo > 2.5) ? ($C - 4716) : ($C - 4715);

	my($ti) = $F * 24.0;
	my($ho) = int($ti);
	my($mi) = ($ti - $ho) * 60.0;
	@res = ($ye, $mo, $da, $ho, $mi);
	@res;
}

#その日のユリウス日を計算する
sub CalJD{ #実数体上
	my($ye, $mo, $da, $ho, $mi) = @_;

	my($y0) = ($mo > 2) ? $ye : ($ye -  1);
	my($m0) = ($mo > 2) ? $mo : ($mo + 12);
	my($JD) = int(365.25 * $y0) + int($y0 / 400) - int($y0 / 100);
	$JD	+= int(30.59 * ($m0 - 2)) + $da;
	$JD	+= (($ho - 9) * 60.0 + $mi) / 1440.0 + 1721088.5;

	$JD;
}

sub CnvJDr{ #実数体→整数環
	my($JD) = @_;
	my($ye, $mo, $da, $ho, $mi) = &CnvCalendar($JD);
	my($JDz) = &CalJDz($ye, $mo, $da);
	$JDz;
}

sub CalJDz{ #整数環上
	my($year, $month, $day) = @_;

	my($yt) = $year;
	my($mt) = $month;
	my($dt) = $day;
	if($month < 3){
		$yt--;
		$mt += 12;
	}

	my($JD)  = int(365.25 * $yt) + int(30.6001 * ($mt + 1));
	$JD += $dt + 1720995;
	$JD += 2 - int($yt / 100) + int($yt / 400);

	$JD;
}

#d, Tを配列で返す。
sub CalTimeCoefficient{
	my($JD) = @_;

	my($d) = $JD - 2451545.0;
	my($T) = $d / 36525.0;
	my(@Coef) = ($d, $T);

	@Coef;
}

#まとめて軌道計算。返値は（黄経、黄緯、動径）。
sub OrbitWork{
	my($L, $opi, $omg, $i, $e, $a) = @_;

	my($M) = &mod360($L - $opi);
	my($E) = &mod360(&SolveKepler($M, $e));
	my($sV) = sqrt(1.0 - $e * $e) * sin($E * $Deg2Rad) / (1.0 - $e * cos($E * $Deg2Rad));
	my($cV) = (cos($E * $Deg2Rad) - $e) / (1.0 - $e * cos($E * $Deg2Rad));
	my($V)  = atan2($sV, $cV) / $Deg2Rad;
	my($U) = &mod360($opi + $V - $omg);

	$r = $a * (1.0 - $e * cos($E * $Deg2Rad));
	$l = &mod360($opi + $V);
	$b = &asin4deg(sin($i * $Deg2Rad) * sin($U * $Deg2Rad));

	my(@res) = ($l, $b, $r);

	@res;
}

#Kepler方程式(M = E - e sinE)を解く。
sub SolveKepler{
	my($M, $e) = @_;

	my($Mr) = $M * $Deg2Rad;
	my($Er) = $Mr;
	my($dE) = 0.0;

	do{
		$dE = ($Mr - $Er + $e * sin($Er)) / (1.0 - $e * cos($Er));
		$Er = $Er + $dE;
	} while(abs($dE) > 1.0e-08);

	my($E) = $Er / $Deg2Rad;

	$E;
}

#日心位置から地心位置へコンバートし、地心黄経を返す。
sub Cnv2Geocentric{
	my($lp, $bp, $rp, $ls, $bs, $rs) = @_;

	my($xp) = $rp * cos($lp * $Deg2Rad) * cos($bp * $Deg2Rad);
	my($yp) = $rp * sin($lp * $Deg2Rad) * cos($bp * $Deg2Rad);
	my($zp) = $rp *                       sin($bp * $Deg2Rad);
	my($xs) = $rs * cos($ls * $Deg2Rad) * cos($bs * $Deg2Rad);
	my($ys) = $rs * sin($ls * $Deg2Rad) * cos($bs * $Deg2Rad);
	my($zs) = $rs *                       sin($bs * $Deg2Rad);

	my($xg) = $xp + $xs;
	my($yg) = $yp + $ys;
	my($zg) = $zp + $zs;

	my($rg) = sqrt($xg * $xg + $yg * $yg + $zg * $zg);
	my($lg) = atan2($yg, $xg) / $Deg2Rad;
	$lg += 360.0 if($lg < 0.0);
	my($bg) = &asin4deg($zg / $rg);

	($lg, $bg, $rg);
}

#黄道座標系から赤道座標系へ変換する。
sub Cnv2Equatorial{
	my($lon, $lat, $obl) = @_;
	my($xs) = &cos4deg($lon) * &cos4deg($lat);
	my($ys) = &sin4deg($lon) * &cos4deg($lat);
	my($zs) =                  &sin4deg($lat);

	my($xd) = $xs;
	my($yd) = $ys * &cos4deg($obl) - $zs * &sin4deg($obl);
	my($zd) = $ys * &sin4deg($obl) + $zs * &cos4deg($obl);

	my($RA) = atan2($yd, $xd) / $Deg2Rad;
	$RA += 360.0 if($RA < 0.0);
	my($Dec) = &asin4deg($zd);

	($RA, $Dec);
}

#歳差補正
sub CoorCnvfromJ2000{
	my(@arg) = @_;
	my($T, $zeta, $zz, $theta);
	my($x, $y, $z, $xd, $yd, $zd, $xs, $ys, $zs);

	($xs, $ys, $zs, $tjd) = @arg;
	$T = ($tjd - 2451545.0) / 36525.0;

	$zeta  = ((( 0.017998 * $T + 0.30188) * $T + 2306.2181) * $T) / 3600.0;
	$zz    = ((( 0.018203 * $T + 1.09468) * $T + 2306.2181) * $T) / 3600.0;
	$theta = (((-0.041833 * $T - 0.42665) * $T + 2004.3109) * $T) / 3600.0;

#Step 1
	$x =  &sin4deg($zeta) * $xs + &cos4deg($zeta) * $ys;
	$y = -&cos4deg($zeta) * $xs + &sin4deg($zeta) * $ys;
	$z = $zs;

#Step 2;
#	$x = $x;
	$y = 0 * $x + &cos4deg($theta) * $y + &sin4deg($theta) * $z;
	$z = 0 * $x - &sin4deg($theta) * $y + &cos4deg($theta) * $z;

#Step 3
	$xd = -&sin4deg($zz) * $x - &cos4deg($zz) * $y;
	$yd =  &cos4deg($zz) * $x - &sin4deg($zz) * $y;
	$zd = $z;

	($xd, $yd, $zd);
}

#地方恒星時計算
sub CalLST{
	my($JD, $ho, $mi, $lo) = @_;
	my($JD0) = int($JD - 0.5) + 0.5;
	my($T) = ($JD0 - 2451545.0) / 36525.0;
	my($UT) = ($JD - $JD0) * 360.0 * 1.002737909350795;
	$UT += 360.0 if($UT < 0);

	#グリニッジ恒星時計算
	my($GST) = 0.279057273 + 100.0021390378 * $T + 1.077591667e-06 * $T * $T;
	   $GST  = $GST - int($GST);
	   $GST *= 360.0;

	#地方恒星時計算＋章動補正
	my($LST) = &mod360($GST + $UT + $lo);
	my($dpsi) = &CalNutation($JD);
	my($eps)  = &CalOblique($JD);
	$LST += $dpsi * &cos4deg($eps) / 3600.0;
	$LST += 360.0 if($LST < 0.0);

	$LST;
}

#黄道傾斜角を計算する関数
sub CalOblique{
	my($JD) = @_;
	my($T) = ($JD - 2451545.0) / 36525.0;
	my($Omg) = &mod360(125.00452 - $T *   1934.136261);
	my($Ls)  = &mod360(280.4665  + $T *  36000.7698);
	my($Lm)  = &mod360(218.3165  + $T * 481267.8813);

	my($e) = 84381.448 + $T * (-46.8150 + $T * (-0.00059 + $T * 0.001813));
	my($deps)  =  9.20 * &cos4deg(1.0 * $Omg);
	   $deps  +=  0.57 * &cos4deg(2.0 * $Ls);
	   $deps  +=  0.10 * &cos4deg(2.0 * $Lm);
	   $deps  += -0.09 * &cos4deg(2.0 * $Omg);

	($e + $deps) / 3600.0;
}

#章動を計算する関数（簡略版）
sub CalNutation{
	my($JD) = @_;
	my($T) = ($JD - 2451545.0) / 36525.0;

	my($Omg) = &mod360(125.00452 - $T *   1934.136261);
	my($Ls)  = &mod360(280.4665  + $T *  36000.7698);
	my($Lm)  = &mod360(218.3165  + $T * 481267.8813);

	my($dpsi)  = -17.20 * &sin4deg(1.0 * $Omg);
	   $dpsi  +=  -1.32 * &sin4deg(2.0 * $Ls);
	   $dpsi  +=  -0.23 * &sin4deg(2.0 * $Lm);
	   $dpsi  +=   0.21 * &sin4deg(2.0 * $Omg);

	$dpsi;
}

# 均時差を計算する関数
sub calEqT{
	my( $JD ) = @_;
	my( $T ) = ( $JD - 2451545.0 ) / 36525.0;

	my( $L0 ) = &mod360( 36000.76983 * $T );
		$L0   = &mod360( 280.46646 + $L0 + 0.0003032 * $T * $T );
		$L0  *= $Deg2Rad;

	my( $M  ) = &mod360( 35999.05029 * $T );
		$M    = &mod360( 357.52911 + $M  - 0.0001537 * $T * $T );
		$M   *= $Deg2Rad;

	my( $e  ) = 0.016708634 + $T * ( -0.000042037 - 0.0000001267 * $T );

	my( $y  ) = CalOblique( $JD );
		$y    = tan4deg( $y / 2.0 );
		$y    = $y * $y;

	my( $E  ) = $y * sin( 2 * $L0 ) - 2.0 * $e * sin( $M );
		$E   += 4.0 * $e * $y * sin( $M ) * cos( 2.0 * $L0 );
		$E   -= $y * $y * sin( 4.0 * $L0 ) / 2.0;
		$E   -= 5.0 * $e * $e * sin( 2.0 * $M ) / 4.0;

	$E /= $Deg2Rad;
	return ( $E * 4.0 );
}

##############################
#カレンダー関係。
sub CalDayOfWeek{
	my($year, $month, $day) = @_;

	my($JD)  = &CalJDz($year, $month, $day);
	my($you) = ($JD + 1) % 7;
	$you;
}

sub chk_leap{
	my($year) = @_;
	my($chk) = 0;

	$chk = 1 if($year %   4 == 0);
	$chk = 0 if($year % 100 == 0);
	$chk = 1 if($year % 400 == 0);

	$chk;
}

sub maxday{
	my($year, $month) = @_;
	@mday = (31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	$md = $mday[$month] + (($month == 2) ? &chk_leap($year) : 0);

	$md;
}

# ΔＴを管理する関数
# formula A : Notes Scientifiques et Techniques du Bureau des Longitudes, nr. S055
# from ftp://cyrano-se.obspm.fr/pub/6_documents/4_lunar_tables/newexp.pdf
# formula B : Polynomial Expressions for Delta T (ΔT)
# from https://eclipse.gsfc.nasa.gov/SEhelp/deltatpoly2004.html
# formula C : Delta T : Polynomial Approximation of Time Period 1620-2013
# from https://www.hindawi.com/archive/2014/480964/ (license: CC-BY-3.0)
sub CorrectTDT{
	my( $JD ) = @_;
	my $year = ( $JD - 2451545.0 ) / 365.2425 + 2000.0;
	my $t, $dt;

	if( $year < 948 ){ # formula A.26
		$t = ( $JD - 2451545.0 ) / 36525.0;
		$dt = 2177.0 + $t * ( 497.0 + $t * 44.1 );
	} elsif( $year < 1600 ){ # formula A.25
		$t = ( $JD - 2451545.0 ) / 36525.0;
		$dt =  102.0 + $t * ( 102.0 + $t * 25.3 );
	} elsif( $year < 1620 ){ # formula B
		$t = year - 1600;
		$dt = 120 + $t * ( -0.9808 + $t * ( -0.01532 + $t / 7129 ) );
	} elsif( $year < 2014 ){ # formula C
		# last elements are sentinels.
		my @tep = (     1620,     1673,     1730,      1798,      1844,     1878,      1905,      1946,      1990,  2014 );
		my @tk  = (    3.670,    3.120,    2.495,     1.925,     1.525,    1.220,     0.880,     0.455,     0.115, 0.000 );
		my @ta0 = (   76.541,   10.872,   13.480,    12.584,     6.364,   -5.058,    13.392,    30.782,    55.281, 0.000 );
		my @ta1 = ( -253.532,  -40.744,   13.075,     1.929,    11.004,   -1.701,   128.592,    34.348,    91.248, 0.000 );
		my @ta2 = (  695.901,  236.890,    8.635,    60.896,   407.776,  -46.403,  -279.165,    46.452,    87.202, 0.000 );
		my @ta3 = (-1256.982, -351.537,   -3.307, -1432.216, -4168.394, -866.171, -1282.050,  1295.550, -3092.565, 0.000 );
		my @ta4 = (  627.152,   36.612, -128.294,  3129.071,  7561.686, 5917.585,  4039.490, -3210.913,  8255.422, 0.000 );

		my $i = 0;
		for( my $j = 0; $j < scalar( @tep ); $j++ ){
			if( $tep[ $j ] <= $year && $year < $tep[ $j + 1 ] ){
				$i = $j;
				last;
			}
		}
		my $k  = $tk[ $i ];
		my $a0 = $ta0[ $i ];
		my $a1 = $ta1[ $i ];
		my $a2 = $ta2[ $i ];
		my $a3 = $ta3[ $i ];
		my $a4 = $ta4[ $i ];

		my $u = $k + ( $year - 2000 ) / 100;
		$dt = $a0 + $u * ( $a1 + $u * ( $a2 + $u * ( $a3 + $u * $a4 ) ) );
	} else { # formula A.25
		$t = ( $JD - 2451545.0 ) / 36525.0;
		$dt =  102.0 + $t * ( 102.0 + $t * 25.3 );
		if( $year < 2100 ){
			$dt += 0.37 * ( $year - 2100 ); # from "Astronomical Algorithms" p.78
		}
	}

	$dt /= 86400.0;
	return $dt;
}

sub AdvanceDate{
	my($date, $step) = @_;
	&EncodeDate(&CnvCalendar(&CalJDz(&DecodeDate($date)) + $step));
}

sub CalDist{
	my($sy, $sm, $sd, $ey, $em, $ed) = @_;
	&CalJDz($ey, $em, $ed) - &CalJDz($sy, $sm, $sd);
}

sub DecodeDate{
	my($date) = @_;
	my($ye) = int( $date / 10000 );
	my($mo) = int(($date % 10000) / 100);
	my($da) =	  $date %   100;
	($ye, $mo, $da);
}

sub DecodeTime{
	my($time) = @_;
	my($ho) = int($time / 100);
	my($mi) = fmod($time, 100);
	($ho, $mi)
}

sub EncodeDate{
	my($ye, $mo, $da) = @_;
	$ye * 10000 + $mo * 100 + $da;
}

sub EncodeTime{
	my($ho, $mi) = @_;
	$ho * 100 + $mi;
}

1;
