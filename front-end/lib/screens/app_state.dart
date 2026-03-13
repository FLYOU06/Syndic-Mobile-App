// ════════════════════════════════════════════════════════════════════
//  app_state.dart — SyndiControl
//
//  Ce fichier est le "cerveau global" de l'app.
//  Il stocke le mode nuit et la langue, et notifie TOUS les écrans
//  automatiquement quand ils changent.
//
//  ▸ flutter pub add provider
// ════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // ── État ──────────────────────────────────────────────────────────
  bool   _isDark = false;
  String _langue = "Français";   // "Français" | "العربية" | "English"

  // ── Getters ───────────────────────────────────────────────────────
  bool   get isDark  => _isDark;
  String get langue  => _langue;

  ThemeMode get themeMode =>
      _isDark ? ThemeMode.dark : ThemeMode.light;

  TextDirection get textDirection =>
      _langue == "العربية" ? TextDirection.rtl : TextDirection.ltr;

  // ── Setters (notifient tous les Consumer/watch) ────────────────────
  void setDark(bool v) {
    _isDark = v;
    notifyListeners();
  }

  void setLangue(String v) {
    _langue = v;
    notifyListeners();
  }
}