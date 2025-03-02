import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Set up the base URL for your API
// const String API_BASE_URL = "https://api.thesafedecision.com/api";

import 'package:car/utils/config.dart'; // Assurez-vous que ce fichier existe et contient la configuration de base URL

final String API_BASE_URL = Config.BASE_URL;

// Helper function to get the token from local storage
String getToken() {
  // Utilisez un package comme `shared_preferences` pour stocker et récupérer le token
  // Exemple: return prefs.getString('token') ?? '';
  return ''; // Remplacez par la logique pour récupérer le token
}

// Generic method for making API calls
Future<dynamic> apiCall(String method, String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers, String contentType = 'application/json'}) async {
  // Get the token from local storage
  String token = getToken();

  // Set up the URL
  Uri url = Uri.parse('$API_BASE_URL$endpoint');

  // Set up the headers
  Map<String, String> defaultHeaders = {
    'Authorization': token.isNotEmpty ? 'Bearer $token' : '',
    'Content-Type': contentType,
  };

  if (headers != null) {
    defaultHeaders.addAll(headers);
  }

  try {
    http.Response response;

    switch (method.toLowerCase()) {
      case 'get':
        response = await http.get(url, headers: defaultHeaders);
        break;
      case 'post':
        response = await http.post(url, headers: defaultHeaders, body: jsonEncode(data));
        break;
      case 'put':
        response = await http.put(url, headers: defaultHeaders, body: jsonEncode(data));
        break;
      case 'delete':
        response = await http.delete(url, headers: defaultHeaders);
        break;
      default:
        throw Exception('Method not supported');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (error) {
    debugPrint('API call error: $error');
    throw error;
  }
}

// POST request
Future<dynamic> post(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers, String contentType = 'application/json'}) async {
  return apiCall('post', endpoint, data: data, headers: headers, contentType: contentType);
}

// GET request
Future<dynamic> get(String endpoint, {Map<String, String>? headers, String contentType = 'application/json'}) async {
  return apiCall('get', endpoint, headers: headers, contentType: contentType);
}

// PUT request
Future<dynamic> put(String endpoint, {Map<String, dynamic>? data, Map<String, String>? headers, String contentType = 'application/json'}) async {
  return apiCall('put', endpoint, data: data, headers: headers, contentType: contentType);
}

// DELETE request
Future<dynamic> delete(String endpoint, {Map<String, String>? headers, String contentType = 'application/json'}) async {
  return apiCall('delete', endpoint, headers: headers, contentType: contentType);
}