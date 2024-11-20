import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json2dart/extension/string_extension.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'JSON to Dart Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'JSON to Dart Converter'),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Input JSON',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 450,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      maxLines: null,
                      controller: contentController,
                      style: TextStyle(
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Paste your JSON here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Class Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: classNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter class name',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    try {
                      list.clear();
                      createClass(
                        contentController.text,
                        classNameController.text.isNotEmpty
                            ? classNameController.text.firstLetterToUpperCase
                            : 'Model',
                      );
                      setState(() {});
                    } catch (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Invalid JSON format'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Convert',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: renderText(list)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Copy to Clipboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: list.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.all(24.0),
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      renderText(list),
                      style: TextStyle(
                        height: 1.8,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
        createClass(
            json.encode(value), '${key[0].toUpperCase()}${key.substring(1)}');
        temVar.write("""${key[0].toUpperCase()}${key.substring(1)}? $tempKey;\n""");
        otherCs.write("""
        $tempKey = json['$key'] != null 
            ? ${key[0].toUpperCase()}${key.substring(1)}.fromJson(json['$key'])
            : null;""");
        toJsonVar.write("""
        if ($tempKey != null) {
          dataMap['$key'] = $tempKey?.toJson();
        }""");
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
            generic = createClass(json.encode(value[0]),
                '${key[0].toUpperCase()}${key.substring(1)}');
          }
        }

        temVar.write("""List<$generic>? $tempKey;\n""");

        // List数据初始化
        // 别名构造函数处理数组的格式
        var listStr = """
        if (json['$key'] != null) {
          $tempKey = <$generic>[];
          json['$key'].forEach((v) {
            $tempKey?.add($generic.fromJson(v));
          });
        }""";
        otherCs.write(listStr);
        
        toJsonVar.write("""
        if ($tempKey != null) {
          dataMap['$key'] = $tempKey?.map((v) => v.toJson()).toList();
        }""");
      }
      csVar.write('this.$tempKey,');
    });

    var result = StringBuffer();

    result.write("""
class $className {
  $temVar
  $className({
    $csVar
  });

  $className.fromJson(Map<String, dynamic> json) {
    $otherCs
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    $toJsonVar
    return dataMap;
  }
}
""");

    list.add(result.toString());
    // logger.v(result.toString());

    return className;
  }
}
