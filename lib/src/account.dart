import 'request_builder.dart';
import 'auth.dart';

abstract class Account {
  String type;
  String id;

  RequestBuilder sign(RequestBuilder requestBuilder);

  static void fromJson(Account account, Map<String, dynamic> json) {
    account.type = json["type"]?.toString() ?? "";
    account.id = json["id"]?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    final output = Map<String, dynamic>();
    output["type"] = type;
    output["id"] = id;
    return output;
  }
}

abstract class OAuth2Account extends Account {
  String accessToken;

  String authorizeUrl();
  String callbackUrl();
  String secret();
  RequestBuilder oauthRequest();

  void requestAccessToken() {
    throw UnimplementedError("OAuth2 flow not implemented");
  }

  void setAuth(Auth auth) {
    accessToken = auth.access_token;
  }

  static void fromJson(OAuth2Account account, Map<String, dynamic> json) {
    Account.fromJson(account, json);
    account.accessToken = json["accessToken"]?.toString() ?? "";
  }

  @override
  Map<String, dynamic> toJson() {
    final output = super.toJson();
    output["accessToken"] = accessToken;
    return output;
  }
}
