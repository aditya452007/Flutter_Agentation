import 'package:flutter/material.dart';

/// Premium instrument tokens — charcoal glass, 8px grid, staggered motion (no AI slop).
class AgentationTokens {
  const AgentationTokens._();

  static const double strokeWidth = 1.5;
  static const double badgeRadius = 8;
  static const double toggleRadius = 12;
  static const double panelRadius = 16;
  static const double spacing = 8;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration highlightDuration = Duration(milliseconds: 150);
  static const Curve easeStandard = Cubic(0.4, 0, 0.2, 1);
  static const Curve easeEmphasized = Cubic(0.2, 0, 0, 1);

  // Premium dark — never pure black/white
  static const Color charcoal = Color(0xFF0A0A0A);
  static const Color charcoal80 = Color(0xCC0A0A0A);
  static const Color cream = Color(0xFFF5F0EB);
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoHover = Color(0xFF4F46E5);
  static const Color blueHover = Color(0xFF3B82F6);
  static const double blur = 20;

  static const List<BoxShadow> shadowSm = [BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1))];
  static const List<BoxShadow> shadowMd = [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))];
  static const List<BoxShadow> shadowLg = [BoxShadow(color: Color(0x1F000000), blurRadius: 32, offset: Offset(0, 8))];
}

/// ThemeExtension for selection colors. Applied via ThemeExtension.
@immutable
class AgentationColors extends ThemeExtension<AgentationColors> {
  const AgentationColors({
    required this.selectionStroke,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  final Color selectionStroke;
  final Color badgeBackground;
  final Color badgeForeground;

  @override
  ThemeExtension<AgentationColors> copyWith({
    Color? selectionStroke,
    Color? badgeBackground,
    Color? badgeForeground,
  }) =>
      AgentationColors(
        selectionStroke: selectionStroke ?? this.selectionStroke,
        badgeBackground: badgeBackground ?? this.badgeBackground,
        badgeForeground: badgeForeground ?? this.badgeForeground,
      );

  @override
  ThemeExtension<AgentationColors> lerp(
    covariant ThemeExtension<AgentationColors>? other,
    double t,
  ) {
    if (other is! AgentationColors) return this;
    return AgentationColors(
      selectionStroke: Color.lerp(selectionStroke, other.selectionStroke, t)!,
      badgeBackground: Color.lerp(badgeBackground, other.badgeBackground, t)!,
      badgeForeground: Color.lerp(badgeForeground, other.badgeForeground, t)!,
    );
  }
}
