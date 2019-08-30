import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'pagination.dart';
import 'package:flutter/foundation.dart';

import 'path_declutter.dart';
import 'account.dart';
import 'package:dio/dio.dart';
import 'request_compute.dart';

enum RequestMethod { get, put, delete, post, patch }

bool isEmpty(String value) => (value == null || value.length == 0);

class RequestBuilder {
  String host;
  String path;
  String listOf_;
  String objectOf_;
  PathDeclutter declutter;

  final params = new Map<String, StringWrapper>();
  final headers = new Map<String, String>();
  final files = new Map<String, String>();
  final meta = new Map<String, String>();

  Account account;
  RequestMethod method = RequestMethod.get;
  String content;
  String content_type;
  Pagination pagination;
  FormData formData;
  ProgressCallback onSendProgress;
  ProgressCallback onReceiveProgress;

  RequestBuilder();

  RequestBuilder jsonpath(String jsonpath) {
    declutter = PathDeclutter.fromPath(jsonpath);
    return this;
  }

  RequestBuilder withFormData(FormData formData) {
    this.formData = formData;
    return this;
  }

  RequestBuilder withReceiveProgress(ProgressCallback callback) {
    this.onReceiveProgress = callback;
    return this;
  }

  RequestBuilder withSendProgress(ProgressCallback callback) {
    this.onSendProgress = callback;
    return this;
  }

  RequestBuilder withAccount(Account account) {
    this.account = account;
    return this;
  }

  RequestBuilder withPagination(Pagination pagination) {
    this.pagination = pagination;
    return this;
  }

  bool get hasPagination => pagination != null;

  RequestBuilder fetchFront(dynamic info) {
    if (pagination != null) {
      pagination.fetchFront(this, info);
    }
    return this;
  }

  RequestBuilder fetchBack(dynamic info) {
    if (pagination != null) {
      pagination.fetchBack(this, info);
    }
    return this;
  }

  RequestBuilder sign() {
    if (account != null) {
      return account.sign(this);
    }
    return this;
  }

  RequestBuilder get() {
    method = RequestMethod.get;
    return this;
  }

  RequestBuilder put() {
    method = RequestMethod.put;
    return this;
  }

  RequestBuilder delete() {
    method = RequestMethod.delete;
    return this;
  }

  RequestBuilder post() {
    method = RequestMethod.post;
    return this;
  }

  RequestBuilder patch() {
    method = RequestMethod.patch;
    return this;
  }

  String methodToString() {
    switch (method) {
      case RequestMethod.post:
        return "POST";
      case RequestMethod.put:
        return "PUT";
      case RequestMethod.delete:
        return "DELETE";
      case RequestMethod.patch:
        return "PATCH";
      case RequestMethod.get:
      default:
        return "GET";
    }
  }

  RequestBuilder setContent(String content, String content_type) {
    this.content = content;
    this.content_type = content_type;
    return this;
  }

//  RequestBuilder setJsonContent(JSONObject jsonContent) {
//    this.content = jsonContent.toString();
//    this.content_type = "application/json; charset=utf-8";
//    return this;
//  }

  RequestBuilder header(String key, String value) {
    headers[key] = value;
    return this;
  }

  RequestBuilder setMeta(String key, String value) {
    meta[key] = value;
    return this;
  }

  RequestBuilder setMetaTag(String value) {
    meta["tag"] = value;
    return this;
  }

  String getMetaTag() {
    return meta["tag"];
  }

  RequestBuilder param(String key, dynamic value) {
    if (value == null) return this;
    String strValue = value.toString();
    if (isEmpty(strValue)) return this;
    params[key] = StringWrapper(value: strValue, encoded: false);
    return this;
  }

  RequestBuilder paramEncoded(String key, String value) {
    if (isEmpty(value)) return this;
    params[key] = StringWrapper(value: value, encoded: true);
    return this;
  }

  RequestBuilder addAllParams(Map<String, String> otherParams) {
    otherParams.forEach((key, value) => param(key, value));
    return this;
  }

  RequestBuilder setDeclutter(PathDeclutter declutter) {
    this.declutter = declutter;
    return this;
  }

  String toQuery() {
    final pairs = List<String>();

    params.forEach((key, value) {
      pairs.add("${Uri.encodeComponent(key)}=${value.toString()}");
    });

    return pairs.join("&");
  }

  String toUrl() {
    final sb = StringBuffer();
    sb.write(host);
    sb.write(path);
    if (params.length > 0 &&
        method != RequestMethod.put &&
        method != RequestMethod.post) {
      sb.write("?");
      sb.write(toQuery());
    }
    return sb.toString();
  }

  String toRequestKey() {
    final sb = StringBuffer();
    sb.write(";");
    sb.write(host);
    sb.write(";");
    sb.write(path);
    sb.write(";");
    sb.write(toQuery());
    sb.write(";");
    if (account != null) {
      sb.write(account.id ?? "");
      sb.write(";");
      sb.write(account.type ?? "");
      sb.write(";");
    }
    return sb.toString();
  }

