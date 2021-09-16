/// create by kevin
/// create at 2021-09-15
/// desc
///
extension FormatString on String {
  /// @desc first letter to upperCase
  String get firstLetterToUpperCase {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// @desc replace _code to Code
  String get replaceUnderscoreToUpperCase {
    if (!contains('_')) return this;
    var splitList = split("_");

    var sb = StringBuffer();
    for (var i = 0; i < splitList.length; i++) {
      if (i > 0) {
        sb.write(splitList[i].firstLetterToUpperCase);
        continue;
      }
      sb.write(splitList[i]);
    }
    return sb.toString();
  }
}
