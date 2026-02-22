import 'dart:ui';
import 'package:flutter/material.dart';
import 'EditHabitantScreen.dart';

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

  // =========================
  // MOYENS DE PAIEMENT (SYNDIC)
  // =========================
  final List<String> paymentMethods = [
    "Espèces",
    "Virement",
    "Chèque",
  ];

  // =========================
  // CHARGES
  // =========================
  List<Map<String, dynamic>> charges = [
    {
      "name": "Eau",
      "price": 120,
      "paid": true,
      "date": "2026-01-05",
      "method": "Espèces",
    },
    {
      "name": "Électricité",
      "price": 180,
      "paid": false,
      "date": null,
      "method": null,
    },
    {
      "name": "Entretien",
      "price": 100,
      "paid": true,
      "date": "2026-01-10",
      "method": "Virement",
    },
    {
      "name": "Jardinier",
      "price": 150,
      "paid": false,
      "date": null,
      "method": null,
    },
  ];

  @override
  void initState() {
    super.initState();
    habitant = Map<String, String>.from(widget.habitant);
  }

  // =========================
  // CALCULS
  // =========================
  int get total => charges.fold(0, (s, c) => s + c["price"] as int);
  int get paid =>
      charges.where((c) => c["paid"] == true).fold(0, (s, c) => s + c["price"] as int);
  int get rest => total - paid;

  // =========================
  // UI PRINCIPALE
  // =========================
  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [

        // ===== IMAGE =====
        Positioned.fill(
          child: Image.asset(
            "assets/imm.jpg",
            fit: BoxFit.cover,
          ),
        ),

        // ===== BLUR + OVERLAY BLEU =====
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              
            ),
          ),
        ),

        // ===== CONTENU =====
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
                    _chargesCard(),
                    const SizedBox(height: 24),
                    _actions(context),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ===== AVATAR AU-DESSUS =====
        Positioned(
          top: 95,
          left: 0,
          right: 0,
          child: Center(
            child: _avatar(),
          ),
        ),
      ],
    ),
  );
}

  // =========================
  // HEADER & AVATAR
  // =========================
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
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =========================
  // CARTES
  // =========================
  Widget _infoCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Informations"),
          _infoRow(Icons.person, habitant["name"] ?? "-"),
          _infoRow(Icons.apartment, habitant["immeuble"] ?? "-"),
          _infoRow(Icons.home, habitant["apt"] ?? "-"),
          _infoRow(Icons.phone, habitant["phone"] ?? "-"),
          _infoRow(Icons.email, habitant["email"] ?? "-"),
          _infoRow(Icons.badge, habitant["role"] ?? "-"),
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
          _paymentRow("Payé", "$paid DH"),
          _paymentRow("Reste", "$rest DH", red: true),
        ],
      ),
    );
  }

  Widget _chargesCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle("Charges"),
          ...charges.map(_chargeRow),
        ],
      ),
    );
  }

  // =========================
  // CHARGE AVEC MOYEN CHOISI
  // =========================
Widget _chargeRow(Map<String, dynamic> c) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                "${c["name"]} - ${c["price"]} DH",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    c["paid"] = !c["paid"];
                    if (c["paid"]) {
                      c["date"] = DateTime.now().toString().substring(0, 10);
                      c["method"] ??= paymentMethods.first;
                    } else {
                      c["date"] = null;
                      c["method"] = null;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: c["paid"]
                        ? const Color.fromARGB(255, 25, 131, 30)
                        : const Color.fromARGB(255, 190, 9, 6),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          c["paid"] ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          c["paid"] ? "PAYÉ" : "IMPAYÉ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (c["paid"] == true)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Color.fromARGB(255, 52, 82, 135)),
                    const SizedBox(width: 6),
                    Text(
                      "${c["date"]}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text("💳 Moyen : "),
                    DropdownButton<String>(
                      value: c["method"],
                      underline: const SizedBox(),
                      items: paymentMethods
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => c["method"] = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        const Divider(),
      ],
    ),
  );
}

  // =========================
  // ACTIONS
  // =========================
  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _editHabitant,
            child: const Text(
              "Modifier",
              style: TextStyle(color: Color(0xFF006494), fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.65),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.pop(context, "delete"),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Color.fromARGB(255, 190, 9, 6), fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editHabitant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditHabitantScreen(habitant: habitant)),
    );

    if (result != null && result is Map<String, String>) {
      setState(() => habitant = Map<String, String>.from(result));
    }
  }

  // =========================
  // OUTILS UI
  // =========================
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: red ? const Color.fromARGB(255, 190, 9, 6) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF004E7A),
          fontSize: 16,
        ),
      ),
    );
  }
}
