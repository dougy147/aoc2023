#include <iostream>
#include <fstream>
#include <list>
#include <vector>
#include <sstream>

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

int get_col_val(string column) {
	vector<string> splitted = split (column, '#');
	int index = 0;
	string reconstructed_line;
	for (auto part : splitted) {
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
		if (reconstructed_line.size() != column.size()) {
			reconstructed_line.push_back('#');
		}
	}
	int sum_column = 0;
	for (int i = 0; i < reconstructed_line.size(); i++) {
		if (reconstructed_line[i] == 'O' ) {
			sum_column += reconstructed_line.size() - i;
		}
	}
	return sum_column;
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

	int sum = 0;
	for (int i = 0; i < content.size(); i++) {
		sum += get_col_val(take_col(content,i));
	}
	cout << sum;
}


