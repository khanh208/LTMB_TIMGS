
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AvatarImageHelper {
  static ImageProvider? getImageProvider(String? avatarUrl) {
    if (avatarUrl == null) return null;
    
    try {
      if (avatarUrl.isEmpty || 
          avatarUrl == 'null' || 
          avatarUrl == '[null]' || 
          avatarUrl.trim().isEmpty) {
        return null;
      }

      final cleanUrl = avatarUrl.trim();
      
      if (cleanUrl.startsWith('data:image/')) {
        final base64String = cleanUrl.split(',').last;
        if (base64String.isEmpty) {
          return null;
        }
        final bytes = base64Decode(base64String);
        return MemoryImage(Uint8List.fromList(bytes));
      }
      
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        return NetworkImage(cleanUrl);
      }
      
      debugPrint('⚠️ [AvatarImageHelper] Invalid avatar URL format: $cleanUrl');
      return null;
    } catch (e) {
      debugPrint('⚠️ [AvatarImageHelper] Error loading image: $e');
      return null;
    }
  }
}

