<?php

chdir("..");

function get_label($line) {
	$sep = strpos($line, ":");
	$x = substr($line, 0, $sep);
	return $x;
}

function get_db($line, $id = null) {
	if ($id !== null) {
		$line = $line[$id];
	}
	$sep = strpos($line, ":");
	if ($sep === false)
		return false;
	$x = substr($line, $sep + strlen(": db \$"), 2);
	return $x;
}

function get_dw($line, $id = null) {
	return get_db($line, $id+1).get_db($line, $id);
}

function generate_const_label($strdb, $map) {
	$val = hexdec($strdb);
	$res = "";
	foreach ($map as $k => $lbl) {
		if ($val & (1 << $k)) {
			$res .= ($res ? "|" : "").$lbl;
			//$val ^= (1 << $k); // Remove bit
		}
	}
	//if ($val)
	//	$res = ($res ? "{$res}" : "") ""
	if (!$res)
		return "\$00";
	return $res;
}

function fmthexnum($dec) {
	return str_pad(strtoupper(dechex($dec)), 2, "0", STR_PAD_LEFT);
}