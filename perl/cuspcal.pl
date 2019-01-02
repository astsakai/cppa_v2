#!/usr/local/bin/perl
#ハウスカスプ計算ルーチン
#(c) 1999-2001, 2004 Yoshihiro Sakai & Sakai Institute of Astrology

#House Cusp Calculating subroutine
sub CalHouseCusp{
	my($ye, $mo, $da, $ho, $mi, $pid) = @_;
	my($lo, $la) = &FindPlaceCoor($pid);
	my(@cusp) = CalHouseCusp2($ye, $mo, $da, $ho, $mi, $lo, $la, 1);
	@cusp;
}

sub CalHouseCusp2{
	my($ye, $mo, $da, $ho, $mi, $Lon, $Lat, $htype) = @_;
	my(@cusp);
	my($JD) = &CalJD($ye, $mo, $da, $ho, $mi);
	my($lst) = &CalLST($JD, $ho, $mi, $Lon);
	my($obl)  = &CalOblique($JD);
#Ordinary Version
	@cusp = &CalHousePlacidus($lst, $Lat, $obl) if($htype == 1);
	@cusp = &CalHouseCampanus($lst, $Lat, $obl) if($htype == 2);
	@cusp = &CalHouseRegiomontanus($lst, $Lat, $obl) if($htype == 3);
	@cusp = &CalHouseKoch($lst, $Lat, $obl) if($htype == 4);
	@cusp = &CalHouseTopocentric($lst, $Lat, $obl) if($htype == 5);
	@cusp = &CalHouseAxial($lst, $Lat, $obl) if($htype == 6);
	@cusp = &CalHouseMorinus($lst, $Lat, $obl) if($htype == 7);
#Another Version
	@cusp = &CalHousePlacidus2($lst, $Lat, $obl) if($htype == 11);
	@cusp = &CalHouseCampanus2($lst, $Lat, $obl) if($htype == 12);
	@cusp = &CalHouseRegiomontanus2($lst, $Lat, $obl) if($htype == 13);
	@cusp = &CalHouseKoch2($lst, $Lat, $obl) if($htype == 14);
	@cusp;
}

#for Koch & Topocentric House System
sub CalAsc{
	my($lst, $lat, $obl) = @_;
	#ASC計算
	my($ASCx) = &cos4deg($lst);
	my($ASCy) = -(&sin4deg($obl) * &tan4deg($lat));
	$ASCy    -= &cos4deg($obl) * &sin4deg($lst);
	my($ASC) = &mod360(atan2($ASCx, $ASCy) / $Deg2Rad);
	$ASC += 360.0 if($ASC < 0.0);

	$ASC;
}

####################
#Placidus House System
sub CalHousePlacidus{
	my($LST, $Lat, $obl) = @_;

	#Initial Setting...
	my($H)    = 0.0;
	my($F)    = 0.0;
	my($P0)   = 0.0;
	my($P1)   = 0.0;
	my($X0)   = 0.0;
	my($X1)   = 0.0;
	my($d)    = 0.0;
	my($d0)   = 1.0e-03;
	my($csp)  = 0.0;
	my($cspx) = 0.0;
	my($cspy) = 0.0;
	my(@cusp);
	(my($ASC), my($MC)) = &CalGeoPoint($LST, $Lat, $obl);

	#Calculating Cusps...
	foreach $i (1..12){
		if($i % 3 == 1){
			$cusp[$i] = &mod360((($i % 6 == 1) ? $ASC : $MC) +
									(($i > 2) && ($i < 8) ? 180.0 : 0.0));
		} else {
			$nh = $i;
			if(($i > 4) && ($i < 10)){
				$nh = ($nh + 6) % 12;
				$nh = 12 if($nh == 0);
			}
			$H = &mod360(($nh + 2) * 30.0);
			$F = ($nh % 2 == 1) ? (3.0) : (1.5);
			$X0 = $LST + $H;
			do{
				$P0  = &sin4deg($X0) * &tan4deg($obl) * &tan4deg($Lat);
				$P0 *= (($nh > 7) ? (-1.0) : (+1.0));
				$P1  = (($nh > 7) ? (+1.0) : (-1.0)) * &acos4deg($P0);
				$X1  = $LST + $P1 / $F + (($nh > 7) ? (0.0) : (180.0));
				$d   = abs($X0 - $X1);
				$X0  = $X1;
			} while($d > $d0);
			$cspx = &sin4deg($X1);
			$cspy = &cos4deg($obl) * &cos4deg($X1);
			$csp  = &atan24deg($cspx, $cspy);
			$csp += (($i > 4) && ($i < 10)) ? (180.0) : (0.0);
			$cusp[$i] = &mod360($csp);
		}
	}

	@cusp;
}

