class FamilleMembre {
  final int id;
  final String nom, postnom, prenom, lieuNaissance, dateNaissance, parente;
  final String? imageUrl;

  const FamilleMembre({
    required this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  String get nomComplet => '$prenom $nom $postnom';

  factory FamilleMembre.fromJson(Map<String, dynamic> j) {
    final img = j['image_url'];
    return FamilleMembre(
      id: int.parse(j['id'].toString()),
      nom: (j['nom'] ?? '').toString(),
      postnom: (j['postnom'] ?? '').toString(),
      prenom: (j['prenom'] ?? '').toString(),
      lieuNaissance: (j['lieu_naissance'] ?? '').toString(),
      dateNaissance: (j['date_naissance'] ?? '').toString(),
      parente: (j['parente'] ?? '').toString(),
      imageUrl: (img == null || img.toString().isEmpty) ? null : img.toString(),
    );
  }
}
