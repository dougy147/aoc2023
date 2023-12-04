#!/usr/bin/env php

<?php

function score_card($content, $index) {
	if ( $index >= count($content) ) {
		return;
	};
	$won_cards = 0;
	list($cn,$numbers) = explode(":", $content[$index]);
	$cn = explode(" ",$cn)[1];
	list($wn,$gn) = explode("|", $numbers);
	$wn = array_values(array_filter(explode(" ", $wn))); // array_filter: remove empty, array_values : reindex
	$gn = array_values(array_filter(explode(" ", $gn)));
	foreach ($wn as $w) {
		if (in_array($w, $gn)) {
			$won_cards += 1;
		};
	};
	$additional_cards = 0;
	for ($i=1; $i <= $won_cards; $i++) {
		$additional_cards += score_card($content, $index + $i);
	};
	return $won_cards + $additional_cards;
};


// open file
$filepath = "./assets/04.txt";
$content = file($filepath);
$score = 0; // number of scratchcards
$index = 0;

foreach ($content as $line) {
	$score += score_card($content, $index);
	$index += 1;
};

$score = $score + $index; // adding the initial deck

print("Total scratchcards: $score");

?>
