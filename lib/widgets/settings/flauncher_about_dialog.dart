/*
 * SG Alfa Home — «Acerca de».
 * GPL-3.0. Se conservan los créditos de los proyectos en los que se basa.
 */

import 'package:flauncher/sgalfa/retro.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LTvLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  const LTvLauncherAboutDialog({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 640,
          padding: const EdgeInsets.all(24),
          decoration: Retro.box(color: Retro.night, shadow: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(6),
                  decoration: Retro.box(color: Retro.cream, radius: 16, shadow: 5),
                  child: Image.asset('assets/sgalfa/helmet.png'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('SG ALFA HOME', style: Retro.title(32)),
                    const SizedBox(height: 8),
                    RetroSticker('v${packageInfo.version} (${packageInfo.buildNumber})',
                        color: Retro.mustard, textColor: Retro.ink),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),
              Text(
                'Tu pantalla de inicio con bloqueo de anuncios, cierre de pop-ups y '
                'automatizaciones estilo MacroDroid.',
                style: Retro.body(17, weight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text('github.com/SantiagoGarces96/sg-alfa-home', style: Retro.body(15, color: Retro.mustard)),
              const SizedBox(height: 18),
              Text(
                'Software libre (GPL-3.0). Basado en Arc Launcher (Badis Meddouri), '
                'LTvLauncher (LeanBitLab) y FLauncher (Étienne Fesser).',
                style: Retro.body(13, color: const Color(0xFFD3CFC4), weight: FontWeight.w500),
              ),
              const SizedBox(height: 18),
              Row(children: [
                RetroButton(
                  autofocus: true,
                  color: Retro.teal,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CERRAR'),
                ),
                RetroButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: 'SG Alfa Home',
                    applicationVersion: packageInfo.version,
                  ),
                  child: const Text('VER LICENCIAS'),
                ),
              ]),
            ],
          ),
        ),
      );
}
