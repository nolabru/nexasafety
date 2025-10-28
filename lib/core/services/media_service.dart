import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

/// Service for handling media capture and selection
/// Provides methods for taking photos, selecting from gallery, and video selection
class MediaService {
  MediaService._internal();
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;

  final ImagePicker _picker = ImagePicker();

  /// Capture photo from camera
  /// Returns null if user cancels or permission denied
  Future<File?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      rethrow;
    }
  }

  /// Select photo from gallery
  /// Returns null if user cancels
  Future<File?> selectPhotoFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      debugPrint('Error selecting photo: $e');
      rethrow;
    }
  }

  /// Select multiple photos from gallery
  /// Maximum 3 photos per occurrence
  Future<List<File>> selectMultiplePhotos({int maxImages = 3}) async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      // Limit to maxImages
      final limitedPhotos = photos.take(maxImages).toList();

      return limitedPhotos.map((xfile) => File(xfile.path)).toList();
    } catch (e) {
      debugPrint('Error selecting multiple photos: $e');
      rethrow;
    }
  }

  /// Select video from gallery
  /// Max duration: 60 seconds
  Future<File?> selectVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60),
      );

      if (video == null) return null;

      final file = File(video.path);

      // Check file size (max 30MB)
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 30) {
        throw Exception('Vídeo muito grande. Tamanho máximo: 30MB');
      }

      return file;
    } catch (e) {
      debugPrint('Error selecting video: $e');
      rethrow;
    }
  }

  /// Record video from camera
  /// Max duration: 60 seconds
  Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );

      if (video == null) return null;

      final file = File(video.path);

      // Check file size (max 30MB)
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      if (sizeInMB > 30) {
        throw Exception('Vídeo muito grande. Tamanho máximo: 30MB');
      }

      return file;
    } catch (e) {
      debugPrint('Error recording video: $e');
      rethrow;
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeInMB(File file) async {
    final sizeInBytes = await file.length();
    return sizeInBytes / (1024 * 1024);
  }

  /// Validate file size
  /// Returns true if file is within acceptable size limits
  Future<bool> validateFileSize(File file, {double maxSizeMB = 10}) async {
    final sizeMB = await getFileSizeInMB(file);
    return sizeMB <= maxSizeMB;
  }

  /// Check if file is an image
  bool isImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  /// Check if file is a video
  bool isVideo(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }
}
