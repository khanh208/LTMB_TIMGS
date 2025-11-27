
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';

class ErrorHandler {
  static String getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    debugPrint('ErrorHandler: $errorString'); 
    if (error is SocketException || 
        errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('no internet')) {
      return 'Không có kết nối internet. Vui lòng kiểm tra kết nối mạng của bạn.';
    }
    
    if (error.toString().contains('timeout') || 
        errorString.contains('408')) {
      return 'Kết nối quá lâu. Vui lòng thử lại sau.';
    }
    
    if (errorString.contains('[500]') ||
        errorString.contains('[502]') ||
        errorString.contains('[503]') ||
        errorString.contains('[504]')) {
      return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
    }
    
    if (errorString.contains('[404]')) {
      return 'Không tìm thấy thông tin. Vui lòng thử lại.';
    }
    
    if (errorString.contains('[401]') || errorString.contains('[403]')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    
    if (errorString.contains('[400]') || errorString.contains('[422]')) {
      return 'Thông tin không hợp lệ. Vui lòng kiểm tra lại.';
    }
    
    if (error.toString().contains('FormatException') ||
        errorString.contains('json')) {
      return 'Dữ liệu không đúng định dạng. Vui lòng thử lại.';
    }
    
    return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
  }
  
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    String title = 'Thông báo',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            if (onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onRetry();
                },
                child: const Text(
                  'Thử lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Đóng',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
  
  static Future<void> showErrorDialogFromException(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    final friendlyMessage = getFriendlyErrorMessage(error);
    return showErrorDialog(
      context,
      message: friendlyMessage,
      onRetry: onRetry,
    );
  }
}

