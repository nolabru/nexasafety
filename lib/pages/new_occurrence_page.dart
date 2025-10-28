import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexasafety/models/occurrence.dart';
import 'package:nexasafety/repositories/occurrence_repository.dart';
import 'package:nexasafety/core/services/occurrence_service.dart';
import 'package:nexasafety/core/services/api_client.dart';
import 'package:nexasafety/core/services/api_client.dart' show ApiException, UnauthorizedException;
import 'package:nexasafety/core/services/media_service.dart';

class NewOccurrencePage extends StatefulWidget {
  const NewOccurrencePage({super.key});

  @override
  State<NewOccurrencePage> createState() => _NewOccurrencePageState();
}

class _NewOccurrencePageState extends State<NewOccurrencePage> {
  final _formKey = GlobalKey<FormState>();
  final _mediaService = MediaService();

  String _type = occurrenceTypes.first;
  String _description = '';
  bool _anonymous = true;
  bool _submitting = false;
  List<File> _mediaFiles = []; // Photos/videos attached to occurrence
  static const int _maxMediaFiles = 3;

  // Mapeia o tipo local (UI) para o tipo da API
  String _toApiType(String local) {
    switch (local) {
      case 'assalto':
        return 'ASSALTO';
      case 'furto':
        return 'FURTO';
      case 'vandalismo':
        return 'VANDALISMO';
      case 'suspeita':
        return 'OUTROS';
      case 'concluido':
        return 'OUTROS';
      default:
        return 'OUTROS';
    }
  }

  // Mapeia o tipo da API para o local para exibir marcador no mapa (repo)
  String _fromApiType(String api) {
    switch (api) {
      case 'ASSALTO':
        return 'assalto';
      case 'FURTO':
        return 'furto';
      case 'VANDALISMO':
        return 'vandalismo';
      case 'AMEACA':
      case 'OUTROS':
        return 'suspeita';
      default:
        return 'suspeita';
    }
  }

  /// Show media source selection dialog
  Future<void> _showMediaSourceDialog() async {
    if (_mediaFiles.length >= _maxMediaFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Máximo de $_maxMediaFiles arquivos por ocorrência'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Galeria de fotos'),
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Gravar vídeo'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Capture photo from camera
  Future<void> _capturePhoto() async {
    try {
      final file = await _mediaService.capturePhoto();
      if (file != null && mounted) {
        setState(() {
          if (_mediaFiles.length < _maxMediaFiles) {
            _mediaFiles.add(file);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Select photo from gallery
  Future<void> _selectFromGallery() async {
    try {
      final remainingSlots = _maxMediaFiles - _mediaFiles.length;
      final files = await _mediaService.selectMultiplePhotos(
        maxImages: remainingSlots,
      );

      if (files.isNotEmpty && mounted) {
        setState(() {
          _mediaFiles.addAll(files);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar fotos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Record video
  Future<void> _recordVideo() async {
    try {
      final file = await _mediaService.recordVideo();
      if (file != null && mounted) {
        setState(() {
          // Videos replace all other media (1 video only)
          _mediaFiles = [file];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gravar vídeo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove media file
  void _removeMediaFile(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

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

      // Tenta usar API se houver token
      final hasToken = (await ApiClient().getToken())?.isNotEmpty == true;
      final now = DateTime.now();

      if (hasToken) {
        try {
          final apiTipo = _toApiType(_type);

          // Use multipart upload if media files are present
          final created = _mediaFiles.isNotEmpty
              ? await OccurrenceService().createOccurrenceWithMedia(
                  tipo: apiTipo,
                  descricao: _description,
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  mediaFiles: _mediaFiles,
                  isPublic: true,
                )
              : await OccurrenceService().createOccurrence(
                  tipo: apiTipo,
                  descricao: _description,
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                  isPublic: true,
                );

          // Também adiciona ao repositório local para aparecer no mapa atual
          final repo = OccurrenceRepository();
          repo.add(
            Occurrence(
              id: created.id,
              type: _fromApiType(created.tipo),
              description: created.descricao,
              lat: created.latitude,
              lng: created.longitude,
              anonymous: _anonymous,
              createdAt: created.createdAt,
            ),
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ocorrência registrada.')),
          );
          Navigator.of(context).pop(true);
          return;
        } on UnauthorizedException {
          // segue para fallback local
        } on ApiException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na API: ${e.message}. Usando modo local.')),
          );
          // continua para fallback local
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao enviar para API: $e. Usando modo local.')),
          );
          // continua para fallback local
        }
      }

      // Fallback local (modo anônimo / offline)
      final repo = OccurrenceRepository();
      repo.add(
        Occurrence(
          id: now.millisecondsSinceEpoch.toString(),
          type: _type,
          description: _description,
          lat: pos.latitude,
          lng: pos.longitude,
          anonymous: _anonymous,
          createdAt: now,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorrência registrada localmente.')),
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
                // Media Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fotos/Vídeos (Opcional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${_mediaFiles.length}/$_maxMediaFiles',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Media preview grid
                      if (_mediaFiles.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _mediaFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            final isVideo = _mediaService.isVideo(file);

                            return Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: isVideo
                                        ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                color: Colors.black87,
                                                child: const Icon(
                                                  Icons.play_circle_outline,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 4,
                                                right: 4,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'VIDEO',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Image.file(
                                            file,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: GestureDetector(
                                    onTap: () => _removeMediaFile(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      if (_mediaFiles.isEmpty)
                        Center(
                          child: Text(
                            'Nenhuma mídia adicionada',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Add media button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _mediaFiles.length < _maxMediaFiles
                              ? _showMediaSourceDialog
                              : null,
                          icon: const Icon(Icons.add_photo_alternate, size: 20),
                          label: const Text('Adicionar mídia'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
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
