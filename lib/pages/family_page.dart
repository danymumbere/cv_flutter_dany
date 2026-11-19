import 'package:flutter/material.dart';
import '../data.dart';
import 'widgets.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: kFamille.length,
      itemBuilder: (context, i) {
        final m = kFamille[i];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: PhotoRonde(m.photo, rayon: 30),
            title: Text(m.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${m.lien}\n${m.profession}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
