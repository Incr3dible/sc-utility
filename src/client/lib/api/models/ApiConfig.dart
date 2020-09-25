class ApiConfig {
  bool maintenance;
  bool globalLiveMode;

  ApiConfig();

  ApiConfig.fromJson(Map<String, dynamic> json)
      : maintenance = json["maintenance"],
        globalLiveMode = json["globalLiveMode"];

  Map<String, dynamic> toJson() =>
      {"maintenance": maintenance, "globalLiveMode": globalLiveMode};
}
