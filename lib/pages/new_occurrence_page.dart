import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/enums/occurrence_enums.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class NewOccurrencePage extends StatefulWidget {
  const NewOccurrencePage({super.key});

  @override
  State<NewOccurrencePage> createState() => _NewOccurrencePageState();
}

class _NewOccurrencePageState extends State<NewOccurrencePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  OccurrenceType? _selectedType;
  bool _isAnonymous = true;
  bool _isLoading = false;
  final List<XFile> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _mediaFiles.addAll(images);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar mídia: $e')),
      );
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaFiles.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o tipo de ocorrência')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Implement actual submission logic
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ocorrência enviada com sucesso!')),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova Ocorrência',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo
            Text(
              'Tipo',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<OccurrenceType>(
              value: _selectedType,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                ),
              ),
              hint: Text(
                'Selecione o tipo',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              items: OccurrenceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    OccurrenceEnumHelper.getTypeLabel(type),
                    style: AppTextStyles.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecione o tipo';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Descrição
            CustomTextField(
              label: 'Descrição',
              controller: _descriptionController,
              maxLines: 5,
              minLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, descreva a ocorrência';
                }
                if (value.length < 10) {
                  return 'Descrição muito curta (mínimo 10 caracteres)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Fotos/Vídeos
            Text(
              'Fotos/Vídeos ( Opcional )',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 8),
            
            // Media preview or add button
            if (_mediaFiles.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Nenhuma mídia adicionada',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(_mediaFiles[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 12),
            
            // Add media button
            CustomButton(
              text: 'Adicionar Mídia',
              onPressed: _pickMedia,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
              icon: Icons.add_photo_alternate,
            ),
            
            const SizedBox(height: 24),
            
            // Manter Anonimato checkbox
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? true;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Manter Anonimato',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Submit button
            CustomButton(
              text: 'Enviar',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
