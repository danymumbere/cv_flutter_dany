import 'package:flutter/material.dart';

/// Image d'asset avec repli (icône) si le fichier est absent.
class PhotoRonde extends StatelessWidget {
  final String chemin;
  final double rayon;
  const PhotoRonde(this.chemin, {super.key, this.rayon = 28});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: rayon,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ClipOval(
        child: Image.asset(
          chemin,
          width: rayon * 2,
          height: rayon * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.person, size: rayon),
        ),
      ),
    );
  }
}

/// Carte-section avec titre et icône.
class Section extends StatelessWidget {
  final String titre;
  final IconData icone;
  final List<Widget> enfants;
  const Section({super.key, required this.titre, required this.icone, required this.enfants});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icone, color: c.primary),
              const SizedBox(width: 8),
              Text(titre,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: c.primary)),
            ]),
            const Divider(),
            ...enfants,
          ],
        ),
      ),
    );
  }
}
