<?php
	
$IN_FILE = "tempconv.txt";

// Purpose: Mass rename mMvAnDef L* entries across multiple files.
require "lib/common.php";

$asmfile = file($IN_FILE);

$replacements = [];

$match = "mMvAnDef L";
$matchLen = strlen($match);

$matchMove = " MOVE_";
$matchMoveLen = strlen($matchMove);

$convTbl = [
"_Cl" => "_CL",
"_Ch" => "_CH",
"_Rotl" => "_RotL",
"_Rotr" => "_RotR",
"_Rotu" => "_RotU",
"_Rotd" => "_RotD",
"_Hitlow" => "_HitLow",
"Guardbreak" => "GuardBreak",
"Lost_Timeover" => "TimeOver",
"Chargemeter" => "ChargeMeter",
];

foreach ($asmfile as $l) {
	$line = trim($l);
	
	if (str_starts_with($line, "MoveAnimTbl_")) {
		$charname = str_replace(["MoveAnimTbl_", ":"], "", $line); 
	} else if (str_starts_with($line, $match)) {
		
		//$bankNum = substr($line, $matchLen, 2); // "04"
		
		$source = substr($line, $matchLen - 1, 7); // "L047E37"
		if (isset($replacements[$source])) // [$bankNum]
			continue;
		
		$moveNamePos = strrpos($line, $matchMove);
		if ($moveNamePos === false)
			die("[ERR] ".$line);
		
		// MOVE_SHARED_PUNCH_CL -> PunchCl
		$moveName = substr($line, $moveNamePos + $matchMoveLen);
		$moveName = str_replace("SHARED_", "", $moveName);
		$moveName = ucwords(strtolower($moveName), "_");
		$moveName = strtr($moveName, $convTbl);
		$moveName = str_replace("_", "", $moveName);
		
		if (str_starts_with($moveName, ucwords(strtolower($charname)))) {
			$moveName = substr($moveName, strlen($charname));
		}
		
		$replacements[$source] = "OBJLstPtrTable_{$charname}_{$moveName}"; // [$bankNum]
	}
}

print "\r\nParsed. Writing to temp...";
file_put_contents("log.txt", print_r($replacements, true)); 

foreach (glob("src/*.asm") as $filename) {
	$basename = basename($filename);
	
    print "\r\n$basename...";
	$file = file_get_contents($filename);
	$file = strtr($file, $replacements);
	file_put_contents("temp/{$basename}", $file);
}

print "\r\nDONE";