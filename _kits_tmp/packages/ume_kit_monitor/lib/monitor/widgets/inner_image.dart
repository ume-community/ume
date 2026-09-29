import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// @date 9/7/22
/// describe:
class InnerImage extends StatelessWidget {
  final String url;
  final double height;
  final double width;
  final BoxFit fit;

  const InnerImage(
    this.url, {
    this.width = 50,
    this.height = 50,
    Key? key,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: 50,
      memCacheHeight: 50,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
