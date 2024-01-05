import java.io.File
import java.io.InputStream;

fun main(args : Array<String>) {
	val input: InputStream = File("./assets/13.txt").inputStream()
	val lineList = mutableListOf<String>()
	var hashmap = HashMap<Int,MutableList<String>>()
	var index = 0
	var mirrorlist = mutableListOf<String>()

	input.bufferedReader().forEachLine { lineList.add(it) }
	lineList.forEach{
		if (it == "") {
			hashmap.put(index,mirrorlist)
			mirrorlist = mutableListOf<String>()
			index+=1
			return@forEach
		}
		mirrorlist.add(it)
	}
	hashmap.put(index,mirrorlist)
	mirrorlist = mutableListOf<String>()

	var total = 0
    	for(key in hashmap.keys){
		total += find_horiz_reflection(hashmap[key]!!)
		total += find_vertic_reflection(hashmap[key]!!)
    	}
	println(total)
}

fun are_identical_rows(pattern: MutableList<String>, index_row1: Int, index_row2: Int): Boolean {
	for (i in 0..pattern[index_row1].length-1 step 1) {
		if (pattern[index_row1][i] != pattern[index_row2][i]) {
			return false
		}
	}
	return true
}

fun are_identical_cols(pattern: MutableList<String>, index_col1: Int, index_col2: Int): Boolean {
	for (i in 0..pattern.size - 1 step 1) {
		if (pattern[i][index_col1] != pattern[i][index_col2]) {
			return false
		}
	}
	return true
}

fun find_horiz_reflection(pattern: MutableList<String>): Int {
	for (i in 0..pattern.size-1 step 1) {
		for (j in pattern.size-1 downTo 0) {
			if ((j-i) % 2 == 0) {
				continue
			}
			if (check_smudge_line(pattern[i],pattern[j])) {
				var above = 1
				var under = 1
				var mirror = true
				while ( (j-under) - (i+above) >= 0 ) {
					if (! are_identical_rows(pattern,i+above,j-under)) {
						mirror = false
						break
					}
					above+=1
					under+=1
				}
				if (!mirror) {
					continue
				}
				above = 1
				under = 1
				while ( (i-above) >= 0 && (j+under) < pattern.size ) {
					if (! are_identical_rows(pattern,i-above,j+under)) {
						mirror = false
						break
					}
					above+=1
					under+=1
				}
				if (mirror) {
					return 100 * (i + ((j-i)/2) + 1)
				}
			}
		}
	}
	return 0
}

fun find_vertic_reflection(pattern: MutableList<String>): Int {
	for (i in 0..pattern[0].length-1 step 1) {
		for (j in pattern[0].length-1 downTo 0) {
			if ((j-i) % 2 == 0) {
				continue
			}
			if (check_smudge_col(pattern,i,j)) {
				var left = 1
				var right = 1
				var mirror = true
				while ( (j-right) - (i+left) >= 0 ) {
					if (! are_identical_cols(pattern,i+left,j-right)) {
						mirror = false
						break
					}
					left+=1
					right+=1
				}
				if (!mirror) {
					continue
				}
				right = 1
				left = 1
				while ( (i-left) >= 0 && (j+right) < pattern[0].length ) {
					if (! are_identical_cols(pattern,i-left,j+right)) {
						mirror = false
						break
					}
					left+=1
					right+=1
				}
				if (mirror) {
					return (i + ((j-i)/2) + 1)
				}
			}
		}
	}
	return 0
}

fun check_smudge_line(line1: String, line2: String): Boolean {
	var diff_count = 0
	for (i in 0..line1.length-1 step 1) {
		if ( line1[i] != line2[i] ) {
			diff_count+=1
		}
		if ( diff_count > 1 ) {
			return false
		}
	}
	if ( diff_count != 1 ) {
		return false
	}
	return true
}

fun check_smudge_col(pattern: MutableList<String>, col_index1: Int, col_index2: Int): Boolean {
	var diff_count = 0
	for (i in 0..pattern.size-1 step 1) {
		if ( pattern[i][col_index1] != pattern[i][col_index2] ) {
			diff_count+=1
		}
		if ( diff_count > 1 ) {
			return false
		}
	}
	if ( diff_count != 1 ) {
		return false
	}
	return true
}
