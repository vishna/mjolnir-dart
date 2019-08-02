import 'request_builder.dart';

abstract class Pagination {
  void fetchFront(RequestBuilder rb, dynamic info);
  void fetchBack(RequestBuilder rb, dynamic info);
}
