<?php

$aaa = '
error: main.asm(20) -> src/bank01.asm(888): Unknown symbol "COLIBOX_07"
';

$data = explode("\n", $aaa);
$nums = [];
foreach ($data as $line) {
	if (($pos = strpos($line, "COLIBOX")) !== false) {
		$num = substr($line, $pos+8, 2);
		if (!in_array($num, $nums))
			$nums[] = $num;
	}
}
sort($nums);
//print_r($nums);

foreach ($nums as $num)
	print "COLIBOX_$num EQU \$$num\r\n";