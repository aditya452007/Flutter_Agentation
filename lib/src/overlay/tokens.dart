import 'package:flutter/material.dart';

/// Instrument tokens for the Agentation overlay — neutral M3, no AI slop.
class AgentationTokens {
  const AgentationTokens._();

  static const double strokeWidth = 1.5;
  static const double badgeRadius = 8;
  static const double toggleRadius = 12;
  static const double panelRadius = 16;
  static const double spacing = 12;
  static const Duration highlightDuration = Duration(milliseconds: 80);
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
