import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


const Color primaryBlue = Color(0xFF004E7A);
const Color bgLight = Color(0xFFF4F6FA);

class AddChargeScreen extends StatefulWidget {
  const AddChargeScreen({super.key});

  @override
  State<AddChargeScreen> createState() => _AddChargeScreenState();
}

class _AddChargeScreenState extends State<AddChargeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  double _amount = 0;
  String _date = "";
  String _selectedBuilding = "Sélectionner un immeuble";

  // ================= DATE PICKER =================

Future<void> _selectDate() async {
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2023),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryBlue, 
            onPrimary: Colors.white, 
            onSurface: primaryBlue, 
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue, 
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _date = DateFormat('dd/MM/yyyy').format(picked);
    });
  }
}
  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          _buildHeader(),
          SafeArea(child: _buildContent()),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            "assets/j.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryBlue.withOpacity(0.4),
                  primaryBlue.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }


bool _validateFields() {
  return _nameController.text.isNotEmpty &&
      _descriptionController.text.isNotEmpty &&
      _amount > 0 &&
      _date.isNotEmpty &&
      _selectedBuilding != "Sélectionner un immeuble";
}
  // ================= CONTENT =================

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildTopBar(),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informations de la charge",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // NOM
                  _buildTextField(
                    icon: Icons.badge,
                    label: "Nom de la charge",
                    hint: "veuillez entrer le nom de la charge",
                    controller: _nameController,
                  ),

                  const SizedBox(height: 12),

                  // MONTANT
                  _buildAmountField(),

                  const SizedBox(height: 12),

                  // DATE PICKER
                  _buildSelectableTile(
                    icon: Icons.calendar_today,
                    title: "Date limite de paiement",
                    value: _date,
                    onTap: _selectDate,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Habitants concernés",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  // IMMEUBLES A/B/C/D
                  _buildBuildingDropdown(),

                  const SizedBox(height: 16),

                  // DESCRIPTION
                  _buildTextField(
                    icon: Icons.description,
                    label: "Description",
                    hint: "Veuillez donner une description.",
                    controller: _descriptionController,
                  ),

                  const SizedBox(height: 30),

                  _buildAddButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= TOP BAR =================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            "Ajouter une charge",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // ================= INPUTS =================

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primaryBlue),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: primaryBlue),
          const SizedBox(width: 8),
          const Text(
            "Montant total",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              onChanged: (val) =>
                  setState(() => _amount = double.tryParse(val) ?? 0),
              decoration: const InputDecoration(
                hintText: "0",
                border: InputBorder.none,
              ),
            ),
          ),
          const Text(" MAD"),
        ],
      ),
    );
  }

  Widget _buildSelectableTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: _selectedBuilding,
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          "Sélectionner un immeuble",
          "Immeuble A",
          "Immeuble B",
          "Immeuble C",
          "Immeuble D",
        ]
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedBuilding = value!;
          });
        },
      ),
    );
  }

  // ================= BUTTON =================

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: primaryBlue,
        ),
        onPressed: () {
  if (!_validateFields()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Veuillez remplir tous les champs"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    return;
  }

  // ✅ Tous les champs sont remplis
  print("Nom: ${_nameController.text}");
  print("Description: ${_descriptionController.text}");
  print("Montant: $_amount");
  print("Date: $_date");
  print("Immeuble: $_selectedBuilding");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text("Charge ajoutée avec succès"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
},
        child: const Text(
          "Ajouter la charge",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ,color: Colors.white),
        ),
      ),
    );
  }
}