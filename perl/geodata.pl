#!/usr/local/bin/perl
#経緯度データファイル。それだけ。
#(c) 1999-2001 Yoshihiro Sakai & Sakai Institute of Astrology


$[ = 0;
sub FindPlaceCoor{
	my($pid) = @_;
	$pid = 48 if(($pid < 1) || ($pid > 47));
#このデータは、都道府県庁舎の経緯度を適当に変換したものです。
	my(@lontbl) = (0.0,
		141.70, 140.74, 141.15, 140.87, 140.10, 140.37,
		140.47, 140.48, 139.88, 139.05, 139.65, 140.12,
		139.69, 139.64, 139.02, 137.21, 136.66, 136.21,
		138.58, 138.18, 136.72, 138.38, 136.91, 136.51,
		135.86, 135.75, 135.52, 135.19, 135.83, 135.17,
		134.24, 133.05, 133.93, 132.45, 131.47, 134.56,
		134.04, 132.77, 133.53, 130.42, 130.30, 129.82,
		130.73, 131.61, 131.42, 130.55, 127.67,   0.00);

	my(@lattbl) = (0.0,
		43.05, 40.82, 39.70, 38.26, 39.71, 38.23,
		37.74, 36.37, 36.56, 36.39, 35.85, 35.60,
		35.68, 35.43, 37.89, 36.68, 36.56, 36.06,
		35.66, 36.64, 35.38, 34.97, 35.17, 34.72,
		35.00, 35.02, 34.67, 34.68, 34.68, 34.22,
		35.50, 35.48, 34.65, 34.38, 34.17, 34.05,
		34.33, 33.87, 33.55, 33.61, 33.24, 32.74,
		32.78, 33.24, 31.91, 31.59, 26.21,  0.00);

	my(@coor) = ($lontbl[$pid], $lattbl[$pid]);
	@coor;
}

sub CnvPrefName{
	my($pid) = @_;
	$pid = 48 if(($pid < 1) || ($pid > 47));

	my(@npref) = ("",
		"北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県",
		"福島県", "茨城県", "栃木県", "群馬県", "埼玉県", "千葉県",
		"東京都", "神奈川県", "新潟県", "富山県", "石川県", "福井県",
		"山梨県", "長野県", "岐阜県", "静岡県", "愛知県", "三重県",
		"滋賀県", "京都府", "大阪府", "兵庫県", "奈良県", "和歌山県",
		"鳥取県", "島根県", "岡山県", "広島県", "山口県", "徳島県",
		"香川県", "愛媛県", "高知県", "福岡県", "佐賀県", "長崎県",
		"熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県", "その他・海外");

	my($pname) = $npref[$pid];
	$pname;
}

1;
