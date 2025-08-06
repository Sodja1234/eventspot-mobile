
import 'dart:convert';

import 'package:odc_mobile_template/business/models/article/event.dart';

import '../../business/models/user/authentication.dart';

import '../../business/models/user/interet.dart';
import '../../business/models/user/loginReponse.dart';
import '../../business/models/user/registerRequest.dart';
import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';
import '../utils/http/remoteHttpUtils.dart';



import 'package:http/http.dart' as http;

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }


  @override
  Future<User> seConnecter(Authentication authentication) async {
    final url = '$baseUrl/login';
    final req = authentication.toJson();

    print(' Données envoyées au backend : $req');

    try {
      final String responseBody = await httpUtils.postData(
        url,
        body: req,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(' Réponse brute : $responseBody');

      final decodedJson = jsonDecode(responseBody);


      if (decodedJson is Map<String, dynamic> &&
          decodedJson.containsKey('message') &&
          decodedJson.containsKey('errors')) {
        final errorMessage = decodedJson['message'];
        final errors = decodedJson['errors'];

        print(' Erreur du backend : $errorMessage');

        if (errors is Map<String, dynamic>) {
          errors.forEach((key, value) {
            print(' [$key] : ${(value as List).join(", ")}');
          });
        }

        throw Exception(errorMessage);
      }


      final loginResponse = LoginResponse.fromJson(decodedJson);
      print(' Utilisateur connecté : ${loginResponse.user.toJson()}');

      return loginResponse.user;
    } catch (e) {
      print(' Erreur lors de la connexion : $e');
      throw Exception('Connexion échouée : ${e.toString()}');
    }
  }


  @override
  Future<User> creerCompte(RegisterRequest registerRequest) async {
    final url = '$baseUrl/register';
    final req = registerRequest.toJson();

    print('Données d\'inscription envoyées : $req');

    try {
      final String responseBody = await httpUtils.postData(
        url,
        body: req,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final decodedJson = jsonDecode(responseBody);

      if (decodedJson['error'] != null) {
        throw Exception(decodedJson['message'] ?? 'Erreur lors de l\'inscription');
      }

      final loginResponse = LoginResponse.fromJson(decodedJson);
      print('Compte créé avec succès : ${loginResponse.user.toJson()}');
      return loginResponse.user;
    } catch (e) {
      print('Erreur création de compte : $e');
      throw Exception('Échec de l\'inscription : ${e.toString()}');
    }
  }

  @override
  Future<User> seDeconnecter() {
    // TODO: implement seDeconnecter
    throw UnimplementedError();
  }

  @override
  Future<List<Interet>> getInterets() async {
    final url = '$baseUrl/interet';

    try {
      final responseBody = await httpUtils.getData(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final decodedJson = jsonDecode(responseBody);
      if (decodedJson is List) {
        return decodedJson.map((e) => Interet.fromJson(e)).toList();
      } else {
        throw Exception('Réponse inattendue du serveur');
      }
    } catch (e) {
      print('Erreur lors du chargement des centres d’intérêt : $e');
      throw Exception('Impossible de charger les centres d’intérêt');
    }
  }

  @override
  Future<bool> verifierOtp({required String email, required String otp}) async {
    final url = '$baseUrl/verify';
    final body = {
      'email': email,
      'otp': otp,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      //  Vérifie simplement si le code HTTP est 200 (succès)
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('Vérification réussie : ${decoded['message']}');
        return true;
      } else {
        final decoded = jsonDecode(response.body);
        print('Erreur OTP : ${decoded['message']}');
        return false;
      }
    } catch (e) {
      print('Erreur lors de la vérification OTP : $e');
      return false;
    }
  }

  @override
  Future<List<Event>> recupererFavEvents(String token) async {
    var url = '$baseUrl/events/favorites';
    var response = await httpUtils.getData(url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'},
    );

    // Si response est un JSON encodé (String), décode-le d’abord
    final jsonResponse = response is String ? jsonDecode(response) : response;

    if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
      List<dynamic> eventData = jsonResponse['data'];
      print("les événements favori venant du backend : $eventData");
      return eventData.map((event) => Event.fromJson(event)).toList();
    } else {
      throw Exception("Format de réponse inattendu lors de la récupération des événements");
    }
  }




}




