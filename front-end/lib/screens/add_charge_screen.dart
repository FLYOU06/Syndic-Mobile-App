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
  final TextEditingController _descriptionController = TextEditingController();

  double _amount = 0;
  String _date = "";
  String _selectedBuilding = "Sélectionner un immeuble";
  
  // ================= NOUVEAUX ÉTATS POUR LES BOUTONS =================
  Color _selectedColor = primaryBlue;
  IconData _selectedIcon = Icons.water_drop;
  
  // ================= LISTES DISPONIBLES =================
  final List<Color> _availableColors = [
    const Color(0xFF004E7A), // Bleu principal
    const Color.fromARGB(255, 11, 116, 168), // Bleu clair
    const Color.fromARGB(255, 246, 217, 55), // Jaune
    const Color(0xFF1B8F6A), // Vert
    const Color.fromARGB(255, 203, 88, 120), // Rose
    const Color(0xFF9C27B0), // Violet
    const Color(0xFFFF5722), // Orange
    const Color(0xFF795548), // Marron
  ];
  
  final List<Map<String, dynamic>> _availableIcons = [
    {"icon": Icons.water_drop, "name": "Eau"},
    {"icon": Icons.flash_on, "name": "Électricité"},
    {"icon": Icons.local_florist, "name": "Jardin"},
    {"icon": Icons.build, "name": "Entretien"},
    {"icon": Icons.cleaning_services, "name": "Nettoyage"},
    {"icon": Icons.security, "name": "Sécurité"},
    {"icon": Icons.pool, "name": "Piscine"},
    {"icon": Icons.sports_tennis, "name": "Sport"},
    {"icon": Icons.restaurant, "name": "Restaurant"},
    {"icon": Icons.park, "name": "Parc"},
    {"icon": Icons.garage, "name": "Garage"},
    {"icon": Icons.elevator, "name": "Ascenseur"},
  ];

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
  
  // ================= NOUVELLES FONCTIONS POUR LES DIALOGUES =================
  
  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Choisir une couleur",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == color ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );
  }
  
  void _showIconPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Choisir un logo",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconData = _availableIcons[index]["icon"];
                final iconName = _availableIcons[index]["name"];
                final isSelected = _selectedIcon == iconData;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? primaryBlue.withOpacity(0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryBlue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          size: 30,
                          color: isSelected ? primaryBlue : Colors.grey.shade700,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          iconName,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? primaryBlue : Colors.grey.shade600,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
          ],
        );
      },
    );
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
                  // ================= TITRE AVEC BOUTONS =================
                  Row(
                    children: [
                      const Text(
                        "Informations de la charge",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      
                      // Bouton couleur
                      GestureDetector(
                        onTap: _showColorPickerDialog,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.color_lens,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Bouton icône
                      GestureDetector(
                        onTap: _showIconPickerDialog,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _selectedIcon,
                            color: primaryBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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
          print("Couleur sélectionnée: $_selectedColor");
          print("Icône sélectionnée: $_selectedIcon");

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