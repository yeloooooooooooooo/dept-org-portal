import 'package:flutter/material.dart';

class OrgLogoAvatar extends StatelessWidget {
  final String orgCode;
  final double size;

  const OrgLogoAvatar({
    super.key,
    required this.orgCode,
    this.size = 40.0,
  });

  String get _assetPath {
    switch (orgCode.toUpperCase()) {
      case 'JPCS':
        return 'assets/images/jpcs_logo.png';
      case 'ACCESS':
        return 'assets/images/access_logo.png';
      case 'INTESS':
        return 'assets/images/intess_logo.png';
      case 'CICS SC':
        return 'assets/images/cics_sc_logo.png';
      default:
        return 'assets/images/default_org.png';
    }
  }

  Color get _placeholderColor {
    switch (orgCode.toUpperCase()) {
      case 'JPCS':
        return const Color(0xFF1E3A8A);
      case 'ACCESS':
        return const Color(0xFF065F46);
      case 'INTESS':
        return const Color(0xFFB45309);
      case 'CICS SC':
        return const Color(0xFF7F1D1D);
      default:
        return const Color(0xFF374151);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _placeholderColor.withValues(alpha: 0.12),
        border: Border.all(
          color: _placeholderColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          _assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                orgCode.length > 4 ? 'SC' : orgCode,
                style: TextStyle(
                  color: _placeholderColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.28,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}