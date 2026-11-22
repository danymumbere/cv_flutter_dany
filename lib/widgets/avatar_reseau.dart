import 'package:flutter/material.dart';

/// Photo ronde chargée depuis une URL (icône si absente ou en erreur).
class AvatarReseau extends StatelessWidget {
  final String? url;
  final double rayon;
  const AvatarReseau(this.url, {super.key, this.rayon = 30});

  @override
  Widget build(BuildContext context) {
    final icone = Icon(Icons.person, size: rayon);
    return CircleAvatar(
      radius: rayon,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: ClipOval(
        child: url == null
            ? icone
            : Image.network(
                url!,
                width: rayon * 2,
                height: rayon * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => icone,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        width: rayon * 2,
                        height: rayon * 2,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
              ),
      ),
    );
  }
}
