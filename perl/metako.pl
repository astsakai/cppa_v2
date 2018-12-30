#!/usr/my/bin/perl
#占星術計算エンジン「めたこ」 version 0.20 at 2004/01/11
#(c) 1999-2001, 2003, 2004 Yoshihiro Sakai & Sakai Institute of Astrology
require 'math.pl';

@planame = ("",
    "太陽", "月",   "水星",   "金星",   "火星",
    "木星", "土星", "天王星", "海王星", "冥王星",
	"ノード", "リリス", "上昇点", "南中点",
	"セレス", "パラス", "ジュノー", "ベスタ", "キローン",
	"キューピッド", "ハデス", "ゼウス", "クロノス",
	"アポロン", "アドメトス", "バルカヌス", "ポセイドン");
@planame6 = ("",
    "太陽　", "月　　", "水星　", "金星　", "火星　",
    "木星　", "土星　", "天王星", "海王星", "冥王星",
	"ノード", "リリス", "上昇点", "南中点",
	"セレス", "パラス", "ジュノ", "ベスタ", "キロン",
	"クピド", "ハデス", "ゼウス", "クロノ",
	"アポロ", "アドメ", "バルカ", "ポセイ");
@sgnname = (
    "牡羊座", "牡牛座", "双子座", "蟹　座", "獅子座", "乙女座",
    "天秤座", "蠍　座", "射手座", "山羊座", "水瓶座", "魚　座");
@sgnS = ("羊", "牛", "双", "蟹", "獅", "乙", "秤", "蠍", "射", "山", "瓶", "魚");

sub CnvPlanetHouse{
	my(@data) = @_;
	my(@pla) = ();
	my(@csp) = ();
	my(@hse) = ();
	for($i = 0;$i <= 14;$i++){
		$pla[$i] = $data[$i];
	}
	for($i = 1;$i <= 12;$i++){
		$csp[$i] = $data[$i + 15];
	}

	
	for($i = 1;$i < 14;$i++){
		$hse[$i] = &CnvPlanetHouse0($pla[$i], @csp);
	}

	@hse;
}

sub CnvPlanetHouse0{
	my($pos, @csp) = @_;
	my($cusp0) = 0.0;
	my($cusp1) = 0.0;
	my($ang0) = 0.0;
	my($ang1) = 0.0;
	my($hse);

	for($j = 1;$j <= 12;$j++){
		$cusp0 = $csp[$j];
		$cusp1 = $csp[$j % 12 + 1];
		$ang0  = &angle1($pos,   $cusp0);
		$ang1  = &angle1($cusp1, $cusp0);
		$hse = $j if((0 <= $ang0) && ($ang0 < $ang1));
	}

	$hse;
}

#----------------------------------

#離角計算（アスペクトタイプ）
sub angle{
    my($obj1, $obj2) = @_;

    my($dist) = $obj2 - $obj1;
    my($ang) = &acos4deg(&cos4deg($dist));

    $ang;
}

sub angle1{
	my($obj, $csp) = @_;
	my($ang) = $obj - $csp;
	if($ang >  180.0){
		$ang += -360.0;
	}
	if($ang < -180.0){
		$ang += +360.0;
	}

	$ang;
}

#角度差→アスペクト変換
sub ChkAspect{
	my($ang, $deforb) = @_;

#	my($asp) = $ang + $deforb;
#	my($asptype) = int($asp / 30.0);
#	my($orb) = $ang - $asptype * 30.0;

	my($asptype, $orb) = &ChkAspectStrictly($ang, $deforb, 0.0);

	my($type) = -1;
	$type =  0 if($asptype ==  0);
	$type =  1 if($asptype ==  4);
	$type =  2 if($asptype ==  6);
	$type =  1 if($asptype ==  7);
	$type =  2 if($asptype == 11);

	my(@result) = ($type, $orb);
	@result;
}

sub ChkAspectStrictly{
	my($asp, $orb1, $orb2) = @_;
	my($asp0, $orb0, $diff);
	my(@aspTable) = (0, 30, 36, 45, 60, 72, 90, 120, 135, 144, 150, 180);
	my(@orbTable) = (1, 2, 2, 2, 1, 2, 1, 1, 2, 2, 2, 1);
	my($res) = -1;
	my($i);

	for($i = 0;$i < 12;$i++){
		$asp0 = $aspTable[$i];
		$orb0 = (($orbTable[$i] == 1) ? $orb1 : $orb2);
		if($asp0 - $orb0 <= $asp && $asp <= $asp0 + $orb0){
			$res = $i;
			$diff = $asp - $asp0;
			last;
		}
	}
	($res, $diff);
}

#前？　後ろ？
sub ChkPos{
	my($to, $from) = @_;

	my($diff) = $to - $from;
	$diff -= 360.0 if($diff >= +180.0);
	$diff += 360.0 if($diff <= -180.0);

	$diff;
}

