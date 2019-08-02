class Auth {
  // members
  String access_token;
  String token_type;
  int expires_in;
  String refresh_token;

  // ctor
  Auth._({
    this.access_token,
    this.token_type,
    this.expires_in,
    this.refresh_token,
  });

  // factory
  factory Auth.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    dynamic access_token = json['access_token'];
    dynamic token_type = json['token_type'];
    dynamic expires_in = json['expires_in'];
    dynamic refresh_token = json['refresh_token'];

    return Auth._(
        access_token: access_token,
        token_type: token_type,
        expires_in: expires_in,
        refresh_token: refresh_token);
  }

  Auth copyWith(
      {String access_token,
      String token_type,
      int expires_in,
      String refresh_token}) {
    return Auth._(
        access_token: access_token ?? this.access_token,
        token_type: token_type ?? this.token_type,
        expires_in: expires_in ?? this.expires_in,
        refresh_token: refresh_token ?? this.refresh_token);
  }

  Map<String, dynamic> toJson() {
    final output = Map<String, dynamic>();

    output["access_token"] = access_token;
    output["token_type"] = token_type;
    output["expires_in"] = expires_in;
    output["refresh_token"] = refresh_token;

    return output;
  }

  static Auth Function(dynamic json) deserializer =
      ((json) => Auth.fromJson(json));
}
