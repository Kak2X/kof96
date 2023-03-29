<?php
	
// Purpose: Apply sym file
require "lib/common.php";

$sym = file("tempconv.sym");

$replacements = [];
foreach ($sym as $l) {
	$line = trim($l);
	if (strlen($line) < 9)
		continue;
	
	$from = "L".substr($line, 0, 2).substr($line, 3, 4);
	$to = substr($line, 8);
	
	$replacements[strtoupper($from)] = $to;
}

$file = file_get_contents("tempconv.txt");
$file = strtr($file, $replacements);
file_put_contents("tempconv.asm", $file);

print "\r\nDONE";