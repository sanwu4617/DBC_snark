#include <iostream>
#include <string>
#include <unordered_map>

string hexToBinary(const string& hexString) {
    // 创建一个映射表，将十六进制字符映射为对应的4位二进制字符串
    unordered_map<char, string> hexToBinMap = {
        {'0', "0000"}, {'1', "0001"}, {'2', "0010"}, {'3', "0011"},
        {'4', "0100"}, {'5', "0101"}, {'6', "0110"}, {'7', "0111"},
        {'8', "1000"}, {'9', "1001"}, {'A', "1010"}, {'B', "1011"},
        {'C', "1100"}, {'D', "1101"}, {'E', "1110"}, {'F', "1111"},
        {'a', "1010"}, {'b', "1011"}, {'c', "1100"}, {'d', "1101"},
        {'e', "1110"}, {'f', "1111"}
    };

    string binaryString;

    // 遍历十六进制字符串，逐个字符转换为二进制字符串
    for (char c : hexString) {
        if (hexToBinMap.find(c) != hexToBinMap.end()) {
            binaryString += hexToBinMap[c];
        } else {
            cerr << "Invalid hexadecimal character: " << c << endl;
            return "";
        }
    }

    // 去掉前导零（可选）
    auto firstOne = binaryString.find('1');
    if (firstOne != string::npos) {
        binaryString = binaryString.substr(firstOne);
    }

    return binaryString;
}

int main() {
    string hexString;
    cout << "请输入十六进制字符串: ";
    cin >> hexString;

    string binaryString = hexToBinary(hexString);
    if (!binaryString.empty()) {
        cout << "十六进制字符串 " << hexString << " 转换为二进制字符串为: " << binaryString << endl;
    }

    return 0;
}