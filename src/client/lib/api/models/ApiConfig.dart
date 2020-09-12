class ApiConfig {
  bool maintenance;

  ApiConfig();

  ApiConfig.fromJson(Map<String, dynamic> json)
      : maintenance = json["maintenance"];

  Map<String, dynamic> toJson() => {"maintenance": maintenance};
}
