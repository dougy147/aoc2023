#!/opt/flutter/bin/dart

import 'dart:io';
import 'dart:math';


String filepath = "./assets/05.txt";

void main() {
	List<dynamic> content = readFile(filepath);
	var seeds = extractSeeds(content[0]);
	//print("Seeds list: ${seeds}");
	List<int> locationNumbers = [];
	seeds.forEach((seed) => {
	  locationNumbers.add(int.parse(convertissor(seed, "seed", "location", content))),
	});
	print("Minimum location number: ${locationNumbers.reduce(min)}");
}

// convert any start_seed number to any other ~ given a start source and an ending target (e.g. source:"soil", target:"water")
convertissor(String start_seed, String start_at, String stop_after, List<dynamic> content) {
	String new_start_seed = start_seed;
	int index = 0;

	while (index < content.length) {
	  while (!reachedStartInDict(start_at, content[index]))  { index+=1; };
	  index+=1; // ignore this exact line when found

          // until next "convert line" (e.g. soil->water), compute seed
          while ( !isConvertLine(content[index]) ) {
	    var details = extractDetails(content[index]);
	    int dest  = int.parse(details[0]);
	    int sour  = int.parse(details[1]);
	    int range = int.parse(details[2]);

	    if ((int.parse(start_seed) >= sour) && (int.parse(start_seed) < sour + range ) )  {
	     String new_seed = ((int.parse(start_seed) - sour) + dest ).toString()  ;
	     new_start_seed = new_seed;
	     break;
	    } else {
	     new_start_seed = start_seed;
	    };

	    index+=1;
	    if ((index >= content.length) || (content[index] == "")) { break; };
	  };

          while (( index < content.length - 1) && (( !isConvertLine(content[index]) ) || (content[index] == "" ))) {
	    index+=1;
	  };

	  if ( (index < content.length ) && (!reachedStopInDict(stop_after, content[index])) ) {
            String new_start_at = RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$').allMatches(content[index])
	    			.elementAt(0)
				.group(2)
				.toString();
	    return convertissor(new_start_seed, new_start_at, stop_after, content);
	  } else {
            while ( true ) {
	      if ( (index < content.length) && (content[index] != "") && (!isConvertLine(content[index])))  {
	        var details = extractDetails(content[index]);
	        int dest  = int.parse(details[0]);
	        int sour  = int.parse(details[1]);
	        int range = int.parse(details[2]);

	        if ((int.parse(new_start_seed) >= sour) && (int.parse(new_start_seed) < sour + range ) )  {
	         String new_seed = ((int.parse(new_start_seed) - sour) + dest ).toString()  ;
	         new_start_seed = new_seed;
	         break;
	        };
	      };
	      index+=1;
	      if (index >= content.length) { break; };
	    };
	    return new_start_seed;
	  };
	  index+=1;
	};
	return new_start_seed;
}

bool isConvertLine(String line) {
	if (RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$').hasMatch(line)) { return true; };
	return false;
}

bool reachedStartInDict(String start_at, String line) {
	RegExp re = RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$');
	if (re.hasMatch(line)) {
	  String match = re.allMatches(line).elementAt(0).group(2).toString();
	  if (match == start_at) {
	    return true;
	  };
	};
	return false;
}

bool reachedStopInDict(String stop_after, String line) {
	RegExp re = RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$');
	if (re.hasMatch(line)) {
	  String match = re.allMatches(line).elementAt(0).group(4).toString();
	  if (match == stop_after) {
	    return true;
	  };
	};
	return false;
}

extractSeeds(String line) {
	List<String> seeds = [];
	RegExp re = RegExp(r'^seeds:\s*((\s*\d+\s*)+)$');
	seeds = re.allMatches(line).elementAt(0).group(1).toString().split(' ');
	return seeds;
}

extractDetails(String line) {
	RegExp re = RegExp(r'^((\s*?\d+\s*?){3})$');
	if (re.hasMatch(line)) {
	  var match = re.allMatches(line).elementAt(0).group(1).toString().split(' ');
	  return(match);
	};
}

readFile(String filepath) {
	List<dynamic> content = [];
	File(filepath).readAsLinesSync().forEach ((line) => {
	  content.add(line),
	});
	return content;
}
