import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'habitants_screen.dart';
import 'detail_charge_screen.dart';
import 'add_charge_screen.dart';
import 'assembly_dashboard_screen.dart';
import 'paramètres.dart';

const Color primaryBlue = Color(0xFF004E7A);
const Color bgLight = Color(0xFFF4F6FA);

class ChargesScreen extends StatefulWidget {
  const ChargesScreen({super.key});

  @override
  State<ChargesScreen> createState() => _ChargesScreenState();
}

class _ChargesScreenState extends State<ChargesScreen> {
  // Liste dynamique des charges pour pouvoir les modifier
  List<Map<String, dynamic>> _charges = [
    {
      "title": "Eau",
      "date": "12/03/2026",
      "amount": "10 000 MAD",
      "progress": 0.4,
      "color": const Color.fromARGB(255, 11, 116, 168),
      "icon": Icons.water_drop,
    },
    {
      "title": "Électricité",
      "date": "12/02/2026",
      "amount": "10 000 MAD",
      "progress": 0.6,
      "color": const Color.fromARGB(255, 246, 217, 55),
      "icon": Icons.flash_on,
    },
    {
      "title": "Jardinier",
      "date": "14/03/2026",
      "amount": "10 000 MAD",
      "progress": 1.0,
      "color": const Color(0xFF1B8F6A),
      "icon": Icons.local_florist,
    },
    {
      "title": "Entretien",
      "date": "10/01/2026",
      "amount": "5 000 MAD",
      "progress": 0.0,
      "color": const Color.fromARGB(255, 203, 88, 120),
      "icon": Icons.build,
    },
  ];

