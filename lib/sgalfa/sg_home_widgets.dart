/*
 * SG Alfa Home — piezas propias de la pantalla de inicio (estilo retro-cartoon).
 * GPL-3.0, como el resto del launcher.
 */

import 'dart:async';

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/sgalfa/retro.dart';
import 'package:flauncher/sgalfa/sg_focus.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flauncher/widgets/settings/sg_alfa_protection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const _protection = MethodChannel('tv.sgalfa.home/protection');

const _days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _greeting(DateTime now) {
  if (now.hour >= 6 && now.hour < 12) return '¡Buenos días!';
  if (now.hour >= 12 && now.hour < 19) return '¡Buenas tardes!';
  return '¡Buenas noches!';
}

/// Marca en la barra superior: casco + «SG ALFA».
class SgBrandBadge extends StatelessWidget {
  const SgBrandBadge({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(3),
            decoration: Retro.box(color: Retro.cream, radius: 10, border: 2.5, shadow: 3),
            child: Image.asset('assets/sgalfa/helmet.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Text('SG ALFA', style: Retro.title(20)),
        ],
      );
}

/// Insignia «Anuncios bloqueados» / «Sin bloqueo». Al pulsarla abre Protección SG Alfa.
class SgProtectionChip extends StatefulWidget {
  const SgProtectionChip({super.key});

  @override
  State<SgProtectionChip> createState() => _SgProtectionChipState();
}

class _SgProtectionChipState extends State<SgProtectionChip> with WidgetsBindingObserver {
  bool? _on;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final s = await _protection.invokeMethod('getState');
      if (mounted && s is Map) setState(() => _on = s['adblock'] == true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final on = _on == true;
    return RetroButton(
      color: on ? const Color(0xFF8FD694) : Retro.cream,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      radius: 20,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (_) => const SettingsPanel(initialRoute: SgAlfaProtectionPage.routeName),
        );
        _refresh();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(on ? Icons.shield : Icons.shield_outlined, size: 18),
          const SizedBox(width: 6),
          Text(on ? 'Anuncios bloqueados' : 'Sin bloqueo', style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

/// Zona destacada sobre el dock: saludo, fecha, hora grande y la app enfocada.
class SgHero extends StatefulWidget {
  const SgHero({super.key});

  @override
  State<SgHero> createState() => _SgHeroState();
}

class _SgHeroState extends State<SgHero> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      final n = DateTime.now();
      if (n.minute != _now.minute || n.hour != _now.hour) setState(() => _now = n);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = '${_days[_now.weekday - 1]} ${_now.day} de ${_months[_now.month - 1]}';
    final time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final focusedApp = context.select<LauncherState, String?>((s) => s.focusedAppName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 0, 48, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
      Expanded(child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RetroSticker(_greeting(_now), color: Retro.mustard, textColor: Retro.ink),
              const SizedBox(width: 12),
              Text(date, style: Retro.body(18)),
            ],
          ),
          const SizedBox(height: 10),
          Text(time, style: Retro.title(84)),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: focusedApp == null
                ? const SizedBox(height: 44, key: ValueKey('none'))
                : Row(
                    key: ValueKey(focusedApp),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: Retro.box(color: Retro.red, radius: 10, shadow: 4),
                        child: Text(focusedApp, style: Retro.title(24)),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text('OK para abrir  ·  mantén OK para opciones',
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: Retro.body(15)),
                      ),
                    ],
                  ),
          ),
        ],
      )),
      const SizedBox(width: 24),
      const SgTodayCard(),
        ],
      ),
    );
  }
}

/// «TU TELE HOY»: anuncios bloqueados, avisos cerrados y la app que sueles ver a esta hora.
class SgTodayCard extends StatefulWidget {
  const SgTodayCard({super.key});

  @override
  State<SgTodayCard> createState() => _SgTodayCardState();
}

class _SgTodayCardState extends State<SgTodayCard> with WidgetsBindingObserver {
  Map<dynamic, dynamic>? _today;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final t = await _protection.invokeMethod('getToday');
      if (mounted && t is Map) setState(() => _today = t);
    } catch (_) {}
  }

  Widget _stat(IconData icon, String number, String label, Color color, bool on) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: Retro.box(color: on ? color : const Color(0xFFB9B4A8), radius: 9, border: 2.5, shadow: 2),
            child: Icon(icon, size: 20, color: Retro.ink),
          ),
          const SizedBox(width: 10),
          Text(number, style: Retro.title(26)),
          const SizedBox(width: 8),
          Text(label, style: Retro.body(14)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final t = _today;
    if (t == null) return const SizedBox.shrink();
    final adblock = t['adblock'] == true;
    final automation = t['automation'] == true;
    final suggestion = t['suggestion'];

    return Container(
      width: 400,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: Retro.box(color: Retro.night.withValues(alpha: 0.88), shadow: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RetroSticker('TU TELE HOY', color: Retro.teal),
          const SizedBox(height: 12),
          _stat(Icons.shield, '${t['ads'] ?? 0}', adblock ? 'anuncios bloqueados' : 'bloqueo apagado',
              const Color(0xFF8FD694), adblock),
          const SizedBox(height: 8),
          _stat(Icons.bolt, '${t['actions'] ?? 0}', automation ? 'avisos cerrados solos' : 'automatizaciones apagadas',
              Retro.mustard, automation),
          if (suggestion is Map) ...[
            const SizedBox(height: 14),
            Text('A ESTA HORA SUELES VER', style: Retro.body(13, color: Retro.mustard, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            Focus(
              canRequestFocus: false,
              skipTraversal: true,
              // Desde la sugerencia, «arriba» va a los ajustes.
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  SgFocus.focusSettings?.call();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: RetroButton(
              focusNode: SgFocus.suggestion,
              color: Retro.red,
              focusColor: Retro.mustard,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onPressed: () {
                final app = context.read<AppsService>().getApplication('${suggestion['packageName']}');
                if (app != null) context.read<AppsService>().launchApp(app);
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.play_arrow_rounded, size: 26),
                const SizedBox(width: 6),
                Flexible(
                  child: Text('${suggestion['name']}',
                      overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18)),
                ),
              ]),
            ),
            ),
          ],
        ],
      ),
    );
  }
}
