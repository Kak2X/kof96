<?php

// Purpose: Create MoveAnimTbl_ structures
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');

$lines = file("tempconv.txt");
$spectbl = []; // Reference to char-specific special move name table
for ($i = 0; $i < count($lines);) {


	if (strpos($lines[$i], "MoveAnimTbl_") !== 0) {
		++$i;
		continue;
	}

	$base_label = get_label($lines[$i]);
	$spectbl = get_move_table($base_label)[1];
	$b = "\r\n{$base_label}:";
	for ($j = 0; $j < (0x9A / 2); $j++) {
		$unused_marker = strpos($lines[$i], ";X") !== false ? " ;X" : "";
		$bank = get_db($lines[$i++]);
		$obj_low = get_db($lines[$i++]);
		$obj_high = get_db($lines[$i++]);
		$target = get_db($lines[$i++]);
		$speed = get_db($lines[$i++]);
		$damage = get_db($lines[$i++]);
		$hitanimraw = get_db($lines[$i++]);
		if (!isset(HIT_ANIMS[hexdec($hitanimraw)])) {
			print "Warning: $hitanimraw\r\n";
			$hitanim = '$'.$hitanimraw;
		} else {
			$hitanim = HIT_ANIMS[hexdec($hitanimraw)];
		}
		$flags = generate_const_label(get_db($lines[$i++]), PLFLAGS3);
		$movedesc = " ; ".get_move_name_from_tbl($j, $spectbl);

		if (!$j) {
			$b .= "\r\n\tdb \${$bank}, \${$obj_low}, \${$obj_high}, \${$target}, \${$speed}, \${$damage}, {$hitanim}, {$flags}$unused_marker$movedesc";
		} else {
			$fullptr = "L{$bank}{$obj_high}{$obj_low}";
			// HACK HACK
			//if ($fullptr == "L094EAE")
			//	$fullptr = "OBJLstPtrTable_Terry_WinA";

			$b .= "\r\n\tmMvAnDef $fullptr, \${$target}, \${$speed}, \${$damage}, {$hitanim}, {$flags}$unused_marker ; BANK \${$bank}$movedesc";

		}

	}
	print "Last of set was ".get_label($lines[$i-1])."\r\n";
	fwrite($h, $b);
}
fclose($h);