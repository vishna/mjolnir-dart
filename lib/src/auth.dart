/// Generated file, DO NOT EDIT!!!
// ignore_for_file: strong_mode_implicit_dynamic_parameter
// ignore_for_file: strong_mode_implicit_dynamic_type
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: omit_local_variable_types
// ignore_for_file: prefer_final_locals
// ignore_for_file: sort_constructors_first
// ignore_for_file: directives_ordering
// ignore_for_file: avoid_init_to_null
// ignore_for_file: prefer_collection_literals
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: unnecessary_brace_in_string_interps
// ignore_for_file: implicit_dynamic_parameter
// ignore_for_file: implicit_dynamic_type

import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  /// members
  final String access_token;
  final String token_type;
  final int expires_in;
  final String refresh_token;

  /// ctor
  const Auth({
    this.access_token,
    this.token_type,
    this.expires_in,
    this.refresh_token,
  });

  /// factory
  factory Auth.fromJson(Map<dynamic, dynamic> json) {
    if (json == null) {
      return null;
    }
    String access_token;
    String token_type;
    int expires_in;
    String refresh_token;
    access_token = json['access_token']?.toString();
    token_type = json['token_type']?.toString();
    expires_in = json['expires_in'];
    refresh_token = json['refresh_token']?.toString();

    return Auth(
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
    return Auth(
        access_token: access_token ?? this.access_token,
        token_type: token_type ?? this.token_type,
        expires_in: expires_in ?? this.expires_in,
        refresh_token: refresh_token ?? this.refresh_token);
  }

  Map<dynamic, dynamic> toJson() {
    final output = Map<dynamic, dynamic>();

    output["access_token"] = access_token;
    output["token_type"] = token_type;
    output["expires_in"] = expires_in;
    output["refresh_token"] = refresh_token;

    return output;
  }

  static Auth Function(dynamic json) deserializer =
      ((json) => Auth.fromJson(json));

  @override
  List<Object> get props =>
      [access_token, token_type, expires_in, refresh_token];
}

DateTime _safeParse(String formattedString) {
  try {
    return DateTime.parse(formattedString);
  } catch (_) {
    return null;
  }
}
