class Notification {
  String id;
  String type;
  String notifiable_type;
  String data;
  bool read;
  DateTime createdAt;

  Notification();

  Notification.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      type = jsonMap['type'] != null ? jsonMap['type'].toString() : '';
      data = jsonMap['data'] != null ? jsonMap['data'].toString() : '';
      notifiable_type = jsonMap['notifiable_type'] != null ? jsonMap['notifiable_type'].toString() : '';
      read = jsonMap['read_at'] != null ? true : false;
      createdAt = DateTime.parse(jsonMap['created_at']);
    } catch (e) {
      id = '';
      type = '';
      notifiable_type = '';
      data = '';
      read = false;
      createdAt = new DateTime(0);
      print(e);
    }
  }

  Map markReadMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["read_at"] = !read;
    return map;
  }
}
