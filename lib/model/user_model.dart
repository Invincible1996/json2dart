class SS {
  String? studentUid;
  String? studentName;
  List<LessonContent>? lessonContent;
  SS({
    this.studentUid,
    this.studentName,
    this.lessonContent,
  });
  SS.fromJson(Map<String, dynamic> json) {
    studentUid = json['studentUid'];
    studentName = json['studentName'];
    if (json['lessonContent'] != null) {
      lessonContent = <LessonContent>[];
      json['lessonContent'].forEach((v) {
        lessonContent?.add(LessonContent.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentUid'] = studentUid;
    data['studentName'] = studentName;
    return data;
  }
}

class LessonContent {
  String? lessonUid;
  String? courseName;
  String? className;
  String? time;
  LessonContent({
    this.lessonUid,
    this.courseName,
    this.className,
    this.time,
  });
  LessonContent.fromJson(Map<String, dynamic> json) {
    lessonUid = json['lessonUid'];
    courseName = json['courseName'];
    className = json['className'];
    time = json['time'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lessonUid'] = lessonUid;
    data['courseName'] = courseName;
    data['className'] = className;
    data['time'] = time;
    return data;
  }
}
