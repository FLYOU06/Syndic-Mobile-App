import 'dart:ui';
import 'package:flutter/material.dart';
import 'EditHabitantScreen.dart';

const _navy  = Color(0xFF004E7A);
const _green = Color(0xFF00B87A);
const _greenL = Color(0xFFE8F9F3);
const _red   = Color(0xFFEF4444);
const _redL  = Color(0xFFFEF2F2);
const _amber = Color(0xFFF59E0B);

class HabitantDetailsScreen extends StatefulWidget {
  final Map<String, String> habitant;

  const HabitantDetailsScreen({
    super.key,
    required this.habitant,
  });

  @override
  State<HabitantDetailsScreen> createState() => _HabitantDetailsScreenState();
}

class _HabitantDetailsScreenState extends State<HabitantDetailsScreen> {
  late Map<String, String> habitant;

  final List<String> paymentMethods = ["Espèces", "Virement", "Chèque"];

  final List<Map<String, dynamic>> _modesPaiement = [
    {"label": "Espèces",  "icon": Icons.payments_outlined,        "color": _green},
    {"label": "Virement", "icon": Icons.account_balance_outlined,  "color": _navy},
    {"label": "Chèque",   "icon": Icons.description_outlined,      "color": _amber},
  ];

  List<Map<String, dynamic>> charges = [
    {"name": "Eau",         "price": 120, "paid": true,  "date": "2026-01-05", "method": "Espèces"},
    {"name": "Électricité", "price": 180, "paid": false, "date": null,         "method": null},
    {"name": "Entretien",   "price": 100, "paid": true,  "date": "2026-01-10", "method": "Virement"},
    {"name": "Jardinier",   "price": 150, "paid": false, "date": null,         "method": null},
  ];

