import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:json2dart/extension/string_extension.dart';
import 'package:json2dart/util/string_util.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(
      methodCount: 0,
      // number of method calls to be displayed
      errorMethodCount: 8,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false // Should each log print contain a timestamp
      ),
);

var formatter = DartFormatter();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Json to Dart with nullsafety'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController contentController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  ScrollController controller = ScrollController();

  var result = '';
  var list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  height: 450,
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        width: 1,
                        color: const Color(0XFFE6E6E6),
                      )),
                  child: TextField(
                    maxLines: null,
                    controller: contentController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        hintText: '请输入需要转换的json',
                        border: InputBorder.none),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  // height: 200,
                  child: TextField(
                    controller: classNameController,
                    decoration: const InputDecoration(
                      label: Text('请输入class名称'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  width: 1,
                  color: Color(0XFFE6E6E6),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50)),
                  onPressed: () {
                    try {
                      list.clear();
                      createClass(
                          contentController.text,
                          classNameController.text.isNotEmpty
                              ? classNameController.text.firstLetterToUpperCase
                              : 'Model');
                      setState(() {});
                    } catch (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('json 格式不对')));
                    }
                  },
                  child: const Text(
                    '转 换',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: renderText(list)));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('复制成功')));
                  },
                  child: const Text(
                    '复制到剪切板',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      renderText(list),
                      style: const TextStyle(height: 1.8),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// create by kevin
  /// create at 2021-09-15
  /// desc  render text and format
  String renderText(List list) {
    var tempText = '';
    for (var element in list.reversed.toList()) {
      tempText += element;
    }

    // return tempText;
    return formatter.format(tempText);
  }

  /// create by kevin
  /// create at 2021-09-14
  /// desc
  ///
  createClass(String jsonData, String className) {
    var map = json.decode(jsonData);

    // 变量名
    var temVar = StringBuffer();

    // 构造函数中的变量值
    var csVar = StringBuffer();

    // 别名构造
    var otherCs = StringBuffer();

    //toJson
    var toJsonVar = StringBuffer();

    map.forEach((String key, value) {
      // logger.v(value is Map);

      final tempKey = key.replaceUnderscoreToUpperCase;

      if (value is String) {
        temVar.write('String? $tempKey;\n');
        otherCs.write('$tempKey =json[\'$key\'];\n');
        toJsonVar.write('dataMap[\'$key\'] = $tempKey;');
      } else if (value is bool) {
        temVar.write('bool? $tempKey;\n');
        otherCs.write('$tempKey =json[\'$key\'];\n');
        toJsonVar.write('dataMap[\'$key\'] = $tempKey;');
      } else if (value is int) {
        otherCs.write('$tempKey =json[\'$key\'];\n');
        temVar.write('int? $tempKey;\n');
        toJsonVar.write('dataMap[\'$key\'] = $tempKey;');
      } else if (value is double) {
        otherCs.write('$tempKey =json[\'$key\'];\n');
        temVar.write('double? $tempKey;\n');
        toJsonVar.write('dataMap[\'$key\'] = $tempKey;');
      } else if (value is Map) {
        //创建实体类
        createClass(json.encode(value), key.firstLetterToUpperCase);
        temVar.write('${key.firstLetterToUpperCase}? $tempKey;\n');
        otherCs.write(
            '$tempKey = json[\'$key\'] != null? ${key.firstLetterToUpperCase}.fromJson(json[\'$key\']):null;');
        toJsonVar.write(
            'if($tempKey != null){dataMap[\'$key\']=$tempKey?.toJson();}');
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
          } else if (value[0] is bool) {
            generic = 'bool';
          } else if (value[0] is String) {
            generic = 'String';
          } else if (value[0] is Map) {
            generic =
                createClass(json.encode(value[0]), key.firstLetterToUpperCase);
          }
          //
        }

        temVar.write('List<$generic>? $key;\n');

        // List数据初始化
        // 别名构造函数处理数组的格式
        var listStr = '''if(json['$key'] != null ){
         $key = <$generic>[];
         json['$key'].forEach((v) {
           $key?.add($generic.fromJson(v));
           });
        }''';
        otherCs.write(listStr);
      }
      csVar.write('this.$tempKey,');
    });

    var result = StringBuffer();

    result.write('class $className {');
    result.write(temVar);
    result.write('$className({$csVar});');
    result.write('$className.fromJson(Map<String, dynamic> json){');
    result.write('$otherCs}');
    result.write('Map<String, dynamic> toJson() {');
    result.write('final Map<String, dynamic> dataMap = <String, dynamic>{};');
    result.write('$toJsonVar');
    result.write('return dataMap;');
    result.write('}}');

    list.add(result.toString());
    logger.v(result.toString());

    return className;
  }
}
