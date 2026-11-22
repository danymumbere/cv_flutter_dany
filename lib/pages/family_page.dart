import 'package:flutter/material.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';
import '../widgets/avatar_reseau.dart';
import 'famille_actions.dart';
import 'membre_detail_page.dart';
import 'membre_form_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  late Future<List<FamilleMembre>> _futur;

  @override
  void initState() {
    super.initState();
    _futur = ApiService.listerMembres();
  }

  Future<void> _recharger() async {
    final f = ApiService.listerMembres();
    setState(() => _futur = f);
    try {
      await f;
    } catch (_) {/* l'erreur est affichée par le FutureBuilder */}
  }

  Future<void> _ajouter() async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => const MembreFormPage()));
    if (ok == true) _recharger();
  }

  Future<void> _modifier(FamilleMembre m) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => MembreFormPage(membre: m)));
    if (ok == true) _recharger();
  }

  Future<void> _supprimer(FamilleMembre m) async {
    if (await supprimerMembre(context, m)) _recharger();
  }

  Future<void> _ouvrir(FamilleMembre m) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => MembreDetailPage(id: m.id)));
    _recharger();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouter,
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter'),
      ),
      body: FutureBuilder<List<FamilleMembre>>(
        future: _futur,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56),
                    const SizedBox(height: 12),
                    Text('${snap.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _recharger,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          final membres = snap.data ?? [];
          return RefreshIndicator(
            onRefresh: _recharger,
            child: membres.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 160),
                    Center(child: Text('Aucun membre pour le moment.')),
                    SizedBox(height: 8),
                    Center(child: Text('Appuyez sur « Ajouter » pour commencer.')),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                    itemCount: membres.length,
                    itemBuilder: (context, i) {
                      final m = membres[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: AvatarReseau(m.imageUrl, rayon: 30),
                          title: Text(m.nomComplet,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${m.parente}\nNé(e) à ${m.lieuNaissance}, le ${m.dateNaissance}'),
                          isThreeLine: true,
                          onTap: () => _ouvrir(m),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) =>
                                v == 'edit' ? _modifier(m) : _supprimer(m),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Modifier')),
                              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
