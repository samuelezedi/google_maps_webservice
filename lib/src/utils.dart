library google_maps_webservice.utils;

import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:http/http.dart';

const kGMapsUrl = 'https://maps.googleapis.com/maps/api';

abstract class GoogleWebService {
  @protected
  final Client _httpClient;

  @protected
  final String _url;

  @protected
  final String _apiKey;

  @protected
  final Map<String, dynamic> _apiHeaders;

  String get url => _url;

  Client get httpClient => _httpClient;

  String get apiKey => _apiKey;

  Map<String, dynamic> get apiHeaders => _apiHeaders;

  GoogleWebService({
    String apiKey,
    String baseUrl,
    @required String url,
    Client httpClient,
    Map<String, dynamic> apiHeaders,
  })  : assert(url != null),
        _url = '${baseUrl ?? kGMapsUrl}$url',
        _httpClient = httpClient ?? Client(),
        _apiKey = apiKey,
        _apiHeaders = apiHeaders;

  @protected
  String buildQuery(Map<String, dynamic> params) {
    final query = [];
    params.forEach((key, val) {
      if (val != null) {
        if (val is Iterable) {
          query.add("$key=${val.map((v) => v.toString()).join("|")}");
        } else {
          query.add('$key=${val.toString()}');
        }
      }
    });
    return query.join('&');
  }

  void dispose() => httpClient.close();

  @protected
  Future<Response> doGet(String url, {Map<String, dynamic> headers}) {
    Uri uri =
        Uri(scheme: url);
    return httpClient.get(uri, headers: headers);
  }

  @protected
  Future<Response> doPost(
    String url,
    String body, {
    Map<String, dynamic> headers,
  }) {
    final postHeaders = {
      'Content-type': 'application/json',
    };
    if (headers != null) postHeaders.addAll(headers);
    Uri uri =
        Uri(scheme: url);
    return httpClient.post(uri, body: body, headers: postHeaders);
  }
}

abstract class GoogleDateTime {
  @visibleForTesting
  @protected
  DateTime dayTimeToDateTime(int day, String time) {
    if (time.length < 4) {
      throw ArgumentError(
          "'time' is not a valid string. It must be four integers.");
    }

    final _now = DateTime.now();
    // Maps is 0-index DO^W
    final _weekday = _now.weekday - 1;
    final _mondayOfThisWeek = _now.day - _weekday;
    final _computedWeekday = _mondayOfThisWeek + day;

    final _hour = int.parse(time.substring(0, 2));
    final _minute = int.parse(time.substring(2));

    return DateTime.utc(
        _now.year, _now.month, _computedWeekday, _hour, _minute);
  }
}
