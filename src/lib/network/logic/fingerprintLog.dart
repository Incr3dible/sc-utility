import 'dart:convert';

class FingerprintLog {
  List<Fingerprint> fingerprints = new List<Fingerprint>();

  void addFingerprint(String sha, String version) {
    if (fingerprints.indexWhere((f) => f.Sha == sha) > -1) return;

    fingerprints.add(new Fingerprint(sha, version));
  }

  void fromJson(String json) {
    if (json != null)
      (jsonDecode(json) as List).map((p) => Fingerprint.fromJson(p)).toList();
  }

  String saveToJson() {
    return jsonEncode(fingerprints);
  }
}

class Fingerprint {
  String Sha = "";
  String Version = "";

  Fingerprint(this.Sha, this.Version);

  Fingerprint.fromJson(Map<String, dynamic> json)
      : Sha = json['sha'],
        Version = json['version'];

  Map toJson() => {
        'sha': Sha,
        'version': Version,
      };
}
