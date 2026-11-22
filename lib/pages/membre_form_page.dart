import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/famille_membre.dart';
import '../services/api_service.dart';
import '../widgets/avatar_reseau.dart';

/// Formulaire d'ajout (membre == null) ou de modification d'un membre.
class MembreFormPage extends StatefulWidget {
  final FamilleMembre? membre;
  const MembreFormPage({super.key, this.membre});

  @override
  State<MembreFormPage> createState() => _MembreFormPageState();
}

class _MembreFormPageState extends State<MembreFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nom, _postnom, _prenom, _lieu, _date, _parente;
  XFile? _image;
  Uint8List? _apercuBytes;
  bool _enregistrement = false;

  bool get _edition => widget.membre != null;

  @override
  void initState() {
    super.initState();
    final m = widget.membre;
    _nom = TextEditingController(text: m?.nom);
    _postnom = TextEditingController(text: m?.postnom);
    _prenom = TextEditingController(text: m?.prenom);
    _lieu = TextEditingController(text: m?.lieuNaissance);
    _date = TextEditingController(text: m?.dateNaissance);
    _parente = TextEditingController(text: m?.parente);
  }

  @override
  void dispose() {
    for (final c in [_nom, _postnom, _prenom, _lieu, _date, _parente]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _choisirImage() async {
    final f = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (f == null) return;
    final octets = await f.readAsBytes();
    if (octets.length > 2 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image trop lourde (2 Mo maximum)')));
      return;
    }
    setState(() {
      _image = f;
      _apercuBytes = octets;
    });
  }

  Future<void> _choisirDate() async {
    final actuelle = DateTime.tryParse(_date.text) ?? DateTime(2000);
    final d = await showDatePicker(
      context: context,
      initialDate: actuelle.isAfter(DateTime.now()) ? DateTime.now() : actuelle,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _date.text =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _enregistrement = true);
    final champs = {
      'nom': _nom.text.trim(),
      'postnom': _postnom.text.trim(),
      'prenom': _prenom.text.trim(),
      'lieu_naissance': _lieu.text.trim(),
      'date_naissance': _date.text.trim(),
      'parente': _parente.text.trim(),
    };
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_edition) {
        await ApiService.modifierMembre(widget.membre!.id, champs, _image);
      } else {
        await ApiService.creerMembre(champs, _image);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
      messenger.showSnackBar(SnackBar(
          content: Text(_edition ? 'Membre modifié' : 'Membre ajouté')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _enregistrement = false);
    }
  }

  Widget _champ(TextEditingController c, String label, int max, {IconData? icone}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        maxLength: max,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icone == null ? null : Icon(icone),
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apercu = _image != null
        ? CircleAvatar(radius: 56, backgroundImage: MemoryImage(_apercuBytes!))
        : AvatarReseau(widget.membre?.imageUrl, rayon: 56);

    return Scaffold(
      appBar: AppBar(
          title: Text(_edition ? 'Modifier le membre' : 'Ajouter un membre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(onTap: _choisirImage, child: apercu),
              TextButton.icon(
                onPressed: _choisirImage,
                icon: const Icon(Icons.photo_library),
                label: Text(_image == null ? 'Choisir une photo' : 'Changer la photo'),
              ),
              const SizedBox(height: 8),
              _champ(_nom, 'Nom', 50, icone: Icons.badge),
              _champ(_postnom, 'Postnom', 50, icone: Icons.badge_outlined),
              _champ(_prenom, 'Prénom', 50, icone: Icons.person),
              _champ(_lieu, 'Lieu de naissance', 100, icone: Icons.place),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _date,
                  readOnly: true,
                  onTap: _choisirDate,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance',
                    prefixIcon: Icon(Icons.cake),
                    suffixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Champ obligatoire' : null,
                ),
              ),
              _champ(_parente, 'Lien de parenté (Père, Mère, Frère...)', 50,
                  icone: Icons.family_restroom),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _enregistrement ? null : _enregistrer,
                  child: _enregistrement
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_edition ? 'Enregistrer les modifications' : 'Ajouter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
