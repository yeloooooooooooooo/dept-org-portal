import 'package:flutter/material.dart';

class OrgLogoAvatar extends StatelessWidget {
  final String orgCode;
  final double size;

  const OrgLogoAvatar({
    super.key,
    required this.orgCode,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    Color bgColor = const Color(0xFF0F2547);
    IconData fallbackIcon = Icons.shield_rounded;

    switch (orgCode) {
      case 'ACCESS':
        assetPath = 'assets/images/access_logo.png';
        bgColor = const Color(0xFF059669);
        fallbackIcon = Icons.hub_rounded;
        break;
      case 'CICS SC':
        assetPath = 'assets/images/cics_sc_logo.png';
        bgColor = const Color(0xFFB45309);
        fallbackIcon = Icons.account_balance_rounded;
        break;
      case 'JPCS':
        assetPath = 'assets/images/jpcs_logo.png';
        bgColor = const Color(0xFF1D4ED8);
        fallbackIcon = Icons.code_rounded;
        break;
      case 'INTESS':
        assetPath = 'assets/images/intess_logo.png';
        bgColor = const Color(0xFF7C3AED);
        fallbackIcon = Icons.lan_rounded;
        break;
    }

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              fallbackIcon,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Icon(
        fallbackIcon,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}