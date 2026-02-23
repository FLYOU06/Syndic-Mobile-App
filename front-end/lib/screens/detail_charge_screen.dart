import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class DetailChargeScreen extends StatefulWidget {
  final String title;
  final String date;
  final double total;
  final double paid;
  final Color color;
  final IconData icon;

  const DetailChargeScreen({
    super.key,
    required this.title,
    required this.date,
    required this.total,
    required this.paid,
    required this.color,
    required this.icon,
  });

  @override
  State<DetailChargeScreen> createState() => _DetailChargeScreenState();
}

class _DetailChargeScreenState extends State<DetailChargeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isPaidExpanded = false;
  bool _isUnpaidExpanded = false;

  // Données simulées
  final List<Map<String, dynamic>> _payes = [
    {"nom": "Adam Lahyan", "montant": 1000, "avatar": "A", "date": "15 Jan 2024"},
    {"nom": "Sofia Benali", "montant": 1000, "avatar": "S", "date": "12 Jan 2024"},
    {"nom": "Youssef Amrani", "montant": 1000, "avatar": "Y", "date": "10 Jan 2024"},
  ];

  final List<Map<String, dynamic>> _impayes = [
    {"nom": "Omar Nassiri", "montant": 1000, "avatar": "O", "date": "En retard"},
    {"nom": "Aya Saidi", "montant": 1000, "avatar": "A", "date": "En retard"},
    {"nom": "Karim El Idrissi", "montant": 1000, "avatar": "K", "date": "En retard"},
    {"nom": "Leila Benjelloun", "montant": 1000, "avatar": "L", "date": "En retard"},
  ];

  double get progress => widget.paid / widget.total;
  String get status {
  final progress = widget.paid / widget.total;

  if (progress == 1) return "Soldée";
  if (progress == 0) return "Impayée";
  return "Partiellement payée";
}

Color get statusColor {
  final progress = widget.paid / widget.total;

  if (progress == 1) return Color.fromARGB(255, 21, 56, 19);
  if (progress == 0) return Color.fromARGB(255, 21, 56, 19);
  return Color.fromARGB(255, 21, 56, 19);
}
String get description {
  switch (widget.title.toLowerCase()) {
    case "eau":
      return "Cette charge couvre la consommation d’eau utilisée dans les parties communes de l’immeuble. Elle inclut le nettoyage des couloirs, escaliers, halls et l’arrosage des espaces communs.";

    case "électricité":
      return "Cette charge couvre l’électricité utilisée dans les parties communes. Elle inclut l’éclairage des escaliers, couloirs, ascenseurs et équipements collectifs.";

    case "jardinier":
      return "Cette charge concerne l’entretien des espaces verts de la résidence. Elle comprend la tonte, la taille des plantes, l’arrosage et le nettoyage du jardin.";

    case "entretien":
      return "Cette charge concerne l’entretien général et la maintenance des parties communes de l’immeuble. Elle inclut les petites réparations, l’entretien des équipements et la préservation du bon état du bâtiment."; 

    default:
      return "Charge mensuelle liée au fonctionnement général et à l'entretien de l'immeuble.";
  }
}

  @override
  void initState() {
    super.initState();
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1600),
);

_progressAnimation = Tween<double>(
  begin: 0,
  end: progress,
).animate(
  CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOutCubicEmphasized,
  ),
);

_animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          _buildHeaderBackground(),
          SafeArea(child: _buildMainContent(context)),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeaderBackground() {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset("assets/j.jpg", fit: BoxFit.cover, width: double.infinity),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.5),
                  widget.color.withOpacity(0.9),
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

  // ================= MAIN =================

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildTopBar(context),
        const SizedBox(height: 20),
        Expanded(child: _buildCardContent()),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
            "Détail de la charge",
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

  // ================= CARD =================

  Widget _buildCardContent() {
    return Container(
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 26),
            _buildAnimatedDonutChart(),
            const SizedBox(height: 5),
            const SizedBox(height: 5),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildMiniInfo(),
            const SizedBox(height: 22),
            _buildExpandableSections(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER INFO =================

  Widget _buildHeaderInfo() {
    return Row(
      children: [
        Icon(widget.icon, color: widget.color, size: 36),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.date, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const Spacer(),
Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    status,
    style: TextStyle(
      color: statusColor,
      fontWeight: FontWeight.bold,
    ),
  ),
),
      ],
    );
  }

  // ================= DONUT ANIMÉ =================

  Widget _buildAnimatedDonutChart() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutCubicEmphasized,
      builder: (context, value, child) {
        return SizedBox(
          height: 240,
          width: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 25,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
        Transform.rotate(
  angle: (1 - value) * 0.6, // rotation fluide premium
  child: SizedBox(
    width: 610,
    height: 610,
    child: CustomPaint(
      painter: AnimatedDonutPainter(
        paidPercent: value,
        paidColor: widget.color,
        unpaidColor: Colors.redAccent,
        animation: _progressAnimation,
      ),
    ),
  ),
),
              _buildAnimatedDonutCenter(value),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDonutCenter(double animatedProgress) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: animatedProgress * 100),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Text(
                "${value.toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
              );
            },
          ),
          const Text("Payé", style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: widget.total),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Text(
                "${value.toInt()} MAD",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _miniDot(widget.color, "${widget.paid.toInt()} MAD"),
              const SizedBox(width: 12),
              _miniDot(Colors.redAccent, "${(widget.total - widget.paid).toInt()} MAD"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniDot(Color color, String value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

 



  // ================= DESCRIPTION =================

Widget _buildDescription() {
  return _sectionCard(
    icon: Icons.info,
    title: "Description",
    content: description,
  );
}

  Widget _buildMiniInfo() {
    return Row(
      children: [
        Expanded(
          child: _infoMiniCard(
            icon: widget.icon,
            title: "Type",
            value: widget.title,
            bg: widget.color.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoMiniCard(
            icon: Icons.calendar_month,
            title: "Période",
            value: widget.date,
            bg: Colors.red.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  // ================= COMPONENTS =================

  Widget _sectionCard({required IconData icon, required String title, required String content}) {
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
              Icon(icon, color: Colors.blue, size: 20),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _infoMiniCard({
    required IconData icon,
    required String title,
    required String value,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  // ================= SECTIONS EXPANDABLES =================

  Widget _buildExpandableSections() {
    return Column(
      children: [
        _buildExpandableSection(
          title: "Habitants ayant payé",
          icon: Icons.check_circle,
          color: Colors.green,
          isExpanded: _isPaidExpanded,
          habitants: _payes,
          totalMontant: _payes.fold(0, (sum, item) => sum + item['montant']),
          onTap: () {
            setState(() {
              _isPaidExpanded = !_isPaidExpanded;
              if (_isPaidExpanded) _isUnpaidExpanded = false;
            });
          },
        ),
        const SizedBox(height: 14),
        _buildExpandableSection(
          title: "Habitants n'ayant pas payé",
          icon: Icons.cancel,
          color: Colors.redAccent,
          isExpanded: _isUnpaidExpanded,
          habitants: _impayes,
          totalMontant: _impayes.fold(0, (sum, item) => sum + item['montant']),
          onTap: () {
            setState(() {
              _isUnpaidExpanded = !_isUnpaidExpanded;
              if (_isUnpaidExpanded) _isPaidExpanded = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required bool isExpanded,
    required List<Map<String, dynamic>> habitants,
    required double totalMontant,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${habitants.length}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildHabitantList(habitants, color, totalMontant),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitantList(List<Map<String, dynamic>> habitants, Color color, double totalMontant) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          ...habitants.map(
            (habitant) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildHabitantItem(habitant, color),
            ),
          ),
          const Divider(height: 20, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  "${totalMontant.toInt()} MAD",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitantItem(Map<String, dynamic> habitant, Color color) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              habitant['avatar'],
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                habitant['nom'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                habitant['date'],
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            "${habitant['montant']} MAD",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// ================= DONUT PAINTER AMÉLIORÉ =================

class AnimatedDonutPainter extends CustomPainter {
  final double paidPercent;
  final Color paidColor;
  final Color unpaidColor;
  final Animation<double> animation;

  AnimatedDonutPainter({
    required this.paidPercent,
    required this.paidColor,
    required this.unpaidColor,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 16;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2;

    // Background circle (gris clair)
    paint.color = Colors.grey.shade200;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * pi,
      false,
      paint,
    );

    // Paid arc avec gradient
    if (paidPercent > 0) {
      paint.shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + 2 * pi * paidPercent,
        colors: [
          paidColor.withOpacity(0.6),
          paidColor,
          paidColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * paidPercent,
        false,
        paint,
      );
    }

    // Unpaid arc avec gradient
    if (paidPercent < 1) {
      paint.shader = SweepGradient(
        startAngle: startAngle + 2 * pi * paidPercent,
        endAngle: 2 * pi,
        colors: [
          unpaidColor.withOpacity(0.4),
          unpaidColor,
          unpaidColor.withOpacity(0.6),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 2 * pi * paidPercent,
        2 * pi * (1 - paidPercent),
        false,
        paint,
      );
    }

    // Ajouter des points de lumière pour l'effet 3D
    final lightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    if (paidPercent > 0) {
      lightPaint.color = paidColor.withOpacity(0.3);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * paidPercent,
        false,
        lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}