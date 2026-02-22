import 'dart:ui';
import 'package:flutter/material.dart';

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

    final fullName = widget.habitant["name"] ?? "";
    final nameParts = fullName.split(" ");

    firstNameCtrl = TextEditingController(
        text: nameParts.isNotEmpty ? nameParts.first : "");
    lastNameCtrl = TextEditingController(
        text: nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "");

    buildingCtrl =
        TextEditingController(text: widget.habitant["immeuble"] ?? "");
    apartmentCtrl =
        TextEditingController(text: widget.habitant["apt"] ?? "");
    phoneCtrl = TextEditingController(text: widget.habitant["phone"] ?? "");
    emailCtrl = TextEditingController(text: widget.habitant["email"] ?? "");
    role = widget.habitant["role"] ?? "Locataire";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/imm.jpg", fit: BoxFit.cover),
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
            "Modifier l'habitant",
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

  Widget _formCard() {
    return _glassCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const _SectionTitle("Informations de l'habitant"),

            _lineField(Icons.person, "Prénom", firstNameCtrl),
            _lineField(Icons.person_outline, "Nom", lastNameCtrl),
            _lineField(Icons.apartment, "Immeuble", buildingCtrl),
            _lineField(Icons.home, "Appartement", apartmentCtrl),
            _lineField(Icons.phone, "Téléphone", phoneCtrl,
                keyboard: TextInputType.phone),
            _lineField(Icons.email, "Email", emailCtrl,
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
        style: const TextStyle(color: Color(0xFF004E7A)),
        validator: (v) {
          if (v == null || v.isEmpty) return "Champ requis";
          if (label == "Téléphone" && !RegExp(r'^\d{10}$').hasMatch(v)) {
            return "Numéro invalide";
          }
          if (label == "Email" && !v.contains('@')) {
            return "Email invalide";
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF004E7A)),
          labelText: label,
          labelStyle: const TextStyle(
  color: Colors.white,
  fontSize: 20, // <-- taille du label
),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: role,
      dropdownColor: const Color(0xFF004E7A),
      style: const TextStyle(color: Colors.white,fontSize: 16),
      decoration: const InputDecoration(
        labelText: "Rôle",
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white38),
        ),
      ),
      items: const [
        DropdownMenuItem(value: "Propriétaire", child: Text("Propriétaire")),
        DropdownMenuItem(value: "Locataire", child: Text("Locataire")),
      ],
      onChanged: (v) => setState(() => role = v!),
    );
  }

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
        onPressed: _updateHabitant,
        child: const Text(
          "Modifier",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  void _updateHabitant() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        "name": "${firstNameCtrl.text} ${lastNameCtrl.text}",
        "immeuble": buildingCtrl.text,
        "apt": apartmentCtrl.text,
        "phone": phoneCtrl.text,
        "email": emailCtrl.text,
        "role": role,
      });
    }
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(26),
          ),
          child: child,
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
