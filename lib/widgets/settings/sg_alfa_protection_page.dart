/*
 * SG Alfa Home — Protección: bloqueo de anuncios, automatizaciones y pop-ups.
 * GPL-3.0, como el resto del launcher.
 */

import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SgAlfaProtectionPage extends StatefulWidget {
  static const String routeName = "sg_alfa_protection_panel";

  const SgAlfaProtectionPage({Key? key}) : super(key: key);

  @override
  State<SgAlfaProtectionPage> createState() => _SgAlfaProtectionPageState();
}

class _SgAlfaProtectionPageState extends State<SgAlfaProtectionPage> with WidgetsBindingObserver {
  static const _channel = MethodChannel('tv.sgalfa.home/protection');

  bool _loading = true;
  bool _busy = false;
  bool _adblock = false;
  bool _automation = false;
  List<Map<dynamic, dynamic>> _macros = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Al volver de Ajustes > Accesibilidad, actualiza el estado.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _apply(dynamic raw) {
    if (raw is! Map) return;
    final macros = raw['macros'];
    setState(() {
      _loading = false;
      _adblock = raw['adblock'] == true;
      _automation = raw['automation'] == true;
      _macros = macros is List ? macros.whereType<Map<dynamic, dynamic>>().toList() : [];
    });
  }

  Future<void> _refresh() async {
    try {
      _apply(await _channel.invokeMethod('getState'));
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setAdblock(bool on) async {
    setState(() => _busy = true);
    try {
      await _channel.invokeMethod('setAdblock', on);
      // El servicio tarda un instante en arrancar.
      await Future.delayed(const Duration(milliseconds: 700));
    } catch (_) {}
    await _refresh();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _setMacro(String id, bool on) async {
    try {
      _apply(await _channel.invokeMethod('setMacroEnabled', {'id': id, 'enabled': on}));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hint = text.bodySmall?.copyWith(color: Colors.white70);

    return Column(
      children: [
        const SettingsPageHeader(title: "Protección SG Alfa"),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    RoundedSwitchListTile(
                      autofocus: true,
                      value: _adblock,
                      onChanged: (v) {
                        if (!_busy) _setAdblock(v);
                      },
                      title: Text("Bloquear anuncios", style: text.bodyMedium),
                      subtitle: Text(
                        _adblock
                            ? "Activo: anuncios, pop-ups y rastreadores filtrados por DNS"
                            : "Filtra anuncios y pop-ups en todas las apps (sin root)",
                        style: hint,
                      ),
                      secondary: const Icon(Icons.shield_outlined),
                    ),
                    FocusableSettingsTile(
                      leading: const Icon(Icons.smart_button_outlined),
                      title: Text("Automatizaciones y cierre de pop-ups", style: text.bodyMedium),
                      subtitle: Text(
                        _automation
                            ? "● Activado"
                            : "○ Desactivado — pulsa y activa «SG Alfa · Automatizaciones»",
                        style: hint,
                      ),
                      onPressed: () => _channel.invokeMethod('openAccessibilitySettings'),
                    ),
                    const SettingsSectionDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(
                        "Mis automatizaciones. Créalas y edítalas desde la app SG Alfa del teléfono.",
                        style: hint,
                      ),
                    ),
                    for (final m in _macros)
                      RoundedSwitchListTile(
                        value: m['enabled'] == true,
                        onChanged: (v) => _setMacro(m['id'] as String, v),
                        title: Text("${m['name']}", style: text.bodyMedium),
                        subtitle: Text("${m['description']}", style: hint),
                        secondary: const Icon(Icons.bolt_outlined),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
        ),
      ],
    );
  }
}
