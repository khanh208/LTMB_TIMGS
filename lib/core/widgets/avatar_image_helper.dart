
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class AvatarImageHelper {
  // Static method để lấy ImageProvider từ avatar URL
  static ImageProvider? getImageProvider(String? avatarUrl) {
    if (avatarUrl == null) return null;
    
    try {
      // Kiểm tra và làm sạch URL
      if (avatarUrl.isEmpty || 
          avatarUrl == 'null' || 
          avatarUrl == '[null]' || 
          avatarUrl.trim().isEmpty) {
        return null;
      }

      final cleanUrl = avatarUrl.trim();
      
      // Kiểm tra nếu là base64 data URL (format: "data:image/png;base64,...")
      if (cleanUrl.startsWith('data:image/')) {
        // Tách phần base64 sau dấu phẩy
        final base64String = cleanUrl.split(',').last;
        if (base64String.isEmpty) {
          return null;
        }
        final bytes = base64Decode(base64String);
        return MemoryImage(Uint8List.fromList(bytes));
      }
      
      // Kiểm tra nếu là URL thông thường hợp lệ
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        return NetworkImage(cleanUrl);
      }
      
      // Nếu không phải format nào cả, trả về null
      debugPrint('⚠️ [AvatarImageHelper] Invalid avatar URL format: $cleanUrl');
      return null;
    } catch (e) {
      debugPrint('⚠️ [AvatarImageHelper] Error loading image: $e');
      return null;
    }
  }
}

