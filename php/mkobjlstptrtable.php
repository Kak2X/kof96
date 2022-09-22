<?php

// Purpose: Create OBJLstPtrTable_ structures
// ==============================

require "lib/common.php";

if (!file_exists("tempconv.txt")) {
	die("can't find tempconv.txt");
}
//const DELIM = "L";
//const DELIMN = 0;

$objlst_flags = [
	0 => "OLF_BIT0",
	1 => "OLF_BIT1",
	2 => "OLF_BIT2",
	3 => "OLF_BIT3",
	4 => "OLF_USETILEFLAGS",
	5 => "OLF_XFLIP",
	6 => "OLF_YFLIP",
	7 => "OLF_NOBUF",
];

print "Converting data...".PHP_EOL;

$h = fopen("tempconv.asm", 'w');

$lines = file("tempconv.txt");

if (count($lines) > 0)
	$banknum = substr($lines[1], 1, 2);

$objlst_a = [];
$objlst_b = [];


for ($i = 0; $i < count($lines);) {
	
	/*
	if (strpos($lines[$i], "OBJLstPtrTable_") !== 0){
		++$i;
		continue;
	}*/
	
	$base_label = get_label($lines[$i]);
	
	if (in_array($base_label, $objlst_a)) {
		print "A hit: $base_label\r\n";
		
		$label = "OBJLstHdrA_".$base_label;
		
		$flags = generate_const_label(get_db($lines[$i++]), $objlst_flags);
		$byte1 = get_db($lines[$i++]);
		$byte2 = get_db($lines[$i++]);
		$gfx_low = get_db($lines[$i++]);
		$gfx_high = get_db($lines[$i++]);
		$gfx_bank = get_db($lines[$i++]);
		$data_low = get_db($lines[$i++]);
		$data_high = get_db($lines[$i++]);
		$xoff = get_db($lines[$i++]);
		$yoff = get_db($lines[$i++]);
		
		$gfx_ptr = ($gfx_bank == "FF" && $gfx_high == "FF" && $gfx_low == "FF") 
			? "db \$FF,\$FF,\$FF"
			: "dp L{$gfx_bank}{$gfx_high}{$gfx_low}";
		
		$data_ptr = "L{$banknum}{$data_high}{$data_low}";
		$objinfo = "";
		if (get_label($lines[$i]) == $data_ptr) {
			$data_ptr = ".bin";
			
			$objcount = get_db($lines[$i++]);
			
			$objinfo .= "
.bin:
	db \${$objcount} ; OBJ Count
	;    Y   X  ID+FLAG";
			
			for ($j = 0, $max = hexdec($objcount); $j < $max; $j++) {
				$y = get_db($lines[$i++]);
				$x = get_db($lines[$i++]);
				$f = get_db($lines[$i++]);
				$objinfo .= "
	db \${$y},\${$x},\${$f} ; \$".fmthexnum($j);
			}
			
			// 
		}
		
		$b = "{$label}:
	db {$flags} ; iOBJLstHdrA_Flags
	db \${$byte1} ; iOBJLstHdrA_Byte1
	db \${$byte2} ; iOBJLstHdrA_Byte2
	{$gfx_ptr} ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw {$data_ptr} ; iOBJLstHdrA_DataPtr
	db \${$xoff} ; iOBJLstHdrA_XOffset
	db \${$yoff} ; iOBJLstHdrA_YOffset{$objinfo}";
		
	} else if (in_array($base_label, $objlst_b)) {
		print "B hit: $base_label\r\n";
		
		$label = "OBJLstHdrB_".$base_label;
		
		$flags = generate_const_label(get_db($lines[$i++]), $objlst_flags);
		$gfx_low = get_db($lines[$i++]);
		$gfx_high = get_db($lines[$i++]);
		$gfx_bank = get_db($lines[$i++]);
		$data_low = get_db($lines[$i++]);
		$data_high = get_db($lines[$i++]);
		$xoff = get_db($lines[$i++]);
		$yoff = get_db($lines[$i++]);
		
		$gfx_ptr = ($gfx_bank == "FF" && $gfx_high == "FF" && $gfx_low == "FF") 
			? "db \$FF,\$FF,\$FF"
			: "dp L{$gfx_bank}{$gfx_high}{$gfx_low}";
		
		$data_ptr = "L{$banknum}{$data_high}{$data_low}";
		$objinfo = "";
		
		
		if (get_label($lines[$i]) == $data_ptr) {
			$data_ptr = ".bin";
		//$isMatch = get_label($lines[$i]) != $data_ptr;
		//if ($isMatch) {
		//	$data_ptr = ".bin";
		//} else {
		//	while ($i < count($lines)) {
		//		$isMatch = get_label($lines[$i]) != $data_ptr;
		//		if ($isMatch) {
		//			break;
		//		}
		//		$b .= $lines[$i];
		//		$i++;
		//	}	
		//}
		//
		//if ($isMatch) {
		//	$objcount = get_db($lines[$i++]);
			
			$objinfo .= "
{$data_ptr}:
	db \${$objcount} ; OBJ Count
	;    Y   X  ID+FLAG";
			
			for ($j = 0, $max = hexdec($objcount); $j < $max; $j++) {
				$y = get_db($lines[$i++]);
				$x = get_db($lines[$i++]);
				$f = get_db($lines[$i++]);
				$objinfo .= "
	db \${$y},\${$x},\${$f} ; \$".fmthexnum($j);
			}
			
			// 
		}
		
		$b = "{$label}:
	db {$flags} ; iOBJLstHdrA_Flags
	{$gfx_ptr} ; iOBJLstHdrA_GFXPtr + iOBJLstHdrA_GFXBank
	dw {$data_ptr} ; iOBJLstHdrA_DataPtr
	db \${$xoff} ; iOBJLstHdrA_XOffset
	db \${$yoff} ; iOBJLstHdrA_YOffset{$objinfo}";
	} else if (strpos($lines[$i], "OBJLstPtrTable_") === 0) {
		$label = $base_label;
		
		$chcount = get_db($lines[$i]);
		
		$b = "{$label}:";
		
		while ($i < count($lines)) {
			
			$header_a_low = get_db($lines[$i++]);
			$header_a_high = get_db($lines[$i++]);
			
			if ($header_a_high == "FF") {
				// End of the OBJLst
				$b .= "
	dw \$FFFF";
				break;
			}
			
			// Only here, since it doesn't count for the end separator
			$unused_marker = strpos($lines[$i-2], ";X") !== false ? " ;X" : "";
			
			$header_b_low = get_db($lines[$i++]);
			$header_b_high = get_db($lines[$i++]);
			
			$header_a_merged = "L{$banknum}{$header_a_high}{$header_a_low}";
			$objlst_a[] = $header_a_merged;
			$header_a_merged = "OBJLstHdrA_".$header_a_merged;
			
			if ($header_b_high == "FF")
				$header_b_merged = "OBJLSTPTR_NONE";
			else {
				$header_b_merged = "L{$banknum}{$header_b_high}{$header_b_low}";
				$objlst_b[] = $header_b_merged;
				$header_b_merged = "OBJLstHdrB_".$header_b_merged;
			}
			
			$b .= "
	dw {$header_a_merged}, {$header_b_merged}{$unused_marker}";
		}
	} else {
		$i++;
	}
	
		$b .= "
		
";

		fwrite($h, $b);	
	
	
}
fclose($h);