#逆行中？
sub ChkRetro{
	my($ye, $mo, $da, $ho, $mi) = @_;
	my(@pos0) = &CalPlanetPosition($ye, $mo, $da, $ho, $mi - 1, 48);
	my(@pos1) = &CalPlanetPosition($ye, $mo, $da, $ho, $mi + 1, 48);
	my(@ret)  = (0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
	my($vel) = 0.0;

	foreach $i (1 .. 10){
		$vel = ($pos1[$i] - $pos[$i]) * 720.0;
		$ret[$i] = -1 if($vel < 0.0);
	}

	@ret;
}

#絶対度数→サイン変換
sub CnvSign{
	my($adeg) = @_;

	$adeg = &mod360($adeg);
	my($sgn) = int($adeg / 30.0);

	$sgn;
}

#絶対度数→サイン文字列変換
sub cnv2kanji{
    my($adeg) = @_;
	my($str);

	if($adeg >= 0.0){
		$adeg = &mod360($adeg);
		my($sgn) = int($adeg / 30.0);
		my($deg) = sprintf("%2d", int($adeg - $sgn * 30.0));
		my($min) = sprintf("%02d", int(($adeg - ($sgn * 30 + $deg)) * 60.0));
		   $str  = $sgnname[$sgn] . $deg . "度" . $min . "分";
	} else {
		   $str  = "未発見";
	}

    $str;
}

#絶対度数→サイン文字列変換
sub cnv2knj{
    my($adeg) = @_;
	my($str);

	if($adeg >= 0.0){
		$adeg = &mod360($adeg);
		my($sgn) = int($adeg / 30.0);
		my($deg) = sprintf("%2d", int($adeg - $sgn * 30.0));
		my($min) = sprintf("%02d", int(($adeg - ($sgn * 30 + $deg)) * 60.0));
		   $str  = $deg . $sgnS[$sgn] . $min;
	} else {
		   $str  = "未発見";
	}

    $str;
}

#天体ＩＤ→記号
sub cnv2glyphP{
	my($pid) = @_;

	my($str, $gaddr1);
	my(@strPlanet) = ("As", "Mc");

	my($gadr0) = "<img src=\"";
#	if($ENV{REMOTE_ADDR} ne "127.0.0.1"){
#		$gadr1 = "http://homepage1.nifty.com/astsakai/image/astropict/planet/p";
		$gadr1 = "../image/astropict/planet/p";
#	} else {
#		$gadr1 = "http://localhost/image/astro/sign/xs";
#		$gadr1 = "http://localhost/image/astropict/planet/p";
#	}
	my($gadr2) = ".png\" alt=\"";
	my($gadr3) = "\">";

	if($pid <= 12){
		$str  = $gadr0 . $gadr1 . sprintf("%02d", $pid - 1) . $gadr2;
		$str .= $planame[$pid] . $gadr3;
	} else {
		$str  = $strPlanet[$pid - 13];
	}
	$str;
}

#絶対度数→サイン記号列変換
sub cnv2glyph{
    my($adeg) = @_;
	my($str, $gaddr1);
	my($gadr0) = "<img src=\"";
#	if($ENV{REMOTE_ADDR} ne "127.0.0.1"){
#		$gadr1 = "http://homepage1.nifty.com/astsakai/image/astropict/sign/s";
		$gadr1 = "../image/astropict/sign/s";
#	} else {
#		$gadr1 = "http://localhost/image/astro/sign/xs";
#		$gadr1 = "http://localhost/image/astropict/sign/s";
#	}
	my($gadr2) = ".png\" alt=\"";
	my($gadr3) = "\">";

	if($adeg >= 0.0){
		$adeg = &mod360($adeg);
		my($sgn) = int($adeg / 30.0);
		my($deg) = sprintf("%2d", int($adeg - $sgn * 30.0));
		my($min) = sprintf("%02d", int(($adeg - ($sgn * 30 + $deg)) * 60.0));
#		my($gadr) = $gadr0 . $gadr1 . sprintf("%02d", $sgn + 1) . $gadr2;
		my($gadr) = $gadr0 . $gadr1 . sprintf("%02d", $sgn) . $gadr2;
		   $gadr .= $sgnname[$sgn] . $gadr3;
		   $str  = $deg . $gadr . $min;
	} else {
		   $str  = "未発見";
	}

    $str;
}

#絶対度数→アスペクト記号列変換
sub asp2glyph{
    my($asp, $orb1, $orb2) = @_;
	my($str, $gadr1);
	my($gadr0) = "<img src=\"";
#	if($ENV{REMOTE_ADDR} ne "127.0.0.1"){
#		$gadr1 = "http://homepage1.nifty.com/astsakai/image/astropict/aspect/a";
		$gadr1 = "../image/astropict/aspect/a";
#	} else {
#		$gadr1 = "http://localhost/image/astro/aspect/xa";
#		$gadr1 = "http://localhost/image/astropict/aspect/a";
#	}
	my($gadr2) = ".png\" alt=\"";
	my($gadr3) = "\">";
	my(@aspTable) = (0, 30, 36, 45, 60, 72, 90, 120, 135, 144, 150, 180);

	my($res, $diff) = &ChkAspectStrictly($asp, $orb1, $orb2);
	if($res >= 0){
		my($deg0) = abs($diff);
		my($deg)  = int($deg0);
		my($min)  = int(($deg0 - $deg) * 60.0);
		$str  = $gadr0 . $gadr1 . sprintf("%03d", $aspTable[$res]) . $gadr2;
		$str .= $aspTable[$i] .  $gadr3;
		$str .= sprintf("%3d&deg;%02d\'", $deg, $min);
	} else {
		$str = "　　　";
	}

    $str;
}

1;
