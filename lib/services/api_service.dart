import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../config.dart';
import '../models/account.dart';
import '../models/famille_membre.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static const _timeout = Duration(seconds: 20);
  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static const _msgInjoignable =
      'Impossible de joindre le serveur. Vérifiez qu\'Apache est démarré, que l\'adresse de l\'API (config.dart) est correcte et, sur Chrome, que le CORS est activé côté API.';

  static Uri _uri(String path) => Uri.parse('$kApiBaseUrl$path');

  /// Exécute une requête, décode le JSON et transforme toute erreur
  /// (réseau, HTTP, validation) en [ApiException] lisible.
  static Future<Map<String, dynamic>> _envoyer(
      Future<http.Response> Function() requete) async {
    http.Response res;
    try {
      res = await requete().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Le serveur ne répond pas (délai dépassé).');
    } on http.ClientException {
      throw ApiException(_msgInjoignable);
    } catch (_) {
      throw ApiException(_msgInjoignable);
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
          'Réponse invalide du serveur (code ${res.statusCode}).', res.statusCode);
    }

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (ok && body['success'] == true) return body;
    throw ApiException(_messageErreur(body), res.statusCode);
  }

  static String _messageErreur(Map<String, dynamic> body) {
    final lignes = <String>[(body['message'] ?? 'Erreur').toString()];
    final erreurs = body['errors'];
    if (erreurs is Map) {
      lignes.addAll(erreurs.values.map((e) => '• $e'));
    }
    return lignes.join('\n');
  }

  // ------------------------------------------------------------ Comptes

  static Future<Account> register(String email, String password) async {
    final body = await _envoyer(() => http.post(
          _uri('/accounts/register'),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    return Account.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<Account> login(String email, String password) async {
    final body = await _envoyer(() => http.post(
          _uri('/accounts/login'),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    return Account.fromJson(body['data'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------ Famille

  static Future<List<FamilleMembre>> listerMembres() async {
    final body = await _envoyer(
        () => http.get(_uri('/famille-membres'), headers: _jsonHeaders));
    final data = body['data'] as List;
    return data
        .map((e) => FamilleMembre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<FamilleMembre> obtenirMembre(int id) async {
    final body = await _envoyer(
        () => http.get(_uri('/famille-membres/$id'), headers: _jsonHeaders));
    return FamilleMembre.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Création : multipart/form-data (image facultative).
  static Future<FamilleMembre> creerMembre(
      Map<String, String> champs, XFile? image) async {
    final body = await _envoyer(() async {
      final req = http.MultipartRequest('POST', _uri('/famille-membres'))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(champs);
      if (image != null) req.files.add(await _fichierImage(image));
      return http.Response.fromStream(await req.send());
    });
    return FamilleMembre.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Modification.
  /// - sans nouvelle image : PUT JSON (l'image actuelle est conservée)
  /// - avec nouvelle image : POST multipart sur /famille-membres/{id}
  static Future<FamilleMembre> modifierMembre(
      int id, Map<String, String> champs, XFile? nouvelleImage) async {
    final body = await _envoyer(() async {
      if (nouvelleImage == null) {
        return http.put(_uri('/famille-membres/$id'),
            headers: _jsonHeaders, body: jsonEncode(champs));
      }
      final req = http.MultipartRequest('POST', _uri('/famille-membres/$id'))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(champs);
      req.files.add(await _fichierImage(nouvelleImage));
      return http.Response.fromStream(await req.send());
    });
    return FamilleMembre.fromJson(body['data'] as Map<String, dynamic>);
  }

  static Future<void> supprimerMembre(int id) async {
    await _envoyer(
        () => http.delete(_uri('/famille-membres/$id'), headers: _jsonHeaders));
  }

  // ------------------------------------------------------------ Outils

  /// Compatible web et mobile : on envoie les octets de l'image
  /// (dart:io / File n'existe pas sur Chrome).
  static Future<http.MultipartFile> _fichierImage(XFile f) async {
    const types = {
      'jpg': 'jpeg',
      'jpeg': 'jpeg',
      'png': 'png',
      'gif': 'gif',
      'webp': 'webp',
    };
    var ext = f.name.contains('.') ? f.name.split('.').last.toLowerCase() : '';
    if (!types.containsKey(ext)) {
      final mime = f.mimeType ?? '';
      ext = mime.startsWith('image/') ? mime.substring(6) : 'jpg';
      if (!types.containsKey(ext)) ext = 'jpg';
    }
    final octets = await f.readAsBytes();
    return http.MultipartFile.fromBytes(
      'image',
      octets,
      filename: 'photo.$ext',
      contentType: MediaType('image', types[ext]!),
    );
  }
}
