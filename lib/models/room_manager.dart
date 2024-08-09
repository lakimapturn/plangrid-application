
class RoomManager {
  RoomManager._privateConstructor();

  static final RoomManager _instance =
  RoomManager._privateConstructor();

  factory RoomManager() {
    return _instance;
  }

  final Map<String, List<String>> _annotations = {};

  List<String> getAllRooms() {
    return _annotations.values.expand((annotations) => annotations).toList();
  }

  void addRoom(String key, String room) {
    if (!_annotations.containsKey(key)) {
      _annotations[key] = [];
    }
    _annotations[key]!.add(room);
  }

  List<String> getRoomsFromPage(String key) {
    return _annotations[key] ?? [];
  }
}
