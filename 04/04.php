#!/usr/bin/env php

<?php

function score_card($card) {
	$card_score = 0;
	list($cn,$numbers) = explode(":", $card);
	$cn = explode(" ",$cn)[1];
	list($wn,$gn) = explode("|", $numbers);
	$wn = array_values(array_filter(explode(" ", $wn))); // array_filter: remove empty, array_values : reindex
	$gn = array_values(array_filter(explode(" ", $gn)));
	foreach ($wn as $w) {
		if (in_array($w, $gn)) {
			if ($card_score == 0) {
				$card_score += 1;
			} else {
				$card_score *= 2;
			};
		};
	};
	return $card_score;
};


// open file
$filepath = "./assets/04.txt";
$content = file($filepath);
$score = 0;

foreach ($content as $line) {
	$score += score_card($line);
};

print("Total points: $score");

?>
