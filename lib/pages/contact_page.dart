import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _ouvrir(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir ce lien')),
      );
    }
  }

  Widget _item(BuildContext context, IconData icone, String titre, String valeur, Uri? uri) {
    return Card(
      child: ListTile(
        leading: Icon(icone, color: Theme.of(context).colorScheme.primary),
        title: Text(titre),
        subtitle: Text(valeur),
        trailing: uri == null ? null : const Icon(Icons.open_in_new, size: 18),
        onTap: uri == null ? null : () => _ouvrir(context, uri),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _item(context, Icons.phone, 'Téléphone', kTelephone,
            Uri(scheme: 'tel', path: kTelephone.replaceAll(' ', ''))),
        _item(context, Icons.email, 'E-mail', kEmail, Uri(scheme: 'mailto', path: kEmail)),
        _item(context, Icons.location_on, 'Adresse', kAdresse, null),
        _item(context, Icons.code, 'GitHub', kGitHub, Uri.parse(kGitHub)),
      ],
    );
  }
}
