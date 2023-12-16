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
	for (i in 0..pattern.size-1-1 step 1) {
		if (are_identical_rows(pattern,i,i+1)) {
			var above  = 1
			var under  = 1
			var mirror = true
			while ( i - above >= 0 ) {
				if ((i+under+1) >= pattern.size) {
					above+=1
					continue
				}
				if (! are_identical_rows(pattern,i-above,i+under+1)) {
					mirror = false
					break
				}
				above+=1
				under+=1
			}
			if (mirror) {
				return 100 * above
			}
		}
	}
	return 0
}

fun find_vertic_reflection(pattern: MutableList<String>): Int {
	for (i in 0..pattern[0].length-1-1 step 1) {
		if (are_identical_cols(pattern,i,i+1)) {
			var left  = 1
			var right  = 1
			var mirror = true
			while ( i - left >= 0 ) {
				if ((i+right+1) >= pattern[0].length) {
					left+=1
					continue
				}
				if (! are_identical_cols(pattern,i-left,i+right+1)) {
					mirror = false
					break
				}
				left+=1
				right+=1
			}
			if (mirror) {
				return left
			}
		}
	}
	return 0
}
