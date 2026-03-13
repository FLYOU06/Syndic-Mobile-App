// ════════════════════════════════════════════════════════════════════
//  settings_screen.dart — SyndiControl
//  Sections :
//  1️⃣  Profil du syndic
//  2️⃣  Informations de la copropriété
//  3️⃣  Langue et apparence
// ════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'dashboard_screen.dart';
import 'habitants_screen.dart';
import 'charges.dart';
import 'assembly_dashboard_screen.dart';

// ─────────────────────────────────────────────
//  Textes multilingues
// ─────────────────────────────────────────────
class _Lang {
  static const Map<String, Map<String, String>> _tr = {
    "Français": {
      "settings":           "Paramètres",
      // Profil syndic
      "profil_title":       "Profil du Syndic",
      "nom_syndic":         "Nom / Société",
      "email_syndic":       "Email",
      "tel_syndic":         "Téléphone",
      "adresse_syndic":     "Adresse",
      "photo_logo":         "Photo / Logo",
      "change_pwd":         "Modifier le mot de passe",
      "change_pwd_sub":     "Dernière modification : il y a 3 mois",
      // Copropriété
      "copro_title":        "Informations de la Copropriété",
      "nom_residence":      "Nom de la résidence",
      "adresse_residence":  "Adresse",
      "nb_coproprietaires": "Nombre de copropriétaires",
      "nb_immeubles":       "Nombre d'immeubles / blocs",
      "nb_appartements":    "Nombre d'appartements",
      // Apparence
      "apparat_title":      "Langue et Apparence",
      "dark_mode":          "Mode nuit",
      "dark_mode_sub":      "Interface sombre pour les yeux",
      "langue":             "Langue",

      // Boutons
      "enregistrer":        "Enregistrer",
      "annuler":            "Annuler",
      "confirmer":          "Confirmer",
      "logout":             "Se déconnecter",
      "logout_confirm":     "Êtes-vous sûr de vouloir vous déconnecter ?",
      "disconnected":       "Déconnexion réussie",
      "pwd_changed":        "Mot de passe modifié ✓",
      "saved":              "Modifications enregistrées ✓",
      "old_pwd":            "Mot de passe actuel",
      "new_pwd":            "Nouveau mot de passe",
      "conf_pwd":           "Confirmer le mot de passe",
      
    },
    "العربية": {
      "settings":           "الإعدادات",
      "profil_title":       "ملف المسير",
      "nom_syndic":         "الاسم / الشركة",
      "email_syndic":       "البريد الإلكتروني",
      "tel_syndic":         "الهاتف",
      "adresse_syndic":     "العنوان",
      "photo_logo":         "الصورة / الشعار",
      "change_pwd":         "تغيير كلمة المرور",
      "change_pwd_sub":     "آخر تعديل: منذ 3 أشهر",
      "copro_title":        "معلومات المجمع",
      "nom_residence":      "اسم المجمع",
      "adresse_residence":  "العنوان",
      "nb_coproprietaires": "عدد المشاركين",
      "nb_immeubles":       "عدد المباني / الكتل",
      "nb_appartements":    "عدد الشقق",
      "apparat_title":      "اللغة والمظهر",
      "dark_mode":          "الوضع الليلي",
      "dark_mode_sub":      "واجهة داكنة لراحة العيون",
      "langue":             "اللغة",
      "enregistrer":        "حفظ",
      "annuler":            "إلغاء",
      "confirmer":          "تأكيد",
      "logout":             "تسجيل الخروج",
      "logout_confirm":     "هل أنت متأكد من تسجيل الخروج؟",
      "disconnected":       "تم تسجيل الخروج بنجاح",
      "pwd_changed":        "تم تغيير كلمة المرور ✓",
      "saved":              "تم الحفظ بنجاح",
      "old_pwd":            "كلمة المرور الحالية",
      "new_pwd":            "كلمة المرور الجديدة",
      "conf_pwd":           "تأكيد كلمة المرور",
    },
    "English": {
      "settings":           "Settings",
      "profil_title":       "Syndic Profile",
      "nom_syndic":         "Name / Company",
      "email_syndic":       "Email",
      "tel_syndic":         "Phone",
      "adresse_syndic":     "Address",
      "photo_logo":         "Photo / Logo",
      "change_pwd":         "Change password",
      "change_pwd_sub":     "Last changed: 3 months ago",
      "copro_title":        "Residence Information",
      "nom_residence":      "Residence name",
      "adresse_residence":  "Address",
      "nb_coproprietaires": "Number of co-owners",
      "nb_immeubles":       "Number of buildings / blocks",
      "nb_appartements":    "Number of apartments",
      "apparat_title":      "Language & Appearance",
      "dark_mode":          "Dark mode",
      "dark_mode_sub":      "Dark interface for your eyes",
      "langue":             "Language",
      "enregistrer":        "Save",
      "annuler":            "Cancel",
      "confirmer":          "Confirm",
      "logout":             "Sign out",
      "logout_confirm":     "Are you sure you want to sign out?",
      "disconnected":       "Signed out successfully",
      "pwd_changed":        "Password changed ✓",
      "saved":              "Saved successfully",
      "old_pwd":            "Current password",
      "new_pwd":            "New password",
      "conf_pwd":           "Confirm password",
    },
  };
  static String t(String key, String lang) =>
      _tr[lang]?[key] ?? _tr["Français"]![key] ?? key;
}

