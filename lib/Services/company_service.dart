import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_projects/Models/company.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class CompanyService{
  String baseUrl = "https://retoolapi.dev/8ATKB5/company";
  final Logger logger = Logger('CompanyService');

  Future<List<Company>> getAllCompanies() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        return await compute(_parseCompanies, response.body);
      } else {
        throw Exception(
            "Error ${response.statusCode}: ${response.body}");
      }
    } catch (e, stacktrace) {
      logger.severe("Failed to fetch companies", e, stacktrace);
      return [];
    }
  }

  List<Company> _parseCompanies(String responseBody) {
    final List<dynamic> jsonData = jsonDecode(responseBody);
    return jsonData.map((c) => Company.fromJson(c)).toList();
  }

  createCompany(Company company) async{
    try{
      var response = await http.post(Uri.parse(baseUrl), body: company.toJson());
      if(response.statusCode == 201 || response.statusCode == 200){}
      else{
        throw Exception("Error occured: \n Status Code: ${response.statusCode} \n Message: ${response.body}");
      }
    }
    catch(e, stacktrace){
      logger.severe("Failed to fetch companies", e, stacktrace);
    }
  }

  updateCompany(Company company, int id) async{
    try{
      var response = await http.put(Uri.parse(baseUrl + "/$id"), body: company.toJson());
      if(response.statusCode == 201 || response.statusCode == 200){}
      else{
        throw Exception("Error occured: \n Status Code: ${response.statusCode} \n Message: ${response.body}");
      }
    }
    catch(e, stacktrace){
      logger.severe("Failed to fetch companies", e, stacktrace);
    }
  }

  deleteCompany(int id) async{
    try{
      var response = await http.delete(Uri.parse(baseUrl + "/$id"));
      if(response.statusCode == 204 || response.statusCode == 200){}
      else{
        throw Exception("Error occured: \n Status Code: ${response.statusCode} \n Message: ${response.body}");
      }
    }
    catch(e, stacktrace){
      logger.severe("Failed to fetch companies", e, stacktrace);
    }
  }
}