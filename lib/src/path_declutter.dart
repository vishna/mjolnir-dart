class PathDeclutter {
  final List<String> keys;

  PathDeclutter(this.keys);

  factory PathDeclutter.fromPath(String path) {
    final keys = new List<String>();
    for (String node in path.split(".")) {
      keys.add(node);
    }
    return PathDeclutter(keys);
  }

  dynamic jsonPath(Map<dynamic, dynamic> input) {
    dynamic output = input;
    for (int i = 0; i < keys.length; i++) {
      output = output[keys[i]];
    }
    return output;
  }
}