#Campanus House Cusp
sub CalHouseCampanus{
	my($Lst, $Lat, $obl) = @_;
	my($C, $Cx, $D, $H, $csp, $cspx, $cspy, $nh, @cusp);
	(my($ASC), my($MC)) = &CalGeoPoint($Lst, $Lat, $obl);

	#Calculating Cusps...
	foreach $i (1..12){
		if($i % 3 == 1){
			$cusp[$i] = &mod360((($i % 6 == 1) ? $ASC : $MC) +
									(($i > 2) && ($i < 8) ? 180.0 : 0.0));
		} else {
			$nh = $i;
			if(($i > 4) && ($i < 10)){
				$nh = ($nh + 6) % 12;
				$nh = 12 if($nh == 0);
			}
			$H  = &mod360(($nh + 2) * 30.0);
			$D  = &cos4deg($H) / (&sin4deg($H) * &cos4deg($Lat));
			$D  = $Lst + 90.0 - &atan4deg($D);
			$Cx = &tan4deg(&asin4deg(&sin4deg($Lat) * &sin4deg($H)));
			$C  = &atan24deg($Cx, &cos4deg($D));
			$cspx = &tan4deg($D) * &cos4deg($C);
			$cspy = &cos4deg($C + $obl);
			$csp  = &atan24deg($cspx, $cspy);
			$csp += ($nh != $i) ? (180.0) : (0.0);
			$cusp[$i] = &mod360($csp);
		}
	}

	@cusp;
}

#Regiomontanus House Cusp
sub CalHouseRegiomontanus{
	my($Lst, $Lat, $obl) = @_;
	my($R, $Rx, $Ry, $H, $csp, $cspx, $cspy, $nh, @cusp);
	(my($ASC), my($MC)) = &CalGeoPoint($Lst, $Lat, $obl);

	#Calculating Cusps...
	foreach $i (1..12){
		if($i % 3 == 1){
			$cusp[$i] = &mod360((($i % 6 == 1) ? $ASC : $MC) +
									(($i > 2) && ($i < 8) ? 180.0 : 0.0));
		} else {
			$nh = $i;
			if(($i > 4) && ($i < 10)){
				$nh = ($nh + 6) % 12;
				$nh = 12 if($nh == 0);
			}
			$H  = &mod360(($nh + 2) * 30.0);
			$Rx = &sin4deg($H) * &tan4deg($Lat);
			$Ry = &cos4deg($Lst + $H);
			$R  = &atan24deg($Rx, $Ry);
			$cspx = &cos4deg($R) * &tan4deg($Lst + $H);
			$cspy = &cos4deg($R + $obl);
			$csp  = &atan24deg($cspx, $cspy);
			$csp += ($nh != $i) ? (180.0) : (0.0);
			$cusp[$i] = &mod360($csp);
		}
	}

	@cusp;
}

#Koch House System
sub CalHouseKoch{
	my($Lst, $Lat, $obl) = @_;
	my($K, $dlst, $csp, $nh, @cusp);
	(my($ASC), my($MC)) = &CalGeoPoint($Lst, $Lat, $obl);

	#Calculating Cusps...
	foreach $i (1..12){
		if($i % 3 == 1){
			$cusp[$i] = &mod360((($i % 6 == 1) ? $ASC : $MC) +
									(($i > 2) && ($i < 8) ? 180.0 : 0.0));
		} else {
			$nh = $i;
			if(($i > 4) && ($i < 10)){
				$nh = ($nh + 6) % 12;
				$nh = 12 if($nh == 0);
			}
			$K = &asin4deg(&sin4deg($MC) * &sin4deg($obl));
			$K = &asin4deg(&tan4deg($Lat) * &tan4deg($K));
			$dlst  = 30.0 + $K / 3.0;
			$dlst *=  2.0 if($nh == 11 || $nh == 3);
			$dlst *= -1.0 if($nh > 7);
			$cusp[$i]  = &CalAsc($Lst + $dlst, $Lat, $obl);
			$cusp[$i] += 180 if(($i > 4) && ($i < 10));
		}
	}

	@cusp;
}

#Topocentric House System
sub CalHouseTopocentric{
	my($Lst, $Lat, $obl) = @_;
	my($dlst, $lat1, $csp, $nh, @cusp);
	(my($ASC), my($MC)) = &CalGeoPoint($Lst, $Lat, $obl);

	#Calculating Cusps...
	foreach $i (1..12){
		if($i % 3 == 1){
			$cusp[$i] = &mod360((($i % 6 == 1) ? $ASC : $MC) +
									(($i > 2) && ($i < 8) ? 180.0 : 0.0));
		} else {
			$nh = $i;
			if(($i > 4) && ($i < 10)){
				$nh = ($nh + 6) % 12;
				$nh = 12 if($nh == 0);
			}
			$dlst  = &mod360(($nh + 2) * 30.0) - 90.0;
			$lat1  = &tan4deg($Lat) / 3.0;
			$lat1 *= 2.0 if($nh == 12 || $nh == 2);
			$lat1  = &atan4deg($lat1);
			$cusp[$i]  = &CalAsc($Lst + $dlst, $lat1, $obl);
			$cusp[$i] += 180 if(($i > 4) && ($i < 10));
		}
	}

	@cusp;
}

