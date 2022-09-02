<?php

const MODE_LZSS = 0b1;
const MODE_RLE = 0b10;

const MIN_MATCH = 1; // Min match size for a dictionary chunk
const FORCE_BITS = false; // If not set, bruteforces the best compression ratio

//------------
const HEADER_BIT_SPLIT = 6; // Bits for the command bytes in the second header byte
const HEADER_MAX_CMDCOUNT_VAL = (1 << (8 + HEADER_BIT_SPLIT)) - 1;
const HEADER_MAX_BYTECOUNT_BITS = (8 - HEADER_BIT_SPLIT); // Number of bits for the data splitpoint marker
const HEADER_MAX_BYTECOUNT_BITS_VAL = 1 << HEADER_MAX_BYTECOUNT_BITS; // Max number of bits for the bytecount (data splitpoint marker).


if ($argc != 4) {
	usage_error("Bad arguments.");
}

$mode = strtolower($argv[1]);

if ($mode != 'e' && $mode != 'd')
	usage_error("Invalid mode.");

if (!file_exists($argv[2])) 
	die("Can't find {$argv[2]}");

$out = fopen($argv[3], 'wb');

if ($mode == 'e') {
	$in = file_get_contents($argv[2]);
	if (FORCE_BITS !== false) {
		$data = encode($in, FORCE_BITS);
		print "BitCount ".FORCE_BITS." (Fixed): Size: ".strlen($data).PHP_EOL;
	} else {
		$data = null;
		for ($i = 1, $best_size = 0; $i <= HEADER_MAX_BYTECOUNT_BITS_VAL; $i++) {
			$attempt = encode($in, $i);
			$size = strlen($attempt);
			if ($data === null) {
				$data = $attempt;
				$best_size = $size;
				print "BitCount $i (Initial): Size: $size".PHP_EOL;
			} else {
				print "BitCount $i: Size: $size | ";
				if ($size < $best_size) {
					print "OK".PHP_EOL;
					$data = $attempt;
					$best_size = $size;
				} else {
					print "SKIP".PHP_EOL;
				}
			}
		}
	}
	
	
} else {
	$in = fopen($argv[2], 'rb');
	$data = decode($in);
	fclose($in);
}

fwrite($out, $data);
fclose($out);

die;

function usage_error($err) {
	print $err.PHP_EOL;
	print "Usage: lzss.php e/d [infile] [outfile]".PHP_EOL."\t- e: Encode file".PHP_EOL."\t- d: Decode file";
	die;
}

function decode($in) {
	$out = "";
	
	$header = ord(fgetc($in));
	$header |= (ord(fgetc($in)) << 8);
	
	// The header is two bytes long, and contains this info:
	// LLLLLLLL-SSHHHHHH
	// - L -> Number of command bytes (Low Byte)
	// - H -> Number of command bytes (High Byte)
	// - S -> Bits before split point.
	$COMMAND_COUNT = ($header & 0x3FFF)+1;
	$SPLIT_POINT_BIT = HEADER_MAX_BYTECOUNT_BITS_VAL - (($header >> (8+HEADER_BIT_SPLIT)) & 0b11);
	$SPLIT_POINT_MASK = (1 << $SPLIT_POINT_BIT) - 1;
	
	// For every command
	for ($i = 0, $mask = 0x80; $i < $COMMAND_COUNT; $i++, $mask = 0x80) {
		
		// this is a bitmask
		$cmd = ord(fgetc($in));
		
		// For every bit in the bitmask...
		for ($j = 0; $j < 8; $j++, $mask = $mask >> 1) {
			$is_dict_copy = $cmd & $mask;
			
			if (!$is_dict_copy) {
				// Raw copy
				$out .= fgetc($in);
			} else {
				// Dictionary copy
				$dict_info = ord(fgetc($in));
				$byte_offset = -($dict_info >> $SPLIT_POINT_BIT)-1;
				$byte_count = ($dict_info & $SPLIT_POINT_MASK)+1;
				
				for ($k = 0, $c = strlen($out); $k < $byte_count; $k++, $c++) {
					$out .= $out[$c + $byte_offset];
				}
			}
		}

	}
	
	return $out;
}

