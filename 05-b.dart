import 'dart:io';
import 'dart:math';

String filepath = "./assets/05.txt";

void main() {
	List<dynamic> content = readFile(filepath);
	var seeds_ranges = extractSeeds(content[0]);

	print("-----------------------------------------");
	print("Seeds and ranges list:  \n${seeds_ranges}\n");
	print("-----------------------------------------");

	var headers = ["seed","soil","fertilizer","water","light","temperature","humidity","location"];

        // ranges_list gives : [ 'seed' : [('seed source interval', 'soil destination interval'), ...],
	//                       'soil' : [('soil source interval', 'fertilizer destination interval'), ...],
	//                       'fert' : ...
	//   -> ascending order index 0
	var ranges_list = getRanges(content);

	int whole_min_val = 999999999999999999; // Arbitrary high number to be reduced (minimum location)

	seeds_ranges.forEach( (my_seeds_range) {
	  int i = 0; // track header
	  var current_intervals = [my_seeds_range];
	  ranges_list.forEach( (dico) {
	    //print("Current source intervals (${headers[i]}-to-${headers[i+1]})");
	    current_intervals = convertIntervals(current_intervals, dico);
	    i+=1;
	  });

	  // Update whole_min_val (minimum location value)
	  current_intervals.forEach( (inter) {
	    if (inter[0] < whole_min_val) {
	      whole_min_val = inter[0];
	    }
	  });
	});
	print("Minimum location for initial range of seeds is: ${whole_min_val}");
}

convertIntervals(List<List<int>> source, List<dynamic> destination) {
        // Converts all intervals into sub intervals from 'seed' to 'location'
        List<List<int>> new_source = [];
	List<List<int>> remaining  = source;

	while (remaining.length != 0) {
	  remaining = [];
	  source.forEach( (s) { // (s) for source
	    destination.forEach ( (d) { // (d) for destination
	      var c = [d[2],d[3]];
	      // case 1, case 6 <== nothing to do.
	      // case 2, case 4
	      if (( s[0] <= d[1] ) && ( d[1] <= s[1] )) {
	         if (d[0] < s[0]) { // case 2 (1 part in 'new_source', 1 part in 'remaining')
		   new_source.add([c[0] + s[0] - d[0]  ,c[1]]);
		   remaining.add([d[1] + 1, s[1]]);
		 } else if (d[0] >= s[0]) { // case 4 (1 part in 'new_source', 2 parts in 'remaining')
		   new_source.add([c[0] ,c[1]]);
		   remaining.add([s[0], d[0] - 1]);
		   remaining.add([s[1] + 1, s[1]]);
		 }
	      // case 3, case 5
	      } else if ( (s[1] >= d[0] ) && (s[1] <=d[1]) ) {
	        if (s[0] < d[0]) { // case 3 (1 part in 'new_source', 1 part in 'remaning')
		  new_source.add([c[0], c[0] + s[1] - d[0]]);
		  remaining.add([s[0], d[0] - 1]);
		} else if (s[0] >= d[0]) { // case 5 (1 part in 'new_source')
                  new_source.add([c[0] + s[0] - d[0], c[1] - (d[1] - s[1])]);
		}
	      }
	    });
	  });

	  if (source == remaining) {
	    //print("Already done a loop with that source. Storing those unmapped ranges in new_source.");
	    remaining.forEach( (r) {
	      new_source.add(r);
	    });
	    break;
	  }
	  source = remaining;
	}
	return new_source;
}

getRanges(List<dynamic> content) {
	RegExp re = RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$');
	int index = 0;
	var ranges_list = [];
	while (index < content.length) {
	  while ((!isConvertLine(content[index])) || (content[index] == "")) { index+=1; };

	  String source_var = re.allMatches(content[index]).elementAt(0).group(2).toString();
	  String destin_var = re.allMatches(content[index]).elementAt(0).group(4).toString();

	  index+=1;

	  var cur_conv_list = [];
	  while ((!isConvertLine(content[index])) || (content[index] != "")) {
	    if (content[index] == "") {
	      break;
	    };
	    var details = extractDetails(content[index]);
	    int dest  = int.parse(details[0]);
	    int sour  = int.parse(details[1]);
	    int range = int.parse(details[2]);
	    var sublist = [sour,sour+range-1,dest,dest+range-1];
	    cur_conv_list.add(sublist);
	    index+=1;
	    if (index >= content.length) {
	      break;
	    };
	  };
	  cur_conv_list.sort((a,b) => a[1].compareTo(b[1])); // sort for index 0
	  ranges_list.add(cur_conv_list);
	  index+=1;
	  if (destin_var == "location") {return ranges_list;};
	};
}


List<List<int>> extractSeeds(String line) {
	// Extract intervals from input
        List<List<int>> seeds = [];
	List<String> seeds_ranges = [];
	RegExp re = RegExp(r'^seeds:\s*((\s*\d+\s*)+)$');
	seeds_ranges = re.allMatches(line).elementAt(0).group(1).toString().split(' ');
	int index = 0;
	seeds_ranges.forEach((value) {
	  if (index % 2 == 0) {
	    int a = int.parse(seeds_ranges[index]);
	    int b = int.parse(seeds_ranges[index+1])+int.parse(seeds_ranges[index]);
	    seeds.add([a,b]); // a: lower bound, b: higher bound
	  };
	  index+=1;
	});
	return seeds;
}

readFile(String filepath) {
	List<dynamic> content = [];
	File(filepath).readAsLinesSync().forEach ((line) => {
	  content.add(line),
	});
	print("[INFO] File '$filepath' imported.");
	return content;
}

extractDetails(String line) {
	RegExp re = RegExp(r'^((\s*?\d+\s*?){3})$');
	if (re.hasMatch(line)) {
	  var match = re.allMatches(line).elementAt(0).group(1).toString().split(' ');
	  return(match);
	};
}

bool isConvertLine(String line) {
	//RegExp re = RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$');
	if (RegExp(r'^((\w+)(-to-)(\w+))\s+.*?$').hasMatch(line)) { return true; };
	return false;
}

