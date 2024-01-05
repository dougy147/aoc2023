//const fs = require('fs'); //

let filepath = "./assets/07.txt" ;
let content = require('fs').readFileSync(filepath, 'utf8');
let lines = content.split(/\r?\n/);

function getHand(line) { return line.split(/\ /)[0]; }
function getBid(line) { return line.split(/\ /)[1]; }

function getHandType(hand) {
	var dict = {};
	for (let i = 0; i < hand.length; i++) {
		if (dict[hand[i]] === undefined) {
			dict[hand[i]] = 1;
		} else {
			dict[hand[i]] += 1;
		}
	}
	let n_jokers = dict['J'];
	let numKey = Object.keys(dict).length;
	if (numKey === 1) {
		return 7;
	} else if (numKey === 2) {
		for (var key in dict) {
			if (dict[key] === 4) {
				if (n_jokers === 1 || n_jokers === 4) {
					return 6 + 1;
				}
				return 6;
			}
		}
		if (n_jokers === 2 || n_jokers === 3) {
			return 5 + 2;
		}
		return 5;
	} else if (numKey === 3) {
		for (var key in dict) {
			if (dict[key] === 3) {
				if (n_jokers === 1 || n_jokers === 3) {
					return 4 + 2;
				}
				return 4;
			}
		}
		if (n_jokers === 1) {
			return 3 + 2;
		} else if (n_jokers === 2) {
			return 3 + 3;
		}
		return 3;

	} else if (numKey === 4) {
		if (n_jokers === 1 || n_jokers === 2) {
			return 2 + 2;
		}
		return 2;
	}
	if (n_jokers === 1) {
		return 1 + 1;
	}
	return 1;
}

function hand1BeatsHand2(hand1,hand2) {
	if (getHandType(hand1) > getHandType(hand2)) {
		return true;
	} else if (getHandType(hand2) > getHandType(hand1)) {
		return false;
	} else {
		if ( bestHand(hand1,hand2) === hand1 ) {
			return true;
		} else {
			return false;
		}
	}
}

function bestHand(hand1,hand2) {
	for (let i = 0; i < hand1.length; i++) {
		if (cardValue(hand1[i]) > cardValue(hand2[i])) {
			return hand1;
		} else if (cardValue(hand2[i]) > cardValue(hand1[i])) {
			return hand2;
		}
	}
}

function cardValue(card) {
	values = {"A": 12, "K": 11, "Q": 10, "J": -1, "T": 8, "9": 7, "8": 6, "7": 5, "6": 4, "5": 3, "4": 2, "3": 1, "2": 0}
	return values[card];
}

function rankAllHands(lines) {
	rankings = {}
	bids = {}
	for (let i = 0; i < lines.length-1; i++) {
		let hand1 = String(getHand(lines[i]));
		if (rankings[hand1] === undefined) {
			rankings[hand1] = 1000;
			bids[hand1] = getBid(lines[i]);
		}
		for (let j = i+1; j < lines.length-1; j++) {
			let hand2 = String(getHand(lines[j]));
			if (rankings[hand2] === undefined ) {
				rankings[hand2] = 1000;
				bids[hand2] = getBid(lines[j]);
			}
			if ( hand1BeatsHand2(hand1,hand2) ) {
				rankings[hand2] -= 1;
			} else if ( hand1BeatsHand2(hand2,hand1) ){
				rankings[hand1] -= 1;
			}
		}
	}
	let result = 0;
	for (var key in rankings) {
		result += (rankings[key] * bids[key]);
	}
	console.log("Result: ",result);
}

rankAllHands(lines);
