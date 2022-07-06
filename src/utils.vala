
string comma_long(long value) {
    string result = "";
    string value_s = value.to_string();
    for (int i = value_s.length - 3; i >= 0; i -= 3) {
        if (result == "") {
            result = value_s.substring(i, 3);
        } else {
            result = value_s.substring(i, 3) + "," + result;
        }
    }
    int rem = value_s.length % 3;
    if (rem > 0) {
        if (result.length > 0) {
            result = value_s.substring(0, rem) + "," + result;
        } else {
            result = value_s.substring(0, rem);
        }
    }

    return result;
}
