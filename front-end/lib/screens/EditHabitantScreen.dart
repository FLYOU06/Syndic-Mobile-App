import 'dart:ui';
import 'package:flutter/material.dart';

const _navy  = Color(0xFF004E7A);
const _green = Color(0xFF00B87A);
const _red   = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);

class EditHabitantScreen extends StatefulWidget {
  final Map<String, String> habitant;

  const EditHabitantScreen({
    super.key,
    required this.habitant,
  });

  @override
  State<EditHabitantScreen> createState() => _EditHabitantScreenState();
}

class _EditHabitantScreenState extends State<EditHabitantScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController buildingCtrl;
  late TextEditingController apartmentCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;

  String role = "Locataire";

  @override
  void initState() {
    super.initState();
    final fullName  = widget.habitant["name"] ?? "";
    final nameParts = fullName.split(" ");

    firstNameCtrl  = TextEditingController(text: nameParts.isNotEmpty ? nameParts.first : "");
    lastNameCtrl   = TextEditingController(text: nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "");
    buildingCtrl   = TextEditingController(text: widget.habitant["immeuble"] ?? "");
    apartmentCtrl  = TextEditingController(text: widget.habitant["apt"]      ?? "");
    phoneCtrl      = TextEditingController(text: widget.habitant["phone"]    ?? "");
    emailCtrl      = TextEditingController(text: widget.habitant["email"]    ?? "");
    role           = widget.habitant["role"] ?? "Locataire";
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    buildingCtrl.dispose();
    apartmentCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  TOAST
  // ══════════════════════════════════════════════════════════════
  void _showToast({required String message, required _ToastType type}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imm.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _formCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HEADER
  // ══════════════════════════════════════════════════════════════
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 10),
        const Text(
          "Modifier l'habitant",
          style: TextStyle(
              color: Colors.white, fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  FORM CARD
  // ══════════════════════════════════════════════════════════════
  Widget _formCard() {
    return _glassCard(
      child: Form(
        key: _formKey,
        child: Column(children: [
          const _SectionTitle("Informations de l'habitant"),

          _lineField(Icons.person,          "Prénom",      firstNameCtrl),
          _lineField(Icons.person_outline,  "Nom",         lastNameCtrl),
          _lineField(Icons.apartment,       "Immeuble",    buildingCtrl),
          _lineField(Icons.home,            "Appartement", apartmentCtrl),
          _lineField(Icons.phone,           "Téléphone",   phoneCtrl,
              keyboard: TextInputType.phone),
          _lineField(Icons.email,           "Email",       emailCtrl,
              keyboard: TextInputType.emailAddress),

          const SizedBox(height: 16),
          _roleDropdown(),
          const SizedBox(height: 28),
          _saveButton(),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CHAMP TEXTE — validation inline améliorée
  // ══════════════════════════════════════════════════════════════
  Widget _lineField(
    IconData icon,
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: _navy, fontSize: 15),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null; // géré par le toast
          if (label == "Téléphone" &&
              !RegExp(r'^\+?[\d\s]{8,15}$').hasMatch(v.trim())) {
            return "Format invalide (ex: +212 6 12 34 56 78)";
          }
          if (label == "Email" && !v.contains('@')) {
            return "Email invalide (ex: nom@domaine.com)";
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _navy, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),

          // ── Bordure normale ──
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          // ── Bordure focus ──
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
          // ── Bordure erreur ──
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _red.withOpacity(0.8), width: 1.5),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _red, width: 2),
          ),

          // ── Message d'erreur stylisé ──
          errorStyle: const TextStyle(
            color: Color(0xFFFF8A80),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DROPDOWN RÔLE
  // ══════════════════════════════════════════════════════════════
  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: role,
      dropdownColor: _navy,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.badge_outlined, color: _navy, size: 20),
        labelText: "Rôle",
        labelStyle: TextStyle(color: Colors.white70, fontSize: 14),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
      items: const [
        DropdownMenuItem(
            value: "Propriétaire", child: Text("Propriétaire")),
        DropdownMenuItem(
            value: "Locataire",    child: Text("Locataire")),
      ],
      onChanged: (v) => setState(() => role = v!),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BOUTON ENREGISTRER
  // ══════════════════════════════════════════════════════════════
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _updateHabitant,
        child: const Text("Modifier",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGIQUE MISE À JOUR
  // ══════════════════════════════════════════════════════════════
  void _updateHabitant() {
    // Vérification champs vides → toast warning
    final Map<String, String> champsVides = {
      "Prénom":      firstNameCtrl.text.trim(),
      "Nom":         lastNameCtrl.text.trim(),
      "Immeuble":    buildingCtrl.text.trim(),
      "Appartement": apartmentCtrl.text.trim(),
      "Téléphone":   phoneCtrl.text.trim(),
      "Email":       emailCtrl.text.trim(),
    };

    final vides = champsVides.entries
        .where((e) => e.value.isEmpty)
        .map((e) => e.key)
        .toList();

    if (vides.isNotEmpty) {
      _showToast(
        message: "Champ${vides.length > 1 ? 's' : ''} requis : ${vides.join(', ')}",
        type: _ToastType.warning,
      );
      return;
    }

    // Validation format → toast error
    if (!RegExp(r'^\+?[\d\s]{8,15}$')
        .hasMatch(phoneCtrl.text.trim())) {
      _showToast(
        message: "Numéro de téléphone invalide\nEx : +212 6 12 34 56 78",
        type: _ToastType.error,
      );
      return;
    }

    if (!emailCtrl.text.trim().contains('@')) {
      _showToast(
        message: "Adresse email invalide\nEx : nom@domaine.com",
        type: _ToastType.error,
      );
      return;
    }

    // Validation Form (formats inline)
    if (!_formKey.currentState!.validate()) return;

    // Succès
    _showToast(
      message: "Habitant modifié avec succès !",
      type: _ToastType.success,
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        Navigator.pop(context, {
          "name":     "${firstNameCtrl.text.trim()} ${lastNameCtrl.text.trim()}",
          "immeuble": buildingCtrl.text.trim(),
          "apt":      apartmentCtrl.text.trim(),
          "phone":    phoneCtrl.text.trim(),
          "email":    emailCtrl.text.trim(),
          "role":     role,
        });
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  GLASS CARD
  // ══════════════════════════════════════════════════════════════
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.40),
            borderRadius: BorderRadius.circular(26),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SECTION TITLE
// ══════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TOAST TYPE
// ══════════════════════════════════════════════════════════════════
enum _ToastType { success, error, warning }

// ══════════════════════════════════════════════════════════════════
//  TOAST WIDGET — même design que LoginScreen
// ══════════════════════════════════════════════════════════════════
class _ToastWidget extends StatefulWidget {
  final String message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<double>(begin: -80, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3500), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case _ToastType.success: return const Color.fromARGB(255, 34, 173, 55);
      case _ToastType.error:   return const Color(0xFFDC2626);
      case _ToastType.warning: return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case _ToastType.success: return Icons.check_circle_rounded;
      case _ToastType.error:   return Icons.error_rounded;
      case _ToastType.warning: return Icons.warning_amber_rounded;
    }
  }

  String get _label {
    switch (widget.type) {
      case _ToastType.success: return "Succès";
      case _ToastType.error:   return "Erreur";
      case _ToastType.warning: return "Attention";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(opacity: _fadeAnim.value, child: child),
        ),
        child: GestureDetector(
          onTap: _dismiss,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _bgColor.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(children: [
                // Icône
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(widget.message,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton fermer
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}