// ─────────────────────────────────────────────
//  Palette
// ─────────────────────────────────────────────
class _P {
  static const primaryBlue = Color(0xFF004E7A);
  static const blue        = Color(0xFF1A4DD1);
  static const success     = Color(0xFF10B981);
  static const warning     = Color(0xFFF59E0B);
  static const danger      = Color(0xFFEF4444);
  static const accent      = Color(0xFF0ECFCF);
  static const indigo      = Color(0xFF6366F1);
  static const purple      = Color(0xFF8B5CF6);
  static const bg          = Color(0xFFF0F4FA);
  static const surface     = Color(0xFFFFFFFF);
  static const border      = Color(0xFFE2E8F4);
  static const textP       = Color(0xFF0B1F3A);
  static const textS       = Color(0xFF64748B);
  static const textM       = Color(0xFFA0ABBA);
  static const bgDk        = Color(0xFF0D1117);
  static const surfaceDk   = Color(0xFF161B22);
  static const borderDk    = Color(0xFF30363D);
  static const textPDk     = Color(0xFFE6EDF3);
  static const textSDk     = Color(0xFF8B949E);
  static const textMDk     = Color(0xFF484F58);
}

// ════════════════════════════════════════════════════════════════════
//  SettingsScreen
// ════════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String selectedMenu = "Settings";

  // ── Champs Profil syndic ─────────────────────────────────────────
  final _nomSyndicCtrl     = TextEditingController(text: "M. Ahmed Benali");
  final _emailSyndicCtrl   = TextEditingController(text: "ahmed.benali@syndicontrol.ma");
  final _telSyndicCtrl     = TextEditingController(text: "+212 6 12 34 56 78");
  final _adresseSyndicCtrl = TextEditingController(text: "Casablanca, Maroc");

  // ── Champs Copropriété ───────────────────────────────────────────
  final _nomResCtrl   = TextEditingController(text: "Résidence Al Amal");
  final _adrResCtrl   = TextEditingController(text: "Bd Al Qods, Casablanca");
  final _nbCoproCtrl  = TextEditingController(text: "20");
  final _nbImmCtrl    = TextEditingController(text: "2");
  final _nbApptCtrl   = TextEditingController(text: "40");

  // ── Helpers couleurs dynamiques ──────────────────────────────────
  bool   get _dark  => context.watch<AppState>().isDark;
  String get _lang  => context.watch<AppState>().langue;
  bool   get _isAr  => _lang == "العربية";

  Color get _bg      => _dark ? _P.bgDk      : _P.bg;
  Color get _surface => _dark ? _P.surfaceDk  : _P.surface;
  Color get _border  => _dark ? _P.borderDk   : _P.border;
  Color get _textP   => _dark ? _P.textPDk    : _P.textP;
  Color get _textS   => _dark ? _P.textSDk    : _P.textS;
  Color get _textM   => _dark ? _P.textMDk    : _P.textM;

  String _t(String key) => _Lang.t(key, _lang);

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bg,
        drawer: _buildDrawer(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHeader(),
                  Positioned(
                    bottom: -60, left: 20, right: 20,
                    child: _buildSyndicAvatarCard(),
                  ),
                ],
              ),
              const SizedBox(height: 80),

              // ── 1️⃣ PROFIL DU SYNDIC ───────────────────────────
              _section(
                titre: _t("profil_title"),
                icon: Icons.manage_accounts_outlined,
                color: _P.primaryBlue,
                children: [
                  _editableField(Icons.person_outline_rounded,      _t("nom_syndic"),     _nomSyndicCtrl,     _P.primaryBlue),
                  _div(),
                  _editableField(Icons.email_outlined,               _t("email_syndic"),   _emailSyndicCtrl,   _P.blue),
                  _div(),
                  _editableField(Icons.phone_outlined,               _t("tel_syndic"),     _telSyndicCtrl,     _P.success),
                  _div(),
                  _editableField(Icons.location_on_outlined,         _t("adresse_syndic"), _adresseSyndicCtrl, _P.warning),
                  _div(),
                  _nav(Icons.lock_outline_rounded,  _t("change_pwd"),  _t("change_pwd_sub"), _P.blue, _showPasswordSheet),
                  _div(),
                  _saveRow(_P.primaryBlue),
                ],
              ),
              const SizedBox(height: 16),

              // ── 2️⃣ INFORMATIONS COPROPRIÉTÉ ────────────────────
              _section(
                titre: _t("copro_title"),
                icon: Icons.apartment_rounded,
                color: _P.primaryBlue,
                children: [
                  _editableField(Icons.home_work_outlined,           _t("nom_residence"),      _nomResCtrl,  _P.purple),
                  _div(),
                  _editableField(Icons.location_on_outlined,         _t("adresse_residence"),  _adrResCtrl,  _P.warning),
                  _div(),
                  _editableField(Icons.people_alt_outlined,          _t("nb_coproprietaires"), _nbCoproCtrl, _P.blue,    isNumber: true),
                  _div(),
                  _editableField(Icons.domain_outlined,              _t("nb_immeubles"),       _nbImmCtrl,   _P.success, isNumber: true),
                  _div(),
                  _editableField(Icons.meeting_room_outlined,        _t("nb_appartements"),    _nbApptCtrl,  _P.accent,  isNumber: true),
                  _div(),
                  _saveRow(_P.purple),
                ],
              ),
              const SizedBox(height: 16),

              // ── 3️⃣ LANGUE ET APPARENCE ─────────────────────────
              _section(
                titre: _t("apparat_title"),
                icon: Icons.palette_outlined,
                color: _P.primaryBlue,
                children: [
                  _toggleProvider(
                    icon: Icons.dark_mode_outlined,
                    label: _t("dark_mode"),
                    sub: _t("dark_mode_sub"),
                    value: _dark,
                    color: _P.indigo,
                    onChanged: (v) => context.read<AppState>().setDark(v),
                  ),
                  _div(),
                  _langueRow(),
                ],
              ),
              const SizedBox(height: 16),

              _logoutBtn(),
              const SizedBox(height: 14),
              Text("SyndiControl © 2025 · v2.1.4",
                  style: TextStyle(fontSize: 11, color: _textM)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(children: [
        Image.asset("assets/j.jpg", fit: BoxFit.cover, width: double.infinity),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_P.primaryBlue.withOpacity(0.4), _P.primaryBlue.withOpacity(0.9)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: 60, left: 20, right: 20,
          child: Builder(
            builder: (ctx) => Row(children: [
              GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(_t("settings"), textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 28),
            ]),
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  CARTE AVATAR SYNDIC (flottante)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSyndicAvatarCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004E7A), Color(0xFF006DAA)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(children: [
        // Avatar / logo
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
          ),
          padding: const EdgeInsets.all(6),
          child: Image.asset("assets/logo.png", fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_nomSyndicCtrl.text,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          Text(_emailSyndicCtrl.text,
              style: const TextStyle(color: Color(0xFFC2E9FF), fontSize: 11)),
          const SizedBox(height: 2),
          Text(_telSyndicCtrl.text,
              style: const TextStyle(color: Color(0xFFC2E9FF), fontSize: 11)),
        ])),
        Column(children: [
          Text(_nbCoproCtrl.text,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("copro.", style: TextStyle(color: Color(0xFFC2E9FF), fontSize: 10)),
        ]),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  CHAMP ÉDITABLE INLINE
  // ══════════════════════════════════════════════════════════════════
  Widget _editableField(IconData icon, String label, TextEditingController ctrl, Color color,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 11, color: _textM, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            TextField(
              controller: ctrl,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textP),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: InputBorder.none,
                hintText: label,
                hintStyle: TextStyle(fontSize: 13, color: _textM),
              ),
            ),
          ]),
        ),
        Icon(Icons.edit_outlined, size: 14, color: _textM),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  BOUTON ENREGISTRER (dans une section) — couleur unifiée
  // ══════════════════════════════════════════════════════════════════
  Widget _saveRow(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: SizedBox(
        width: double.infinity, height: 44,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _P.primaryBlue, // couleur unique pour tous les boutons
            foregroundColor: Colors.white, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            setState(() {}); // rafraîchit la carte flottante
            _showSuccessDialog();
          },
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            
            const SizedBox(width: 8),
            Text(_t("enregistrer"), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  DIALOG SUCCÈS
  // ══════════════════════════════════════════════════════════════════
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Icône animée
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
            ),
            const SizedBox(height: 20),
            Text(
              _t("saved"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textP),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _lang == "العربية"
                  ? "تم حفظ جميع التعديلات بنجاح"
                  : _lang == "English"
                      ? "All changes have been saved successfully."
                      : "Toutes vos modifications ont été sauvegardées.",
              style: TextStyle(fontSize: 13, color: _textS, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Barre de progression verte décorative
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 1.0, minHeight: 4,
                backgroundColor: Color(0xFFD1FAE5),
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _P.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _lang == "العربية" ? "حسناً" : _lang == "English" ? "OK" : "Parfait !",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  PASSWORD SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showPasswordSheet() {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        bool o = true, n = true, c = true;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _handle(),
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _P.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.lock_outline_rounded, color: _P.blue, size: 18),
                ),
                const SizedBox(width: 10),
                Text(_t("change_pwd"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textP)),
              ]),
              const SizedBox(height: 20),
              _pwf(ctrl: oldCtrl,  hint: _t("old_pwd"),  obs: o, tog: () => setS(() => o = !o)),
              const SizedBox(height: 10),
              _pwf(ctrl: newCtrl,  hint: _t("new_pwd"),  obs: n, tog: () => setS(() => n = !n)),
              const SizedBox(height: 10),
              _pwf(ctrl: confCtrl, hint: _t("conf_pwd"), obs: c, tog: () => setS(() => c = !c)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _P.blue, foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _toast(_t("pwd_changed"), _P.success, Icons.check_circle_rounded);
                  },
                  child: Text(_t("confirmer"),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  LOGOUT
  // ══════════════════════════════════════════════════════════════════
  Widget _logoutBtn() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: _P.danger.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _P.danger.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.logout_rounded, color: _P.danger, size: 20),
          const SizedBox(width: 10),
          Text(_t("logout"),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _P.danger, letterSpacing: 0.3)),
        ]),
      ),
    ),
  );

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.logout_rounded, color: _P.danger, size: 20),
          const SizedBox(width: 8),
          Text(_t("logout"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textP)),
        ]),
        content: Text(_t("logout_confirm"), style: TextStyle(fontSize: 13, color: _textS, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t("annuler"), style: TextStyle(color: _textS, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _P.danger, foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _toast(_t("disconnected"), _P.danger, Icons.logout_rounded);
            },
            child: Text(_t("logout"), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SECTION / TOGGLE / NAV / LANGUE
  // ══════════════════════════════════════════════════════════════════
  Widget _section({
    required String titre,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(7)),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 7),
            Text(titre.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.8)),
          ]),
        ),
        Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_dark ? 0.2 : 0.04),
                blurRadius: 12, offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(20),
              child: Column(children: children)),
        ),
      ]),
    );
  }

  Widget _toggle(IconData icon, String label, String sub, bool val, Color color,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textP)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: _textS)),
        ])),
        CupertinoSwitch(value: val, onChanged: onChanged, activeColor: color, trackColor: _border),
      ]),
    );
  }

  Widget _toggleProvider({
    required IconData icon, required String label, required String sub,
    required bool value, required Color color, required ValueChanged<bool> onChanged,
  }) => _toggle(icon, label, sub, value, color, onChanged);

  Widget _nav(IconData icon, String label, String sub, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textP)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 11, color: _textS)),
          ])),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(
              _isAr ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
              size: 12, color: _textM,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _langueRow() {
    final langs = [
      {"code": "Français", "flag": "🇫🇷", "short": "FR"},
      {"code": "العربية",  "flag": "🇲🇦", "short": "AR"},
      {"code": "English",  "flag": "🇬🇧", "short": "EN"},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: _P.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
          child: const Icon(Icons.language_outlined, size: 19, color: _P.blue),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(_t("langue"),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textP))),
        Row(
          children: langs.map((l) {
            final bool sel = _lang == l["code"];
            return GestureDetector(
              onTap: () => context.read<AppState>().setLangue(l["code"]!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? _P.blue.withOpacity(0.12) : _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? _P.blue.withOpacity(0.5) : _border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(l["flag"]!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(l["short"]!, style: TextStyle(
                      fontSize: 11,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: sel ? _P.blue : _textS)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }

  // ── Micro helpers ────────────────────────────────────────────────
  Widget _div() => Divider(height: 1, color: _border, indent: 66);

  Widget _handle() => Container(
    width: 40, height: 4,
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)),
  );

  Widget _pwf({required TextEditingController ctrl, required String hint,
      required bool obs, required VoidCallback tog}) {
    return Container(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: TextField(
        controller: ctrl, obscureText: obs,
        style: TextStyle(fontSize: 13, color: _textP),
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(fontSize: 13, color: _textM),
          prefixIcon: Icon(Icons.lock_outline_rounded, size: 17, color: _textM),
          suffixIcon: GestureDetector(
            onTap: tog,
            child: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 17, color: _textM),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _toast(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ══════════════════════════════════════════════════════════════════
  //  DRAWER
  // ══════════════════════════════════════════════════════════════════
  Widget _buildDrawer() {
    return AppDrawer(
      selectedMenu: selectedMenu,
      onMenuSelected: (menu) {
        if (menu == selectedMenu) { Navigator.of(context).pop(); return; }
        setState(() => selectedMenu = menu);
        Navigator.of(context).pop();
        if (menu == "Dashboard") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else if (menu == "Habitants") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HabitantsScreen()));
        } else if (menu == "Charges") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChargesScreen()));
        } else if (menu == "Assemblée Générale") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AssemblyDashboardScreen()));
        }
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  AppDrawer
// ════════════════════════════════════════════════════════════════════
const Color primaryBlue = Color(0xFF004E7A);

class AppDrawer extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const AppDrawer({super.key, required this.selectedMenu, required this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.dashboard,      "title": "Dashboard"},
      {"icon": Icons.task,           "title": "Habitants"},
      {"icon": Icons.calendar_month, "title": "Charges"},
      {"icon": Icons.message,        "title": "Assemblée Générale"},
      {"icon": Icons.settings,       "title": "Paramètres"},
    ];

    return Drawer(
      backgroundColor: primaryBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80, height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Bienvenue sur", style: TextStyle(color: Color(0xFFC2E9FF), fontSize: 15)),
            const Text("SyndiControl",
                style: TextStyle(color: Color(0xFFC2E9FF), fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ...menuItems.map((item) {
              final bool isSelected = selectedMenu == item["title"];
              return GestureDetector(
                onTap: () => onMenuSelected(item["title"]),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Icon(item["icon"], color: isSelected ? Colors.white : const Color(0xFFC2E9FF)),
                    const SizedBox(width: 12),
                    Text(item["title"], style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFC2E9FF), fontSize: 16,
                    )),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}