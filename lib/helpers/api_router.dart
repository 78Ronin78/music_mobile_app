import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:convert';

class ApiRouter {
  static Future sendRequest({
    Map requestBody,
    Map<String, String> requestParams,
    @required String method,
    @required String path,
  }) async {
    String urlApi = 'vm2413085.32ssd.had.wf';
    var client = new http.Client();
    Uri uri;
    var response;

    switch (method) {
      case 'post':
        uri = Uri.http(urlApi, '$path');
        print('POST: $uri');
        print('BODY: ' + requestBody.toString());
        response = await client.post(
          uri,
          body: requestBody,
        );
        break;
      case 'get':
        uri = Uri.http(urlApi, '$path', requestParams);
        print('GET: $uri');
        response = await client.get(
          uri,
        );
        break;
      case 'put':
        uri = Uri.https(urlApi, '$path', requestParams);
        print('PUT: $uri');
        response = await client.put(
          uri,
          body: json.encode(requestBody),
        );
        break;
      case 'patch':
        uri = Uri.https(urlApi, '$path', requestParams);
        print('PATCH: $uri');
        response = await client.patch(
          uri,
          body: json.encode(requestBody),
        );
        break;
      case 'delete':
        uri = Uri.http(urlApi, '$path', requestParams);
        print('DELETE: $uri');
        print('BODY: ' + requestBody.toString());
        response = await client.delete(
          uri,
        );
        break;

      default:
        break;
    }
    try {
      log(response.body);
      return response.body;
    } catch (e) {
      print('request body error: $e');
      return null;
    }
  }
}
