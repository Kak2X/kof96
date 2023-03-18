<?php

// Purpose: Convert sound header
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}

const DELIM = "L";
const DELIMN = 0;

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');

$bit_status = [
	0 => "SIS_PAUSE",
	1 => "SIS_SKIPNRx2",
	2 => "SIS_USEDBYSFX",
	3 => "SIS_SFX",
	4 => "SIS_UNK_4",
	5 => "SIS_UNK_5",
	6 => "SIS_UNUSED_6",
	7 => "SIS_ENABLED",
];
$sndptr_map = [
	'13' => "SND_CH1_PTR",
	'18' => "SND_CH2_PTR",
	'1D' => "SND_CH3_PTR",
	'22' => "SND_CH4_PTR",
];
$sndptrlbl_map = [
	'13' => ".ch1",
	'18' => ".ch2",
	'1D' => ".ch3",
	'22' => ".ch4",
];

for ($i = 0, $lines = file("tempconv.txt"); $i < count($lines);) {
	
	if (strpos($lines[$i], "SndHeader_") !== 0 || strpos($lines[$i], "SndHeader_01") === 0){
		++$i;
		continue;
	}
	
	$label = get_label($lines[$i]);
	$chcount = get_db($lines[$i]);
	
	$b = "
{$label}:
	db \${$chcount} ; Number of channels";
	

	++$i;
	for ($j = 0; $j < $chcount; $j++) {
		$status = get_db($lines[$i++]);
		$soundptr = get_db($lines[$i++]);
		$dataptr_low = get_db($lines[$i++]);
		$dataptr_high = get_db($lines[$i++]);
		$freqbase = get_db($lines[$i++]);
		$unused = get_db($lines[$i++]);
		
		$b .= "
".$sndptrlbl_map[$soundptr].":
	db ".generate_const_label($status, $bit_status)." ; Initial playback status
	db ".$sndptr_map[$soundptr]." ; Sound channel ptr
	dw L1F{$dataptr_high}{$dataptr_low} ; Data ptr
	db \${$freqbase} ; Base freq/note id
	db \${$unused} ; Unused";
	}
	
$b .= "
; END {$label} at ".get_label($lines[$i]);
	fwrite($h, $b);
}
fclose($h);