/// create by kevin
/// create at 2021-09-15
/// desc
///
import 'dart:convert';
import 'package:json2dart/util/string_util.dart';
import '../main.dart';

class Json2dartUtil {
  /// create by kevin
  /// create at 2021-09-14
  /// desc
  ///
  static createClass(String jsonData, String className) {
    var map = json.decode(jsonData);

    // 变量名
    var temVar = StringBuffer();

    // 构造函数中的变量值
    var csVar = StringBuffer();

    // 别名构造
    var otherCs = StringBuffer();

    map.forEach((String key, value) {
      // logger.v(value is Map);

      if (value is String) {
        temVar.write('String? $key;\n');
        otherCs.write('$key =json[\'$key\'];\n');
      } else if (value is int) {
        otherCs.write('        $key =json[\'$key\'];\n');
        temVar.write('      int? $key;\n');
      } else if (value is Map) {
        //创建实体类
        createClass(
            json.encode(value), '${key[0].toUpperCase()}${key.substring(1)}');
        temVar
            .write('      ${key[0].toUpperCase()}${key.substring(1)}? $key;\n');
        otherCs.write(
            '        $key = json[$key] != null? ${StringUtil.upperCaseFirstLetter(key)}.fromJson(json[$key]):null;');
      } else if (value is List) {
        // 判断数组中第一个元素的类型
        // 确定List泛型
        var generic = '';
        if (value.isNotEmpty) {
          // 判断类型
          if (value[0] is int) {
            generic = 'int';
          } else if (value[0] is double) {
            generic = 'double';
          } else if (value[0] is Map) {
            generic = createClass(
                json.encode(value[0]), StringUtil.upperCaseFirstLetter(key));
          }
          //
        }

        temVar.write('      List<$generic>? $key;\n');

        // List数据初始化
        // 别名构造函数处理数组的格式
        var listStr = '''if(json[$key]!=null ){
         $key = <$generic>[];
         json[$key].forEach((v) {
           $key?.add($generic.fromJson(v));
           });
        }''';
        otherCs.write(listStr);
      }
      csVar.write('this.$key,');
    });
    var result = '''class $className {
      $temVar
      $className({$csVar});

      $className.fromJson(Map<String, dynamic> json){
      $otherCs\n    } 
      }''';
    // list.add(result);
    logger.v(result);

    return className;
  }
}
