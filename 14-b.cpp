#include <iostream>
#include <fstream>
#include <list>
#include <vector>
#include <sstream>
#include <map>

using namespace std;

string take_col(list<string> content, int index) {
	string column;
	for (auto const &i: content) {
		column.push_back(i[index]);
	}
	return column;
}

vector<string> split (const string &s, char delim) {
    vector<string> result;
    stringstream ss (s);
    string item;
    while (getline (ss, item, delim)) {
        result.push_back (item);
    }
    return result;
}

int get_rows_val(list<string> content) {
	int index = 0;
	int sum_column = 0;
	for (auto row : content) {
		for (int i = 0; i < row.size(); i++) {
			if (row[i] == 'O' ) {
				sum_column += content.size() - index;
			}
		}
		index+=1;
	}
	return sum_column;
}

string rotate(string column, string direction) {
	vector<string> splitted = split (column, '#');
	int index = 0;
	string reconstructed_line;
	for (auto part : splitted) {
		if ( direction == "up" ) {
			for (int j = 0; j < part.size(); j++) {
				if (part[j] == 'O') {
					reconstructed_line.push_back('O');
				}
			}
			for (int j = 0; j < part.size(); j++) {
				if (part[j] == '.') {
					reconstructed_line.push_back('.');
				}
			}
		}
		if ( direction == "down" ) {
			for (int j = 0; j < part.size(); j++) {
				if (part[j] == '.') {
					reconstructed_line.push_back('.');
				}
			}
			for (int j = 0; j < part.size(); j++) {
				if (part[j] == 'O') {
					reconstructed_line.push_back('O');
				}
			}
		}
		if (reconstructed_line.size() != column.size()) {
			reconstructed_line.push_back('#');
		}
	}
	return reconstructed_line;
}

list<string> cycle(list<string> content) {
	list<string> north;
	list<string> west;
	list<string> south;
	list<string> east;
	for ( int i = 0; i < content.size(); i++ ) {
		north.push_back(rotate(take_col(content,i),"up"));
	}
	for ( int i = 0; i < north.size(); i++ ) {
		west.push_back(rotate(take_col(north,i),"up"));
	}
	for ( int i = 0; i < west.size(); i++ ) {
		south.push_back(rotate(take_col(west,i),"down"));
	}
	for ( int i = 0; i < south.size(); i++ ) {
		east.push_back(rotate(take_col(south,i),"down"));
	}
	return east;
}

int main() {
	fstream file;
	file.open("./assets/14.txt", ios::in);
	list<string> content;
	if (file.is_open()) {
		string data;
		while (getline(file,data,'\n')) {
			content.push_back(data);
		}
	}
	file.close();

	list<string> cycled = content;
	map<list<string>,int> states_hashmap;
	int eras = 0;

	while (states_hashmap.find(cycled) == states_hashmap.end()) {
		eras += 1;
		states_hashmap[cycled] = eras;
		cycled = cycle(cycled);
	}
	int begin_loop = states_hashmap[cycled] - 1;
	int value = 0;
	for (int i = 0; i < ((1000000000 - begin_loop) % (eras - begin_loop)); i++) {
		cycled = cycle(cycled);
	}
	value = get_rows_val(cycled);
	cout << value;
}


