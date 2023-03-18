<?php
	
// Purpose: Mass rename "dpr L******" structures inside OBJLstHdr*_*
require "lib/common.php";

$replacements = [];

print "\r\nScanning files...";
foreach (glob("src/*.asm") as $filename) {
	$basename = basename($filename);
    print "\r\n$basename...";
	$asmfile = file($filename);
	
	
	$hdrType = "";
	$charName = "";
	$moveName = "";
	foreach ($asmfile as $l) {
		$line = trim($l);
		
		/*
		if (str_starts_with($line, "OBJLstHdrA_") || str_starts_with($line, "OBJLstHdrB_")) {
			$label = get_label($line);
			$last = substr($label, -1, 1);
			if ($last == "A" || $last == "B") {	
				$replacements[$label] = substr($label, 0, strlen($label)-1)."_{$last}";
				print "\r\n".$replacements[$label];
			}
		}*/
		
		if (str_starts_with($line, "OBJLstHdrA_") || str_starts_with($line, "OBJLstHdrB_")) {
			print "\r\n".$line;
			list($hdrType, $charName, $moveName) = explode("_", get_label($line), 3);
			$hdrType = ($hdrType == "OBJLstHdrA" ? "A" : "B");
			print " ($hdrType, $charName, $moveName)";
		}
		
		if (str_starts_with($line, "dpr L") && strpos($line, "iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank") !== false) {
			print "\r\n MATCH => ".$line;
			$label = substr($line, 4, 7); // ie: L0B6BE0
			if (isset($replacements[$label])) {
				print "...skipped.";
			} else {
				$replacements[$label] = "GFX_Char_{$charName}_{$moveName}"; //_{$hdrType}";
				print "...ok.";
			}
		}
	}
}
print "\r\nParsed. Verifying...";

$duplMap = [];
foreach ($replacements as $k => $v) {
	if (isset($duplMap[$v]))
		die("$v is a duplicate entry!");
	$duplMap[$v] = true;
}

print "\r\nWriting to temp...";
file_put_contents("log.txt", print_r($replacements, true)); 

foreach (glob("src/*.asm") as $filename) {
	$basename = basename($filename);
	
    print "\r\n$basename...";
	$file = file_get_contents($filename);
	$file = strtr($file, $replacements);
	file_put_contents("temp/{$basename}", $file);
}

print "\r\nDONE";