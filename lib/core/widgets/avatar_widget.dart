
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'avatar_image_helper.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final IconData defaultIcon;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    this.radius = 50,
    this.defaultIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey,
      backgroundImage: avatarUrl != null ? _getImageProvider(avatarUrl!) : null,
      child: avatarUrl == null
          ? Icon(defaultIcon, size: radius, color: Colors.white)
          : null,
    );
  }

  ImageProvider? _getImageProvider(String url) {
    return AvatarImageHelper.getImageProvider(url);
  }
}