  // Copie de travail pour détecter les changements
  late List<Map<String, dynamic>> _chargesSnapshot;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    habitant = Map<String, String>.from(widget.habitant);
    _chargesSnapshot = charges.map((c) => Map<String, dynamic>.from(c)).toList();
  }

  void _checkChanges() {
    bool changed = false;
    for (int i = 0; i < charges.length; i++) {
      if (charges[i]["paid"] != _chargesSnapshot[i]["paid"] ||
          charges[i]["method"] != _chargesSnapshot[i]["method"]) {
        changed = true;
        break;
      }
    }
    setState(() => _hasChanges = changed);
  }

  // ── Calculs ───────────────────────────────────────────────────
  int get total => charges.fold(0, (s, c) => s + c["price"] as int);
  int get paid  => charges.where((c) => c["paid"] == true)
      .fold(0, (s, c) => s + c["price"] as int);
  int get rest  => total - paid;

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Image fond ─────────────────────────────────────────
          Positioned.fill(
            child: Image.asset("assets/imm.jpg", fit: BoxFit.cover),
          ),
          // ── Blur + overlay ──────────────────────────────────────
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(),
            ),
          ),

          // ── Contenu ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _header(context),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _infoCard(),
                      const SizedBox(height: 16),
                      _paymentCard(),
                      const SizedBox(height: 16),
                      _chargesCard(),       // ← nouveau design
                      const SizedBox(height: 24),
                      _actions(context),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Avatar flottant ─────────────────────────────────────
          Positioned(
            top: 95, left: 0, right: 0,
            child: Center(child: _avatar()),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HEADER & AVATAR  (identiques à l'original)
  // ══════════════════════════════════════════════════════════════
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 42,
        backgroundColor: const Color(0xFF006494),
        child: Text(
          habitant["name"]![0].toUpperCase(),
          style: const TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CARTES INFOS & PAIEMENTS  (identiques à l'original)
  // ══════════════════════════════════════════════════════════════
  Widget _infoCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Informations"),
          _infoRow(Icons.person,    habitant["name"]     ?? "-"),
          _infoRow(Icons.apartment, habitant["immeuble"] ?? "-"),
          _infoRow(Icons.home,      habitant["apt"]      ?? "-"),
          _infoRow(Icons.phone,     habitant["phone"]    ?? "-"),
          _infoRow(Icons.email,     habitant["email"]    ?? "-"),
          _infoRow(Icons.badge,     habitant["role"]     ?? "-"),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Paiements"),
          _paymentRow("Total à payer", "$total DH"),
          _paymentRow("Payé",          "$paid DH"),
          _paymentRow("Reste",         "$rest DH", red: true),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CHARGES CARD — NOUVEAU DESIGN
  // ══════════════════════════════════════════════════════════════
  Widget _chargesCard() {
    return Column(
      children: [
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ──────────────────────────────────────────
              const _SectionTitle("Charges"),

              // ── Liste des charges ──────────────────────────────
              ...charges.map(_chargeRow),
            ],
          ),
        ),

        // ── Bouton Enregistrer — toujours visible, hors de la carte ──
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: GestureDetector(
              onTap: _enregistrerCharges,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_navy, Color(0xFF006DAA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Enregistrer les charges",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _enregistrerCharges() {
    // Mettre à jour le snapshot
    _chargesSnapshot =
        charges.map((c) => Map<String, dynamic>.from(c)).toList();
    setState(() => _hasChanges = false);

    // Toast succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text("Charges enregistrées avec succès",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LIGNE DE CHARGE — NOUVEAU DESIGN
  // ══════════════════════════════════════════════════════════════
  Widget _chargeRow(Map<String, dynamic> c) {
    final bool isPaid = c["paid"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPaid
            ? _green.withOpacity(0.07)
            : _red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? _green.withOpacity(0.25)
              : _red.withOpacity(0.20),
          width: 1.2,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Ligne principale ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
          child: Row(children: [
            // Icône charge
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isPaid
                    ? _green.withOpacity(0.12)
                    : _red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForCharge(c["name"]),
                  size: 18, color: isPaid ? _green : _red),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(c["name"],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: _navy)),
                Text("${c["price"]} DH",
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: isPaid ? _green : _red)),
              ]),
            ),
            // Badge statut — tap pour basculer
            GestureDetector(
              onTap: () {
                setState(() {
                  c["paid"] = !c["paid"];
                  if (c["paid"]) {
                    c["date"]   = DateTime.now().toString().substring(0, 10);
                    c["method"] ??= "Espèces";
                  } else {
                    c["date"]   = null;
                    c["method"] = null;
                  }
                });
                _checkChanges();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPaid ? _green : _red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isPaid ? _green : _red).withOpacity(0.30),
                      blurRadius: 8, offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: Colors.white, size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPaid ? "Payé" : "Impayé",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ]),
              ),
            ),
          ]),
        ),

        // ── Mode de paiement (visible si payé) ───────────────────
        if (isPaid) ...[
          Divider(height: 1, indent: 14, endIndent: 14,
              color: _green.withOpacity(0.25)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Date
              Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _navy),
                const SizedBox(width: 6),
                Text("Payé le ${c["date"]}",
                    style: const TextStyle(
                        fontSize: 12, color: _navy,
                        fontWeight: FontWeight.w500)),
              ]),
              const SizedBox(height: 10),

              // Label
              const Text("Mode de paiement",
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: _navy)),
              const SizedBox(height: 8),

              // 3 cartes cliquables
              Row(children: _modesPaiement.map((mode) {
                final bool isSelected = c["method"] == mode["label"];
                final Color modeColor = mode["color"] as Color;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => c["method"] = mode["label"]);
                      _checkChanges();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: mode == _modesPaiement.last ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? modeColor.withOpacity(0.10)
                            : Colors.white.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? modeColor
                              : Colors.grey.withOpacity(0.25),
                          width: isSelected ? 1.8 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: modeColor.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? modeColor.withOpacity(0.15)
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isSelected
                                    ? modeColor.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.2)),
                          ),
                          child: Icon(mode["icon"] as IconData,
                              size: 18,
                              color: isSelected
                                  ? modeColor
                                  : Colors.grey.shade400),
                        ),
                        const SizedBox(height: 5),
                        Text(mode["label"] as String,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? modeColor
                                    : Colors.grey.shade500)),
                        if (isSelected) ...[
                          const SizedBox(height: 3),
                          Icon(Icons.check_circle_rounded,
                              size: 11, color: modeColor),
                        ],
                      ]),
                    ),
                  ),
                );
              }).toList()),
            ]),
          ),
        ],
      ]),
    );
  }

  IconData _iconForCharge(String name) {
    switch (name.toLowerCase()) {
      case "eau":         return Icons.water_drop_outlined;
      case "électricité": return Icons.flash_on_outlined;
      case "entretien":   return Icons.build_outlined;
      case "jardinier":   return Icons.local_florist_outlined;
      default:            return Icons.receipt_outlined;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  ACTIONS  (identiques à l'original)
  // ══════════════════════════════════════════════════════════════
  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _editHabitant,
            child: const Text("Modifier",
                style: TextStyle(
                    color: Color(0xFF006494),
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => _confirmDelete(context),
            child: const Text("Supprimer",
                style: TextStyle(
                    color: Color.fromARGB(255, 190, 9, 6),
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // ── Icône ─────────────────────────────────────────────
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _red.withOpacity(0.20), width: 1.5),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 34, color: _red),
            ),
            const SizedBox(height: 18),

            // ── Titre ─────────────────────────────────────────────
            const Text("Supprimer l'habitant",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _navy)),
            const SizedBox(height: 10),

            // ── Message ───────────────────────────────────────────
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5),
                children: [
                  const TextSpan(text: "Êtes-vous sûr de vouloir supprimer "),
                  TextSpan(
                    text: habitant["name"] ?? "cet habitant",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _navy),
                  ),
                  const TextSpan(
                      text: " ?\nCette action est "),
                  const TextSpan(
                    text: "irréversible",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _red),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Séparateur ────────────────────────────────────────
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 18),

            // ── Boutons ───────────────────────────────────────────
            Row(children: [
              // Annuler
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Annuler",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              // Confirmer suppression
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);           // ferme le dialog
                    Navigator.pop(context, "delete"); // retour avec résultat
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_rounded, size: 16),
                      SizedBox(width: 6),
                      Text("Supprimer",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _editHabitant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => EditHabitantScreen(habitant: habitant)),
    );
    if (result != null && result is Map<String, String>) {
      setState(() => habitant = Map<String, String>.from(result));
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPERS UI  (identiques à l'original)
  // ══════════════════════════════════════════════════════════════
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006494)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _paymentRow(String label, String value, {bool red = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: red
                    ? const Color.fromARGB(255, 190, 9, 6)
                    : Colors.black,
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  SECTION TITLE  (identique à l'original)
// ══════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF004E7A),
              fontSize: 16)),
    );
  }
}