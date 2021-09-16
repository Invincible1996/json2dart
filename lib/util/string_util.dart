/// create by kevin
/// create at 2021-09-14
/// desc
///

class StringUtil {
  /// create by kevin
  /// create at 2021-09-14
  /// desc
  ///
  static String upperCaseFirstLetter(String str) {
    if (str.isNotEmpty) {
      return '${str[0].toUpperCase()}${str.substring(1)}';
    }
    return '';
  }

  /// create by kevin
  /// create at 2021-09-15
  /// desc
  ///
  static String formatVar(String text) {
    var splitList = text.split("_");

    var sb = StringBuffer();
    for (var i = 0; i < splitList.length; i++) {
      if (i > 0) {
        sb.write(StringUtil.upperCaseFirstLetter(splitList[i]));
        continue;
      }
      sb.write(splitList[i]);
    }
    return sb.toString();
  }
}
