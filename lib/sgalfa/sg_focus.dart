/*
 * SG Alfa Home — puntos de foco propios del inicio (para el mando).
 */

import 'package:flutter/widgets.dart';

class SgFocus {
  SgFocus._();

  /// Botón «A esta hora sueles ver…» de la tarjeta TU TELE HOY.
  static final FocusNode suggestion = FocusNode(debugLabel: 'sg-suggestion');

  /// Lleva el foco al engranaje de ajustes (lo registra el inicio).
  static VoidCallback? focusSettings;

  /// ¿Está la sugerencia en pantalla y se puede enfocar?
  static bool get suggestionAvailable =>
      suggestion.context != null && suggestion.canRequestFocus && !suggestion.hasFocus;
}
