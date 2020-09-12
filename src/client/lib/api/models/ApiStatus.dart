class ApiStatus {
  int totalApiRequests;
  int uptimeSeconds;
  bool maintenance;

  ApiStatus();

  ApiStatus.fromJson(Map<String, dynamic> json)
      : totalApiRequests = json["totalApiRequests"],
        uptimeSeconds = json["uptimeSeconds"],
        maintenance = json["maintenance"];
}
