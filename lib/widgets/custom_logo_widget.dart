import 'package:flutter/material.dart';
import 'package:investrack_admin/utils/constants.dart';

class CustomLogoWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackName;
  final double size;

  const CustomLogoWidget({
    super.key,
    required this.imageUrl,
    required this.fallbackName,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.hardEdge,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              _getFullImageUrl(imageUrl!),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback();
              },
            )
          : _buildFallback(),
    );
  }

  String _getFullImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    // Remove the '/api' from the baseUrl to get the host URL
    final hostUrl = AppConstants.baseUrl.replaceAll(RegExp(r'/api$'), '');
    if (url.startsWith('/')) {
      return '$hostUrl$url';
    }
    return '$hostUrl/$url';
  }

  Widget _buildFallback() {
    final initial = fallbackName.isNotEmpty
        ? fallbackName.substring(0, 1).toUpperCase()
        : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
