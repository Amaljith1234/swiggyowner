import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'AppUtils.dart';

class NetworkUtil {

  static String? token;

  static String base_url = "http://13.126.146.173:4000/";

  static String owner_login_url = "owner/login";

  static String owner_signUp_url = "owner/signup";


  static String HOTEL_DETAILS_ADD_URL = "owner/profile/restaurant-details";

  static String BANK_DETAILS_ADD_URL = "owner/profile/bank-details";


  static String GET_FOOD_LIST_URL = "owner/profile/food-list/1/10";

  static String ADD_FOOD_ITEM_URL = "owner/profile/add-food";

  static String FETCH_FOOD_ITEMS_URL = "owner/profile/food-list/1/10";

  static String DELETE_FOOD_ITEM_URL = 'owner/profile/remove-food-item';

  static String UPDATE_FOOD_ITEM_URL = 'owner/profile/update-food-item';


  static String PROFILE_DETAILS_URL = "owner/profile/details";

  static String BANK_DETAILS_URL = "owner/profile/bank-details";

  static String RESTAURENT_DETAILS_URL = "owner/profile/restaurant-details";


  static String ORDER_LIST_URL = "user/ordering/owner/list/1/10";

  static String PREPARE_ORDER_URL = "user/ordering/prepare";

  static String COMPLETE_ORDER_URL = "user/ordering/owner-completed-the-order";


  static String CHANGE_PASSWORD_URL = 'owner/profile/change-password';

  static String FORGOT_PASSWORD_URL = 'owner/profile/forgot-password';

  static String RESET_PASSWORD_WITH_OTP_URL = 'owner/profile/reset-password';


  static Future<http.Response> get(String uri,
      {Map<String, dynamic>? body}) async {
    try {
      token = await AppUtil.getToken();
      Map<String, String> headers = {};
      if (token != null) {
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          HttpHeaders.authorizationHeader: 'Bearer ' + token!
        };
      } else {
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          // 'Accept': 'application/json'
        };
      }

      debugPrint(headers.toString());

      var url;
      if (body != null) {
        String queryString = Uri(queryParameters: body).query;
        var requestUrl = base_url + uri + '?' + queryString;
        debugPrint(requestUrl);
        url = Uri.parse(requestUrl);
      } else {
        url = Uri.parse(base_url + uri);
      }
      final response = await http.get(url, headers: headers);

      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }

  static Future<http.Response> post(String uri, {body}) async {
    try {
      token = await AppUtil.getToken();
      debugPrint("Token retrieved: " + (token ?? "No token found"));
      Map<String, String> headers = {};
      if (token != null) {
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          HttpHeaders.authorizationHeader: 'Bearer ' + token!
        };
      } else {
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          // 'Accept': 'application/json'
        };
      }
      debugPrint(headers.toString());
      var url = Uri.parse(base_url + uri);
      debugPrint(body.toString());
      final response = await http.post(url, headers: headers, body: body);
      return response;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw const FormatException("Unable to process the data");
    } catch (e) {
      throw e;
    }
  }

}

const String PLACES_API_KEY = "AIzaSyBqpg1fgJ9dgCRJPZLIh-Qug-e_MqgWty8";