  // Fonction pour mettre à jour une charge
  void _updateCharge(int index, Map<String, dynamic> updatedCharge) {
    setState(() {
      _charges[index] = updatedCharge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,

      // ==============================
      // DRAWER
      // ==============================
      drawer: AppDrawer(
        selectedMenu: "Charges",
        onMenuSelected: (menu) {
          if (menu == "Charges") {
            Navigator.of(context).pop();
            return;
          }
          if (menu == "Dashboard") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
          if (menu == "Habitants") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HabitantsScreen()),
            );
          }
          if (menu == "Paramètres") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
          if (menu == "Assemblée Générale") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AssemblyDashboardScreen()),
            );
          }
        },
      ),

      body: Column(
        children: [
          // =====================================================
          // HEADER STYLE DASHBOARD
          // =====================================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
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
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryBlue.withOpacity(0.35),
                            primaryBlue.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Gestion des charges",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 26,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddChargeScreen()),
                              );
                              
                              // Si on reçoit une nouvelle charge, l'ajouter à la liste
                              if (result != null) {
                                setState(() {
                                  _charges.add(result);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // DEUX CARTES FLOTTANTES (comme dashboard)
              // =====================================================
              const Positioned(
                bottom: -50, // moitié en dehors du header
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: DashboardKpiCard(
                        title: "Charges impayées",
                        value: "3,200   MAD",
                        subtitle: "Ce mois",
                        gradientColors: [Color(0xFF004E7A), Color(0xFF006DAA)],
                        valueColor: Colors.white,
                        subtitleColor: Colors.white,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DashboardKpiCard(
                        title: "Le montant total",
                        value: "5,300 MAD",
                        subtitle: "Ce mois",
                        gradientColors: [Color(0xFF004E7A), Color(0xFF006DAA)],
                        valueColor: Colors.white,
                        subtitleColor: Colors.white,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 70), // espace après les cartes

          // =====================================================
          // LISTE DES CHARGES
          // =====================================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _charges.length,
              itemBuilder: (context, index) {
                final charge = _charges[index];
                return ChargeCard(
                  title: charge["title"],
                  date: charge["date"],
                  amount: charge["amount"],
                  progress: charge["progress"],
                  color: charge["color"],
                  icon: charge["icon"],
                  onEdit: (updatedCharge) {
                    _updateCharge(index, updatedCharge);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// KPI CARD (Dashboard style)
// =====================================================
class DashboardKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;
  final Color subtitleColor;
  final IconData icon;
  final List<Color> gradientColors;

  const DashboardKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
    required this.subtitleColor,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CHARGES CARD (VERSION COMPACTE AVEC BOUTON MODIFIER)
// =====================================================
class ChargeCard extends StatefulWidget {
  final String title;
  final String date;
  final String amount;
  final double progress;
  final Color color;
  final IconData icon;
  final Function(Map<String, dynamic>) onEdit;

  const ChargeCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.progress,
    required this.color,
    required this.icon,
    required this.onEdit,
  });

  @override
  State<ChargeCard> createState() => _ChargeCardState();
}

class _ChargeCardState extends State<ChargeCard> {
  late bool _isEditing;
  late TextEditingController _titleController;
  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late double _currentProgress;
  late Color _currentColor;
  late IconData _currentIcon;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _titleController = TextEditingController(text: widget.title);
    _dateController = TextEditingController(text: widget.date);
    _amountController = TextEditingController(text: widget.amount.replaceAll(" MAD", ""));
    _currentProgress = widget.progress;
    _currentColor = widget.color;
    _currentIcon = widget.icon;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String get status {
    if (_currentProgress == 1) return "Soldée";
    if (_currentProgress == 0) return "Impayée";
    return "Partiellement payée";
  }

  void _saveChanges() {
    final updatedCharge = {
      "title": _titleController.text,
      "date": _dateController.text,
      "amount": "${_amountController.text} MAD",
      "progress": _currentProgress,
      "color": _currentColor,
      "icon": _currentIcon,
    };
    widget.onEdit(updatedCharge);
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    setState(() {
      _titleController.text = widget.title;
      _dateController.text = widget.date;
      _amountController.text = widget.amount.replaceAll(" MAD", "");
      _currentProgress = widget.progress;
      _currentColor = widget.color;
      _currentIcon = widget.icon;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ===== Barre colorée à gauche =====
          Container(
            width: 5,
            height: _isEditing ? 200 : 160, // Hauteur ajustée en mode édition
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),

          // ===== Infos de la charge =====
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Titre + Badge =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_currentIcon, color: _currentColor, size: 18),
                          const SizedBox(width: 6),
                          _isEditing
                              ? SizedBox(
                                  width: 120,
                                  child: TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      hintText: "Titre",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _currentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _currentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // ===== Date =====
                  _isEditing
                      ? TextField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: "Date (JJ/MM/AAAA)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          style: const TextStyle(fontSize: 12),
                        )
                      : Text(
                          widget.date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                  const SizedBox(height: 6),

                  // ===== Montant =====
                  _isEditing
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "Montant",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Text(" MAD", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Text(
                          widget.amount,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  const SizedBox(height: 6),

                  // ===== Progression =====
                  _isEditing
                      ? Column(
                          children: [
                            Row(
                              children: [
                                const Text("Progression: ", style: TextStyle(fontSize: 12)),
                                Expanded(
                                  child: Slider(
                                    value: _currentProgress,
                                    onChanged: (value) {
                                      setState(() {
                                        _currentProgress = value;
                                      });
                                    },
                                    min: 0,
                                    max: 1,
                                    divisions: 10,
                                    activeColor: _currentColor,
                                  ),
                                ),
                                Text("${(_currentProgress * 100).toInt()}%"),
                              ],
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _currentProgress,
                            minHeight: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(_currentColor),
                          ),
                        ),

                  const SizedBox(height: 4),

                  // ===== Boutons =====
                  Row(
                    children: [
                      Text(
                        "${(_currentProgress * 100).toInt()}% payé",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _currentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _currentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      
                      // ===== NOUVEAU BOUTON MODIFIER =====
                      if (!_isEditing)
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: _currentColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final totalValue = double.parse(
                                  widget.amount.replaceAll(" MAD", "").replaceAll(" ", "")
                                );
                                final paidValue = totalValue * widget.progress;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailChargeScreen(
                                      title: widget.title,
                                      date: widget.date,
                                      total: totalValue,
                                      paid: paidValue,
                                      color: _currentColor,
                                      icon: _currentIcon,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Voir détails",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Bouton modifier
                            Container(
                              decoration: BoxDecoration(
                                color: _currentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, color: _currentColor, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                      
                      // ===== BOUTONS EN MODE ÉDITION =====
                      if (_isEditing)
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.check, color: Colors.green, size: 18),
                                onPressed: _saveChanges,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                onPressed: _cancelEdit,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// DRAWER (réutilisation du Dashboard Drawer)
// =====================================================
class AppDrawer extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const AppDrawer({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {"icon": Icons.dashboard, "title": "Dashboard"},
      {"icon": Icons.task, "title": "Habitants"},
      {"icon": Icons.calendar_month, "title": "Charges"},
      {"icon": Icons.message, "title": "Assemblée Générale"},
      {"icon": Icons.settings, "title": "Paramètres"},
    ];

    return Drawer(
      backgroundColor: primaryBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 90,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Bienvenue sur",
              style: TextStyle(
                color: Color(0xFFC2E9FF),
                fontSize: 15,
              ),
            ),
            const Text(
              "SyndiControl",
              style: TextStyle(
                color: Color(0xFFC2E9FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        item["icon"],
                        color: isSelected ? Colors.white : const Color(0xFFC2E9FF),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item["title"],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFC2E9FF),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Spacer(),

// Bouton déconnexion
GestureDetector(
  onTap: () {
    // ta logique de déconnexion ici
    Navigator.of(context).pop();
  },
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    child: const Row(
      children: [
        Icon(Icons.logout, color: Color(0xFFC2E9FF)),
        SizedBox(width: 12),
        Text(
          "Déconnexion",
          style: TextStyle(
            color: Color(0xFFC2E9FF),
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}