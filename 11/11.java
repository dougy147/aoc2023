import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.util.List;
import java.util.ArrayList;

public class Main {

	public static List<Integer> get_rows_indexes(List<String> content) {
		List<Integer> indexes = new ArrayList<Integer>();
		for (int i = 0; i < content.size(); i++) {
			boolean gal_is_here = false;
			for (int j = 0; j < content.get(i).length(); j++) {
		  		if (content.get(i).charAt(j) == '#') {
					gal_is_here = true;
				}
			}
			if ( gal_is_here == false ) {
				indexes.add(i);
			}
		}
		return indexes;
	}

	public static List<Integer> get_cols_indexes(List<String> content) {
		List<Integer> indexes = new ArrayList<Integer>();
		for (int i = 0; i < content.get(0).length(); i++) {
			boolean gal_is_here = false;
			for (int j = 0; j < content.size(); j++) {
				if (content.get(j).charAt(i) == '#') {
					gal_is_here = true;
				}
			}
			if ( gal_is_here == false ) {
				indexes.add(i);
			}
		}
		return indexes;
	}

	public static List<List<Integer>> get_galaxies_coordinates(List<String> content) {
		List<List<Integer>> indexes = new ArrayList<List<Integer>>();
		for (int i = 0; i < content.size(); i++) {
			for (int j = 0; j < content.get(i).length(); j++) {
				if (content.get(i).charAt(j) == '#') {
					List<Integer> tmp = new ArrayList<Integer>();
					tmp.add(i);
					tmp.add(j);
					indexes.add(tmp);
				}
			}
		}
		return indexes;
	}

	public static long compute_distances_sum(List<List<Integer>> coordinates, List<Integer> row_indexes, List<Integer> col_indexes, Integer spacing) {
		long result = 0;
		for (int i = 0; i < coordinates.size(); i++) {
			for (int j = i+1; j < coordinates.size(); j++) {
				Integer tmp1 = coordinates.get(i).get(0);
				Integer tmp2 = coordinates.get(i).get(1);
				List<Integer> gal1 = new ArrayList<Integer>()
					{{ add(tmp1); add(tmp2); }};
				Integer tmp3 = coordinates.get(j).get(0);
				Integer tmp4 = coordinates.get(j).get(1);
				List<Integer> gal2 = new ArrayList<Integer>()
					{{ add(tmp3); add(tmp4); }};
				for (int k = 0; k < row_indexes.size(); k++) {
					if (row_indexes.get(k) >= tmp1 && row_indexes.get(k) <= tmp3) {
						gal2.set(0,gal2.get(0) + spacing - 1);
					}
				}
				for (int l = 0; l < col_indexes.size(); l++) {
					if (tmp2 <= col_indexes.get(l) && tmp4 >= col_indexes.get(l)) {
						gal2.set(1,(gal2.get(1) + (spacing - 1)));
					}
					if (tmp2 >= col_indexes.get(l) && tmp4 <= col_indexes.get(l)) {
						gal2.set(1,(gal2.get(1) - (spacing - 1)));
					}
				}
				result = result + ( Math.abs(gal2.get(0) - gal1.get(0)) + Math.abs(gal2.get(1) - gal1.get(1)));
			}
		}

		return result;
	}

	public static void main(String[] args) {
		String filepath = "./assets/11.txt";
		List<String> content = new ArrayList<>();
		try {
			Scanner scanner = new Scanner(new File(filepath));

			while (scanner.hasNextLine()) {
				content.add(scanner.nextLine());
			}
			scanner.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}

		Integer spacing = 2;
		System.out.println(compute_distances_sum(get_galaxies_coordinates(content),get_rows_indexes(content),get_cols_indexes(content),spacing));
	}
}
