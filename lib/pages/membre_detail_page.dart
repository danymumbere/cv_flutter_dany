import 'package:flutter/material.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';
import '../widgets/avatar_reseau.dart';
import 'famille_actions.dart';
import 'membre_form_page.dart';

/// Consultation d'un membre : charge les données via GET /famille-membres/{id}.
class MembreDetailPage extends StatefulWidget {
  final int id;
  const MembreDetailPage({super.key, required this.id});

  @override
  State<MembreDetailPage> createState() => _MembreDetailPageState();
}

class _MembreDetailPageState extends State<MembreDetailPage> {
  late Future<FamilleMembre> _futur;

  @override
  void initState() {
    super.initState();
    _futur = ApiService.obtenirMembre(widget.id);
  }

  void _recharger() =>
      setState(() => _futur = ApiService.obtenirMembre(widget.id));

  Widget _ligne(IconData icone, String titre, String valeur) => ListTile(
        leading: Icon(icone),
        title: Text(titre),
        subtitle: Text(valeur),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FamilleMembre>(
      future: _futur,
      builder: (context, snap) {
        final m = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail du membre'),
            actions: m == null
                ? null
                : [
                    IconButton(
                      tooltip: 'Modifier',
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MembreFormPage(membre: m)));
                        if (ok == true) _recharger();
                      },
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        if (await supprimerMembre(context, m) && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
          ),
          body: () {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || m == null) {
              return Center(child: Text('${snap.error}'));
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Center(child: AvatarReseau(m.imageUrl, rayon: 70)),
                const SizedBox(height: 12),
                Center(
                  child: Text(m.nomComplet,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
                const SizedBox(height: 16),
                _ligne(Icons.family_restroom, 'Lien de parenté', m.parente),
                _ligne(Icons.place, 'Lieu de naissance', m.lieuNaissance),
                _ligne(Icons.cake, 'Date de naissance', m.dateNaissance),
              ],
            );
          }(),
        );
      },
    );
  }
}
