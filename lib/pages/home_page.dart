import 'package:flutter/material.dart';
import '../data.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _ligne(String haut, String milieu, String bas) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(haut, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(milieu, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (bas.isNotEmpty) Text(bas),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          color: c.primaryContainer,
          child: Column(children: [
            const PhotoRonde(kPhoto, rayon: 60),
            const SizedBox(height: 12),
            Text(kNom,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(kTitre, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(kResume, textAlign: TextAlign.center),
          ]),
        ),
        Section(
          titre: 'Formation',
          icone: Icons.school,
          enfants: [for (final f in kFormations) _ligne(f['periode']!, f['titre']!, f['lieu']!)],
        ),
        Section(
          titre: 'Expériences',
          icone: Icons.work,
          enfants: [for (final e in kExperiences) _ligne(e['periode']!, e['titre']!, e['detail']!)],
        ),
        Section(
          titre: 'Compétences techniques',
          icone: Icons.code,
          enfants: [
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final s in kCompetencesTech) Chip(label: Text(s)),
            ]),
          ],
        ),
        Section(
          titre: 'Langues',
          icone: Icons.translate,
          enfants: [for (final l in kLangues) Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text('• $l'))],
        ),
        Section(
          titre: 'Centres d\'intérêt',
          icone: Icons.favorite,
          enfants: [
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final i in kInterets) Chip(label: Text(i)),
            ]),
          ],
        ),
      ],
    );
  }
}