#Axial Rotation System
sub CalHouseAxial{
	my($Lst, $Lat, $obl) = @_;
	my($alpha, $cspx, $cspy, @cusp);

	for($i = 10;$i < 16;$i++){
		$house = (($i > 12) ? $i - 12 : $i);
		$alpha = $Lst + 60.0 + 30.0 * $house;
		$cspx  = &cos4deg($alpha) * &cos4deg($obl);
		$cspy  = &sin4deg($alpha);
		$cusp[$house] = &atan24deg($cspy, $cspx);
	}
	for($i = 4;$i < 10;$i++){
		my($oh) = $i + 6;
		if($oh > 12){
			$oh -= 12;
		}
		$cusp[$i] = &mod360($cusp[$oh] + 180.0);
	}
	@cusp;
}

#Morinus House System
sub CalHouseMorinus{
	my($Lst, $Lat, $obl) = @_;
	my($Z, $cspx, $cspy, @cusp);

	for($i = 1;$i <= 12;$i++){
		$Z = &mod360($Lst + 60.0 + 30.0 * $i);
		$cspx = &cos4deg($Z);
		$cspy = &sin4deg($Z) * &cos4deg($obl);
		$cusp[$i] = &atan24deg($cspy, $cspx);
	}
	@cusp;
}

####################
#Another Placidus System
sub CalHousePlacidus2{
	my($Lst, $Lat, $obl) = @_;
	my($S, $C, $i, $n, $k, $h, $alpha, $q, $dq, $F0, $F1, $cspx, $cspy, @cusp);

	$S = &sin4deg($Lat) * &tan4deg($obl);
	$C = &cos4deg($Lat);
	for($i = 10;$i < 16;$i++){
		$h = (($i <= 12) ? $i : $i - 12);
		$n = $h + (($h < 7) ? 6 : 0);
		$k = ($n - 10) / 3.0;
		$alpha = &mod360($Lst + 60.0 + $n * 30.0);
		$q = 90.0;
		do{
			$F0     =  $C * &cos4deg($q) +      $S * &sin4deg($alpha);
			$F1     = -$C * &sin4deg($q) + $k * $S * &cos4deg($alpha);
			$dq     = (-$F0 / $F1) * (180.0 / $PI);
			$q     += $dq;
			$alpha += $k * $dq;
		} while(abs($F0) > 1.0e-05);
		$cspx = &cos4deg($alpha) * &cos4deg($obl);
		$cspy = &sin4deg($alpha);
		$cusp[$h] = &mod360(&atan24deg($cspy, $cspx) + (($h < 7) ? 180.0 : 0.0));
	}
	for($i = 4;$i < 10;$i++){
		my($oh) = $i + 6;
		if($oh > 12){
			$oh -= 12;
		}
		$cusp[$i] = &mod360($cusp[$oh] + 180.0);
	}
	@cusp;
}

#Another Campanus System - still exists critical bug...
sub CalHouseCampanus2{
	my($Lst, $Lat, $obl) = @_;
	my($Z, $P, $V, $cspx, $cspy, @cusp);
	open(Log, ">camp.log");

	for($i = 1;$i <= 12;$i++){
		$Z = &mod360(60.0 + 30.0 * $i);
		$P = &atan24deg(&sin4deg($Z) * &cos4deg($Lat), &cos4deg($Z));
		$V = &sin4deg($P) * &sin4deg($Lat) * &sin4deg($obl);
		print Log "house $i : Z = $Z P = $P V = $V\n";
		$cspx = &cos4deg($Lst + $Z) * &cos4deg($Lat) * &cos4deg($obl) - $V;
		$cspy = &sin4deg($Lst + $Z);
		$cusp[$i] = &atan24deg($cspy, $cspx);
	}
	close(Log);
	@cusp;
}

#Another Koch System
sub CalHouseKoch2{
	my($Lst, $Lat, $obl) = @_;
	my($Z, $B, $G, $K, $H, $cspx, $cspy, @cusp);

	$Z = &asin4deg(&sin4deg($Lst) * &tan4deg($Lat) * &tan4deg($obl));
	for($i = 1;$i <= 12;$i++){
		$B = &mod360(60.0 + 30.0 * $i);
		$G = $B / 90.0 - (1.0 + (($B < 180.0) ? 0.0 : 2.0));
		$K = ($B < 180.0) ? +1 : -1;
		$H = $Lst + $B + $Z * $G;
		$cspx = &cos4deg($H) * &cos4deg($obl) - $K * &tan4deg($Lat) * &sin4deg($obl);
		$cspy = &sin4deg($H);
		$cusp[$i] = &atan24deg($cspy, $cspx);
	}
	@cusp;
}

#Another Regiomontanus System
sub CalHouseRegiomontanus2{
	my($Lst, $Lat, $obl) = @_;
	my($n, $D, $V, $cspx, $cspy, @cusp);

	for($n = 1;$n <= 12;$n++){
		$D = 60.0 + 30.0 * $n;
		$V = &sin4deg($D) * &sin4deg($Lat) * &sin4deg($obl);
		$cspx = &cos4deg($Lst + $D) * &cos4deg($Lat) * &cos4deg($obl) - $V;
		$cspy = &sin4deg($Lst + $D) * &cos4deg($Lat);
		$cusp[$n] = &atan24deg($cspy, $cspx);
	}
	@cusp;
}

1;
