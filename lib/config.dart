import 'package:flutter/foundation.dart' show kIsWeb;

/// Adresse de base de l'API (sans slash final).
///
/// - Chrome / Flutter web : http://localhost/api-test/public
///   (le navigateur tourne sur le même PC qu'Apache. Si XAMPP utilise un
///   autre port, ajoutez-le : http://localhost:8080/api-test/public)
/// - Émulateur Android    : http://10.0.2.2/api-test/public
/// - Téléphone réel       : http://IP_DE_VOTRE_PC/api-test/public
final String kApiBaseUrl = kIsWeb
    ? 'http://localhost:81/api-test/public'
    : 'http://10.0.2.2/api-test/public';
