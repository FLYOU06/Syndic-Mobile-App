import 'dart:ui';
import 'package:flutter/material.dart';


class AddHabitantScreen extends StatefulWidget {
  const AddHabitantScreen({super.key});

  @override
  State<AddHabitantScreen> createState() => _AddHabitantScreenState();
}

class _AddHabitantScreenState extends State<AddHabitantScreen> {
  final _formKey = GlobalKey<FormState>();

  String firstName = "";
  String lastName = "";
  String building = "";
  String apartment = "";
  String phone = "";
  String email = "";
  String role = "Locataire";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ================= BACKGROUND =================
          Positioned.fill(
            child: Image.asset(
              "assets/imm.jpg",
              fit: BoxFit.cover,
            ),
          ),
                  Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                 
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
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

          SafeArea(
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Transform.translate(
                      offset: const Offset(0, 0), // ⬆️ remonte la carte
                      child: _formCard(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            "Ajouter un habitant",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FORM CARD =================
  Widget _formCard() {
    return _glassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle("Informations de l'habitant"),

            _lineField(Icons.person, "Nom", (v) => lastName = v),
            _lineField(Icons.person_outline, "Prénom", (v) => firstName = v),
            _lineField(Icons.apartment, "Immeuble", (v) => building = v),
            _lineField(Icons.home, "Appartement", (v) => apartment = v),
            _lineField(Icons.phone, "Téléphone", (v) => phone = v,
                keyboard: TextInputType.phone),
            _lineField(Icons.email, "Email", (v) => email = v,
                keyboard: TextInputType.emailAddress),

            const SizedBox(height: 16),
            _roleDropdown(),
            const SizedBox(height: 28),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  // ================= LINE TEXT FIELD =================
// ================= LINE TEXT FIELD =================
Widget _lineField(
  IconData icon,
  String label,
  Function(String) onChanged, {
  TextInputType keyboard = TextInputType.text,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      keyboardType: keyboard,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFF004E7A)),
      validator: (v) {
        if (v == null || v.isEmpty) return "Champ requis";

        if (label == "Téléphone") {
          // Vérifie si le téléphone contient exactement 10 chiffres
          final regex = RegExp(r'^\d{10}$');
          if (!regex.hasMatch(v)) return "Numéro de téléphone invalide";
        }

        if (label == "Email") {
          // Vérifie si l'email contient '@'
          if (!v.contains('@')) return "Email invalide";
        }

        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF004E7A)),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF004E7A)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF004E7A), width: 2),
        ),
      ),
    ),
  );
}

  // ================= DROPDOWN =================
  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: role,
      dropdownColor: const Color.fromARGB(255, 251, 251, 251),
      style: const TextStyle(color: Color(0xFF004E7A)),
      decoration: const InputDecoration(
        labelText: "Rôle",
        labelStyle: TextStyle(color: Color(0xFF004E7A)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Propriétaire", child: Text("Propriétaire")),
        DropdownMenuItem(value: "Locataire", child: Text("Locataire")),
      ],
      onChanged: (v) {
        if (v != null) setState(() => role = v);
      },
    );
  }

  // ================= BUTTON =================
  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004E7A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: _saveHabitant,
child: const Text(
  "Enregistrer",
  style: TextStyle(
    fontSize: 16, 
    fontWeight: FontWeight.bold,
    color: Colors.white, // Blanc (par défaut)
  ),
),
      ),
    );
  }

  // ================= SAVE =================
  void _saveHabitant() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        "name": "$firstName $lastName",
        "immeuble": building,
        "apt": apartment,
        "phone": phone,
        "email": email,
        "role": role,
      });
    }
  }

  // ================= GLASS CARD =================
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ================= SECTION TITLE =================
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 2, 62, 90),
        ),
      ),
    );
  }
}
