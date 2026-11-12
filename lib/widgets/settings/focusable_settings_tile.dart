import 'package:flutter/material.dart';

import 'settings_theme.dart';

/// A single settings row with subtle focus feedback.
///
/// The visual chrome (glass fill, specular border, lift) lives in
/// [SettingsFocusCard]; this widget only lays out the leading icon, text and
/// trailing control. Behaviour is unchanged: OK/Enter still invokes
/// [onPressed], and the row is still a single focus target.
class FocusableSettingsTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool autofocus;

  /// Shows a disclosure chevron when no [trailing] widget is provided.
  final bool showChevron;

  /// Draws a tinted squircle behind [leading] when it is an icon. Disable for
  /// radio indicators, which should read as plain marks.
  final bool frameLeading;

  const FocusableSettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.autofocus = false,
    this.showChevron = false,
    this.frameLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final baseTextStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    // Icons get a tinted squircle behind them; arbitrary widgets (app icons,
    // spinners) are rendered untouched.
    final framedLeading = frameLeading && leading is Icon;

    return SettingsFocusCard(
      autofocus: autofocus,
      onPressed: onPressed,
      builder: (context, highlighted) => DefaultTextStyle.merge(
        style: baseTextStyle.copyWith(
          color: highlighted ? Colors.white : Colors.white.withValues(alpha: 0.9),
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              if (framedLeading)
                AnimatedContainer(
                  duration: SettingsStyle.focusDurationFor(context),
                  curve: Curves.easeOutCubic,
                  width: SettingsStyle.iconChipSize,
                  height: SettingsStyle.iconChipSize,
                  // SG Alfa: chapita de cómic (mostaza/crema con contorno de tinta).
                  decoration: BoxDecoration(
                    color: highlighted ? const Color(0xFFFFF1D0) : const Color(0xFFFFB703),
                    borderRadius: BorderRadius.circular(SettingsStyle.iconChipRadius),
                    border: Border.all(color: const Color(0xFF1D1A16), width: 2.5),
                    boxShadow: const [BoxShadow(color: Color(0xFF1D1A16), offset: Offset(2, 2))],
                  ),
                  child: IconTheme.merge(
                    data: const IconThemeData(
                      size: SettingsStyle.iconSize,
                      color: Color(0xFF1D1A16),
                    ),
                    child: Center(child: leading!),
                  ),
                )
              else
                leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        title,
                        const SizedBox(height: 2),
                        subtitle!,
                      ],
                    )
                  : title,
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ] else if (showChevron) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: highlighted
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.25),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