function encode($in, $SPLIT_POINT_BIT) {
	$out = "";
	
	if ($SPLIT_POINT_BIT > 4)
		die("Split point is out of range");
	
	$SPLIT_POINT_MASK = (1 << $SPLIT_POINT_BIT) - 1;
	
	$MAX_BYTECOUNT_SIZE = (1 << $SPLIT_POINT_BIT); // Max value for $byte_count, as determined by the bitmask fields on the right
	$MAX_DICTOFFSET_BITS = 8 - $SPLIT_POINT_BIT;
	$MAX_DICTOFFSET_SIZE = (1 << $MAX_DICTOFFSET_BITS); // Max relative value for $byte_offset 
	/*
	print "
HEADER_MAX_BYTECOUNT_BITS_VAL: ".HEADER_MAX_BYTECOUNT_BITS_VAL."
SPLIT_POINT_BIT: $SPLIT_POINT_BIT
SPLIT_POINT_MASK: $SPLIT_POINT_MASK
MAX_BYTECOUNT_SIZE: $MAX_BYTECOUNT_SIZE
MAX_DICTOFFSET_BITS: $MAX_DICTOFFSET_BITS
MAX_DICTOFFSET_SIZE: $MAX_DICTOFFSET_SIZE
";*/

	for ($i = 0, $c = strlen($in), $command_count = 0; $i < $c; $command_count++) {
		
		// Command bitmask
		$cmd = 0;
		// Buffer for 8 next data blocks
		$b = "";
		
		// For every bit in the mask
		for ($j = 0, $cmd_bit = 0x80; $j < 8; $j++, $cmd_bit = $cmd_bit >> 1) {
			
			//
			// Determine if it's better to do a dictionary copy or a raw copy.
			//
			
			// Build a buffer of everything before $i, at max $MAX_DICTOFFSET_SIZE in length.
			$pr_from = max(0, $i-$MAX_DICTOFFSET_SIZE);
			$pr_size = min($i, $MAX_DICTOFFSET_SIZE);
			$prev_buffer = substr($in, $pr_from, $pr_size);
			
			//print "FROM: $i:$pr_from:$pr_size\n";
			
			$do_dict_copy = false;
			$prev_len = strlen($prev_buffer);
			
			if ($prev_len > MIN_MATCH) {	
				// And build a buffer of everything that's after that
				$pb_from = $i;
				$pb_size = min($prev_len, $MAX_BYTECOUNT_SIZE);
				$post_buffer = substr($in, $pb_from, $pb_size);
				//print "TO: $i:$pb_from:$pb_size\n";
			
				//print "$i:$pb_from:$pb_size:".$post_buffer.":\n";
				$post_len = strlen($post_buffer);
				
				if ($post_len > MIN_MATCH) {
					// start from the largest strpos and go down
					for ($k = $post_len; $k > MIN_MATCH; $k--) {
						
						// Find the largest anchor from $i (start of $post_buffer)
						$to_match = substr($post_buffer, 0, $k);
						// And match if it's in the back buffer
						$matchpos = strpos($prev_buffer, $to_match);
						
						if ($matchpos !== false) {
							
							$do_dict_copy = true;
							$byte_offset = $i - ($pr_from + $matchpos); // Offset relative to $i
							$byte_count = $k; // Number of bytes to copy in succession

							//print "MATCH $i:$byte_offset:$byte_count";
							//if ($byte_offset > $MAX_DICTOFFSET_SIZE) {
							//	die("{$byte_offset}:{$MAX_DICTOFFSET_SIZE}");
							//if ($matchpos != 0) {
							//	print " SKIPPED ($byte_offset > $MAX_DICTOFFSET_SIZE) \n";
							//	$do_dict_copy = false;
							//} else {
							//	print "\n";
								break;
							//}
						}
					}
				}
			}
			
			
			if ($do_dict_copy) { // If we're doing a dictionary copy
				// Set the bit marking a dictionary copy
				$cmd |= $cmd_bit;
				// Write the copy info
				//if ($byte_count > $MAX_BYTECOUNT_SIZE)
				//	die("fuck");
				$b .= chr((($byte_offset-1) << $SPLIT_POINT_BIT) | ($byte_count - 1));
				
				$i += $byte_count;
			} else { // Otherwise, direct byte (not during RLE mode)
				$b .= $in[$i];
				$i++;

			}
			
			// If we reached the end of the input data, exit this
			// and write the leftovers to the output.
			if ($i >= $c) {
				$j++;
				//print "Info: Padding characters: ".(8-$j).PHP_EOL;
				for (; $j < 8; $j++) {
					$b .= "\0";
				}
				break;
			}
		}
		
		// Write the output
		$out .= chr($cmd).$b;
	}
	
	// It's offset by 1 in the header
	$command_count--;
	
	if ($command_count > HEADER_MAX_CMDCOUNT_VAL || $command_count < 0)
		print "Warning: Command count is higher than the max allowed value ({$command_count} > ".HEADER_MAX_CMDCOUNT_VAL.")".PHP_EOL;
	
	// Write the header
	$hb1 = $command_count & 0xFF;
	$hb2 = ((HEADER_MAX_BYTECOUNT_BITS_VAL - $SPLIT_POINT_BIT) << HEADER_BIT_SPLIT) | ($command_count >> 8);
	$header = chr($hb1).chr($hb2);
	//print "Command count: $command_count | $hb1 | $hb2 ".PHP_EOL;
	
	return $header.$out;
}