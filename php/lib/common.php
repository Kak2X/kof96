<?php

require "defines.php";

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

function get_move_table($base_label) {
	// Determine initial running ID
	if (strpos($base_label, "Shared") !== false) {
		if (strpos($base_label, "Base") !== false) {
			return [MOVEGROUP_BASE_START, null];
		} else if (strpos($base_label, "Hit") !== false) {
			return [MOVEGROUP_HIT_START, null];
		}
	} else {
		$id = MOVEGROUP_ATTACK_START;
		
		// Determine character table
		$charname = strtoupper(explode("_", $base_label, 2)[1]);
		print $charname."\r\n";
		$charid = array_search($charname, CHAR_NAMES, true);
		if ($charid === false)
			die("not found! $charname");
		$spectbl = MOVES_CHAR[$charid];
		
		return [$id, $spectbl];
	}
}

function get_move_name_from_tbl($id, $spectbl) {
	if ($id >= MOVEGROUP_ATTACKSPEC_START && $id < MOVEGROUP_ATTACKSPEC_END) {
		// character-specific
		return $spectbl[$id-MOVEGROUP_ATTACKSPEC_START];
	} else {
		// common
		return MOVES_GLOBAL[$id];
	}
}

function fmthexnum($dec, $digits = 2) {
	return str_pad(strtoupper(dechex($dec)), $digits, "0", STR_PAD_LEFT);
}