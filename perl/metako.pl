#!/usr/my/bin/perl
#�萯�p�v�Z�G���W���u�߂����v version 0.20 at 2004/01/11
#(c) 1999-2001, 2003, 2004 Yoshihiro Sakai & Sakai Institute of Astrology
require 'math.pl';

@planame = ("",
    "���z", "��",   "����",   "����",   "�ΐ�",
    "�ؐ�", "�y��", "�V����", "�C����", "������",
	"�m�[�h", "�����X", "�㏸�_", "�쒆�_",
	"�Z���X", "�p���X", "�W���m�[", "�x�X�^", "�L���[��",
	"�L���[�s�b�h", "�n�f�X", "�[�E�X", "�N���m�X",
	"�A�|����", "�A�h���g�X", "�o���J�k�X", "�|�Z�C�h��");
@planame6 = ("",
    "���z�@", "���@�@", "�����@", "�����@", "�ΐ��@",
    "�ؐ��@", "�y���@", "�V����", "�C����", "������",
	"�m�[�h", "�����X", "�㏸�_", "�쒆�_",
	"�Z���X", "�p���X", "�W���m", "�x�X�^", "�L����",
	"�N�s�h", "�n�f�X", "�[�E�X", "�N���m",
	"�A�|��", "�A�h��", "�o���J", "�|�Z�C");
@sgnname = (
    "���r��", "������", "�o�q��", "�I�@��", "���q��", "������",
    "�V����", "嶁@��", "�ˎ��", "�R�r��", "���r��", "���@��");
@sgnS = ("�r", "��", "�o", "�I", "��", "��", "��", "�", "��", "�R", "�r", "��");

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

#���p�v�Z�i�A�X�y�N�g�^�C�v�j
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

#�p�x�����A�X�y�N�g�ϊ�
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

#�O�H�@���H
sub ChkPos{
	my($to, $from) = @_;

	my($diff) = $to - $from;
	$diff -= 360.0 if($diff >= +180.0);
	$diff += 360.0 if($diff <= -180.0);

	$diff;
}

#�t�s���H
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

#��Γx�����T�C���ϊ�
sub CnvSign{
	my($adeg) = @_;

	$adeg = &mod360($adeg);
	my($sgn) = int($adeg / 30.0);

	$sgn;
}

#��Γx�����T�C��������ϊ�
sub cnv2kanji{
    my($adeg) = @_;
	my($str);

	if($adeg >= 0.0){
		$adeg = &mod360($adeg);
		my($sgn) = int($adeg / 30.0);
		my($deg) = sprintf("%2d", int($adeg - $sgn * 30.0));
		my($min) = sprintf("%02d", int(($adeg - ($sgn * 30 + $deg)) * 60.0));
		   $str  = $sgnname[$sgn] . $deg . "�x" . $min . "��";
	} else {
		   $str  = "������";
	}

    $str;
}

#��Γx�����T�C��������ϊ�
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
		   $str  = "������";
	}

    $str;
}

#�V�̂h�c���L��
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

#��Γx�����T�C���L����ϊ�
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
		   $str  = "������";
	}

    $str;
}

#��Γx�����A�X�y�N�g�L����ϊ�
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
		$str = "�@�@�@";
	}

    $str;
}

1;
