class SharedDoorData {
  static final SharedDoorData _instance = SharedDoorData._internal();

  factory SharedDoorData() => _instance;

  SharedDoorData._internal();

  List<Map<String, String>> doors = [
    {"door": "Door 1", "status": "Available"},
    {"door": "Door 2", "status": "Occupied"},
    {"door": "Door 3", "status": "Available"},
    {"door": "Door 4", "status": "Occupied"},
  ];
}
