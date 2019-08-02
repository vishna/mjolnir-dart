import 'request_builder.dart';
import 'path_declutter.dart';

class RequestCompute {
  final String body;
  String listOf_;
  String objectOf_;
  PathDeclutter declutter;

  RequestCompute(this.body, RequestBuilder requestBuilder) {
    listOf_ = requestBuilder.listOf_;
    objectOf_ = requestBuilder.objectOf_;
    declutter = requestBuilder.declutter;
  }

  dynamic Function(dynamic json) deserializerByClassName(String className) {
    throw UnimplementedError(
        "implement deserializerByClassName in overriding class");
  }
}
