class SupercellUtil{
  static bool validateTag(String tag) {
    if (tag.length > 30 && tag.length < 3) return false;

    tag = tag.toUpperCase().replaceAll("#", "");
    var charArray = tag.split("");
    var isValid = true;

    for (var t in charArray) if (!"0289PYLQGRJCUV".contains(t)) isValid = false;

    return isValid;
  }

  static int getIdFromTag(String tag) {
    var tagArray = tag.toUpperCase().replaceAll("#", "").split("");

    int id = 0;

    for (var t in tagArray) {
      var i = "0289PYLQGRJCUV".indexOf(t);

      id *= 14;
      id += i;
    }

    var high = id % 256;
    var low = (id - high) >> 8;

    return (high << 32) | (low & 0xFFFFFFFF);
  }

  static String getTagFromId(int id) {
    var tag = "";
    var highInt = id >> 32;
    if (highInt > 255) return tag;

    var lowInt = id & 0xFFFFFFFF;

    id = (lowInt << 8) + highInt;
    while (id != 0) {
      var index = id % 14;
      tag = "0289PYLQGRJCUV"[index] + tag;

      id ~/= 14;
    }

    tag = "#" + tag;

    return tag;
  }
}