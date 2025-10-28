import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexasafety/models/occurrence.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';

class NewOccurrencePage extends StatefulWidget {
  const NewOccurrencePage({super.key});

  @override
  State<NewOccurrencePage> createState() => _NewOccurrencePageState();
}

class _NewOccurrencePageState extends State<NewOccurrencePage> {
  final _formKey = GlobalKey<FormState>();
  String _type = occurrenceTypes.first;
  String _description = '';
  bool _anonymous = true;
  bool _submitting = false;

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    setState(() => _submitting = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização desativado.')),
        );
        setState(() => _submitting = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
        setState(() => _submitting = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final repo = OccurrenceRepository();
      final now = DateTime.now();
      final newItem = Occurrence(
        id: now.millisecondsSinceEpoch.toString(),
        type: _type,
        description: _description,
        lat: pos.latitude,
        lng: pos.longitude,
        anonymous: _anonymous,
        createdAt: now,
      );
      repo.add(newItem);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorrência registrada (mock).')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter localização: $e')),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ocorrência'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _type,
                  items: occurrenceTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(labelForType(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? occurrenceTypes.first),
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  maxLines: 4,
                  minLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva o que aconteceu (mín. 10 caracteres)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 10) return 'Mínimo de 10 caracteres';
                    return null;
                  },
                  onSaved: (v) => _description = (v ?? '').trim(),
                ),
                SizedBox(height: spacing),
                CheckboxListTile(
                  title: const Text('Manter anonimato'),
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v ?? true),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: spacing * 2),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
