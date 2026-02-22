import 'dart:math';
import 'package:flutter/material.dart';
import 'NotificationsScreen.dart';
import 'habitants_screen.dart';
import 'charges.dart';

const Color primaryBlue = Color(0xFF004E7A);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedMenu = "Dashboard";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
drawer: AppDrawer(
  selectedMenu: selectedMenu,
onMenuSelected: (menu) {
  if (menu == selectedMenu) return;

  setState(() {
    selectedMenu = menu;
  });

  Navigator.of(context).pop(); // fermer le drawer

  if (menu == "Habitants") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HabitantsScreen(),
      ),
    );
  } else if (menu == "Charges") {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChargesScreen(),
      ),
    );
  }
},
),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================================================
            // HEADER + KPI FLOATING
            // =====================================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 230,
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
  top: 60,
  left: 20,
  right: 20,
  child: Builder(
    builder: (context) => Row(
      children: [
        // ☰ HAMBURGER
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 12),

        // TITRE
        const Expanded(
          child: Text(
            "Résidence Al Amal",
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

        // 🔔 NOTIFICATION
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
      ],
    ),
  ),
),

                    ],
                  ),
                ),

                // KPI FLOATING
                const Positioned(
                  bottom: -50,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: DashboardKpiCard(
                          title: "Charges impayées",
                          value: "600 MAD",
                          subtitle: "+12 % ce mois",
                          background: Color(0xFFFFEEEE),
                          valueColor: Colors.black,
                          subtitleColor: Colors.red,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: DashboardKpiCard(
                          title: "Nombre d'habitants",
                          value: "40",
                          subtitle: "Habitants",
                          background: Color(0xFFF1F6FF),
                          valueColor: Colors.black,
                          subtitleColor: Colors.green,
                          icon: Icons.people_outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),
// =====================================================
// PROCHAINE ASSEMBLÉE GÉNÉRALE
// =====================================================
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF004E7A), Color(0xFF006DAA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 🔥 évite hauteur inutile
      children: [

        // TITRE
        const Row(
          children: [
            Icon(Icons.event_available, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Prochaine Assemblée Générale",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // DATE + BOUTON
        Row(
          children: [
            const Icon(Icons.calendar_month,
                color: Colors.white70, size: 18),
            const SizedBox(width: 6),

            const Expanded(
              child: Text(
                "25 Mars 2026 - 18:00",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                minimumSize: Size.zero, // 🔥 réduit taille interne
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                debugPrint("Voir détails Assemblée");
              },
              child: const Text(
                "Voir détails",
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // LIEU
        const Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: Colors.white70, size: 18),
            SizedBox(width: 6),
            Text(
              "Salle polyvalente - Résidence",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

const SizedBox(height: 24),

            // =====================================================
            // GRAPH (STYLE IMAGE)
            // =====================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aperçu des charges impayées",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F4FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Ce mois",
                            style: TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Distribution par appartement",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: ModernUnpaidChartPainter(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // ACTIONS RAPIDES
            // =====================================================
        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min, // 🔥 réduit la hauteur de la colonne
    children: [
      const Text(
        "Actions rapides",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10), // petit espace facultatif
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        padding: EdgeInsets.zero, // 🔥 supprime le padding par défaut
        childAspectRatio: 2.3,
        children: [
  ActionCard(
  icon: Icons.people_outline,
  label: "Gérer les habitants",
  color: Colors.blue,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HabitantsScreen(),
      ),
    );
  },
),

          const ActionCard(
            icon: Icons.insert_drive_file_outlined,
            label: "Générer des rapports",
            color: Colors.green,
          ),
          const ActionCard(
            icon: Icons.event_note_outlined,
            label: "Planifier une assemblée",
            color: Colors.deepPurple,
          ),
          const ActionCard(
            icon: Icons.campaign_outlined,
            label: "Diffusion",
            color: Colors.orange,
          ),
        ],
      ),
    ],
  ),
),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// KPI CARD
// =====================================================
class DashboardKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color background;
  final Color valueColor;
  final Color subtitleColor;
  final IconData icon;

  const DashboardKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.background,
    required this.valueColor,
    required this.subtitleColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
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
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                title.toLowerCase().contains("habitant")
                    ? Icons.people_outline
                    : icon,
                size: 18,
              ),
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
// GRAPH PAINTER (STYLE IMAGE)
// =====================================================
// =====================================================
// GRAPH PAINTER (STYLE IMAGE) AVEC NOMBRE D'IMMEUBLES
// =====================================================
class ModernUnpaidChartPainter extends CustomPainter {
  // Montants des charges impayées par appartement
  final List<double> values = [240, 480, 350, 420, 380];
  // Noms des appartements
  final List<String> labels = ["A12", "A05", "A08", "A15", "B03"];
  // Nombre d'immeubles pour chaque appartement
  final List<int> buildingCounts = [2, 3, 1, 2, 4];

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 40;
    const double bottomPadding = 40; // un peu plus pour le nombre d'immeubles
    const double topPadding = 20;

    final usableHeight = size.height - bottomPadding - topPadding;
    final usableWidth = size.width - leftPadding;

    final maxValue = values.reduce(max);
    const int steps = 5;
    final stepValue = (maxValue / steps).ceilToDouble();

    // -----------------------------
    // AXE Y + GRID
    // -----------------------------
    final axisPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    const textStyle = TextStyle(
      fontSize: 10,
      color: Color(0xFF6B7280),
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= steps; i++) {
      final value = stepValue * i;
      final y = topPadding + usableHeight -
          (value / (stepValue * steps)) * usableHeight;

      // Ligne horizontale
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width, y),
        axisPaint,
      );

      // Texte axe Y
      final tp = TextPainter(
        text: TextSpan(
          text: "${value.toInt()} MAD",
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(leftPadding - tp.width - 6, y - tp.height / 2),
      );
    }

    // Ligne verticale axe Y
    canvas.drawLine(
      const Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + usableHeight),
      axisPaint,
    );

    // -----------------------------
    // BARRES
    // -----------------------------
    const barWidth = 26.0;
    final space =
        (usableWidth - barWidth * values.length) / (values.length + 1);

    for (int i = 0; i < values.length; i++) {
      final barHeight = (values[i] / (stepValue * steps)) * usableHeight;
      final x = leftPadding + space + i * (barWidth + space);
      final y = topPadding + usableHeight - barHeight;

      // Ombre de la barre
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 2, barWidth, barHeight),
          const Radius.circular(10),
        ),
        Paint()..color = Colors.black.withOpacity(0.1),
      );

      // Barre principale
      final barPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF6EC1FF),
            Color(0xFF004E7A),
          ],
        ).createShader(Rect.fromLTWH(0, 0, barWidth, usableHeight));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(10),
        ),
        barPaint,
      );

      // Valeur au-dessus de la barre
      final valuePainter = TextPainter(
        text: TextSpan(
          text: "${values[i].toInt()} MAD",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(x + (barWidth - valuePainter.width) / 2, y - 16),
      );

      // Label X (Appartement)
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          x + (barWidth - labelPainter.width) / 2,
          size.height - bottomPadding + 2,
        ),
      );

      // Nombre d'immeubles sous le label
      final buildingPainter = TextPainter(
        text: TextSpan(
        text: "Imm.${buildingCounts[i]} ",
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      buildingPainter.layout();
      buildingPainter.paint(
        canvas,
        Offset(
          x + (barWidth - buildingPainter.width) / 2,
          size.height - bottomPadding + 16, // un peu plus bas
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// =====================================================
// ACTION CARD
// =====================================================
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap; // <-- nouveau paramètre

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap, // <-- assignation du paramètre
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ?? () { // si pas défini, juste debugPrint
          debugPrint("Action : $label");
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.7), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
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
      {"icon": Icons.message, "title": "Messages"},
      {"icon": Icons.settings, "title": "Settings"},
      {"icon": Icons.person, "title": "Profile"},
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
                onTap: () {
                  onMenuSelected(item["title"]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        item["icon"],
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFC2E9FF),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item["title"],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFC2E9FF),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 