import 'package:flutter/material.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';

/// Demande confirmation puis supprime le membre via l'API.
/// Retourne true si la suppression a réussi.
Future<bool> supprimerMembre(BuildContext context, FamilleMembre m) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Supprimer ce membre ?'),
      content: Text('${m.nomComplet} sera supprimé définitivement.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer')),
      ],
    ),
  );
  if (confirme != true) return false;

  try {
    await ApiService.supprimerMembre(m.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Membre supprimé')));
    }
    return true;
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
    return false;
  }
}