  Future<Response> asResponse({Dio client}) {
    if (client == null) {
      client = _client();
    }

    sign();

    RequestOptions requestOptions = RequestOptions(
        headers: headers,
        method: methodToString(),
        responseType: ResponseType.plain // it's by default parsed
        );

    dynamic _data = this;

    switch (method) {
      case RequestMethod.delete:
      case RequestMethod.get:
        {
          // NO-OP
          break;
        }
      case RequestMethod.patch:
      case RequestMethod.put:
      case RequestMethod.post:
        {
          if (formData != null) {
            _data = formData;
          } else {
            requestOptions.contentType =
                _MjonirPostTransformer.requestBuilderType;
          }
          break;
        }
      default:
        throw UnimplementedError("Method $method not implemented yet");
    }

    return client.request(toUrl(),
        data: _data,
        options: requestOptions,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }

  RequestCompute makeRequestCompute(dynamic data) {
    throw UnimplementedError(
        "implement this method by extending RequestBuilder class");
  }

  Future<MjolnirResponse<Map<String, dynamic>>> plainJson() {
    Response _response;

    return asResponse()
        .then((response) => compute(_parsePlainJson, response.data.toString()))
        .then((computation) => MjolnirResponse<Map<String, dynamic>>(
            data: computation, response: _response, requestBuilder: this))
        .catchError((error) => MjolnirResponse<Map<String, dynamic>>(
            error: error, response: _response, requestBuilder: this));
  }

  Future<MjolnirResponse<T>> objectOf<T>({String type}) {
    this.objectOf_ = type ?? this.objectOf_;

    if (objectOf_ == null) {
      objectOf_ = _typeOf<T>().toString();
    }

    assert(objectOf_ != null);

    Response _response;

    return asResponse()
        .then((response) {
          _response = response;
          return makeRequestCompute(response.data);
        })
        .then((requestCompute) => compute(_parseResponseObject, requestCompute))
        .then((computation) => MjolnirResponse<T>(
            data: computation, response: _response, requestBuilder: this))
        .catchError((error) => MjolnirResponse<T>(
            error: error, response: _response, requestBuilder: this));
  }

  Future<MjolnirResponse<List<T>>> listOf<T>({String type}) {
    this.listOf_ = type ?? this.listOf_;

    if (listOf_ == null) {
      String t = _typeOf<T>().toString();

      if (t != "dynamic") {
        listOf_ = t;
      }
    }

    assert(listOf_ != null);

    Response _response;

    return asResponse()
        .then((response) {
          _response = response;
          return makeRequestCompute(response.data);
        })
        .then((requestCompute) => compute(_parseResponseList, requestCompute))
        .then((computation) => MjolnirResponse<List<T>>(
            data: List<T>.from(computation),
            response: _response,
            requestBuilder: this))
        .catchError((error) => MjolnirResponse<List<T>>(
            error: error, response: _response, requestBuilder: this));
  }

  /// Necessary to obtain generic [Type]
  /// https://github.com/dart-lang/sdk/issues/11923
  static Type _typeOf<T>() => T;

  static void setClientSingleton(Dio value) {
    _clientSingleton = value;
  }
}

Map<String, dynamic> _parsePlainJson(String body) {
  return json.decode(body) as Map<String, dynamic>;
}

dynamic _parseResponseObject(RequestCompute requestCompute) {
  var responseJSON = (json.decode(requestCompute.body) as Map<String, dynamic>);
  final jsonResponse =
      requestCompute.declutter?.jsonPath(responseJSON) ?? responseJSON;
  final deserializer =
      requestCompute.deserializerByClassName(requestCompute.objectOf_);
  return deserializer(jsonResponse);
}

List<dynamic> _parseResponseList(RequestCompute requestCompute) {
  var responseJSON = (json.decode(requestCompute.body) as Map<String, dynamic>);
  final jsonResponse =
      requestCompute.declutter?.jsonPath(responseJSON) ?? responseJSON;
  final deserializer =
      requestCompute.deserializerByClassName(requestCompute.listOf_);

  return jsonResponse.map(deserializer).toList();
}

class StringWrapper {
  final String value;
  final bool encoded;

  StringWrapper({this.value, this.encoded = false});

  @override
  String toString() {
    return encoded ? value : Uri.encodeComponent(value);
  }
}

Dio _clientSingleton;
Dio _client() {
  if (_clientSingleton == null) {
    final options = BaseOptions(
      connectTimeout: 20 * 1000,
      receiveTimeout: 30 * 1000,
    );

    _clientSingleton = new Dio(options);
    _clientSingleton.transformer = _MjonirPostTransformer();
  }
  return _clientSingleton;
}

class _MjonirPostTransformer extends DefaultTransformer {
  static final requestBuilderType =
      ContentType.parse("application/x-www-form-urlencoded;charset=UTF-8");

  @override
  Future<String> transformRequest(RequestOptions options) {
    if (options.contentType.value == requestBuilderType.value &&
        options.data is RequestBuilder) {
      return Future.sync(() => (options.data as RequestBuilder).toQuery());
    } else {
      return super.transformRequest(options);
    }
  }
}

class MjolnirResponse<T> {
  final T data;
  final dynamic error;
  final Response response;
  final RequestBuilder requestBuilder;

  MjolnirResponse({this.data, this.error, this.response, this.requestBuilder});

  bool get isSuccessful {
    return data != null && error == null;
  }
}
