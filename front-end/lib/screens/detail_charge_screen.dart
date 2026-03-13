import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

// ══════════════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ══════════════════════════════════════════════════════════════════
class _DC {
  static const bg       = Color(0xFFF2F5FB);
  static const surface  = Color(0xFFFFFFFF);
  static const border   = Color(0xFFE8EDF5);
  static const textPrimary   = Color(0xFF0F1C2E);
  static const textSecondary = Color(0xFF6B7A94);
  static const textMuted     = Color(0xFFADB8CC);
  static const green    = Color(0xFF00B87A);
  static const greenBg  = Color(0xFFE8F9F3);
  static const red      = Color(0xFFEF4444);
  static const redBg    = Color(0xFFFEF2F2);
  static const amber    = Color(0xFFF59E0B);
  static const amberBg  = Color(0xFFFFFBEB);
}

// ══════════════════════════════════════════════════════════════════
//  NOTIFICATION STATE MODEL
// ══════════════════════════════════════════════════════════════════
enum AlertStatus { none, sending, sent }

// ══════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ══════════════════════════════════════════════════════════════════
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
    with TickerProviderStateMixin {

  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;

  bool _isPaidExpanded   = false;
  bool _isUnpaidExpanded = false;

  // Alert status per habitant (by name key)
  final Map<String, AlertStatus> _alertStatus = {};

  // ── DATA ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _payes = [
    {"nom": "Adam Lahyan",      "montant": 1000, "initials": "AL", "date": "15 Jan 2024", "apt": "A12"},
    {"nom": "Sofia Benali",     "montant": 1000, "initials": "SB", "date": "12 Jan 2024", "apt": "B04"},
    {"nom": "Youssef Amrani",   "montant": 1000, "initials": "YA", "date": "10 Jan 2024", "apt": "C07"},
  ];

  final List<Map<String, dynamic>> _impayes = [
    {"nom": "Omar Nassiri",      "montant": 1000, "initials": "ON", "date": "En retard", "apt": "A03"},
    {"nom": "Aya Saidi",         "montant": 1000, "initials": "AS", "date": "En retard", "apt": "B11"},
    {"nom": "Karim El Idrissi",  "montant": 1000, "initials": "KE", "date": "En retard", "apt": "C02"},
    {"nom": "Leila Benjelloun",  "montant": 1000, "initials": "LB", "date": "En retard", "apt": "D08"},
  ];

  double get _progress => widget.paid / widget.total;

  String get _status {
    if (_progress >= 1.0) return "Soldée";
    if (_progress == 0.0) return "Impayée";
    return "Partielle";
  }

  Color get _statusColor {
    if (_progress >= 1.0) return _DC.green;
    if (_progress == 0.0) return _DC.red;
    return _DC.amber;
  }

  Color get _statusBg {
    if (_progress >= 1.0) return _DC.greenBg;
    if (_progress == 0.0) return _DC.redBg;
    return _DC.amberBg;
  }

  String get _description {
    switch (widget.title.toLowerCase()) {
      case "eau":
        return "Consommation d'eau dans les parties communes : nettoyage des couloirs, escaliers, halls et arrosage des espaces verts.";
      case "électricité":
        return "Électricité des parties communes : éclairage des escaliers, couloirs, ascenseurs et équipements collectifs.";
      case "jardinier":
        return "Entretien des espaces verts : tonte, taille, arrosage et nettoyage du jardin de la résidence.";
      case "entretien":
        return "Maintenance générale des parties communes : petites réparations, entretien des équipements et préservation du bâtiment.";
      default:
        return "Charge mensuelle liée au fonctionnement général et à l'entretien de l'immeuble.";
    }
  }

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _progressAnim = Tween<double>(begin: 0, end: _progress).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOutCubicEmphasized),
    );

    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    _progressCtrl.forward();
    _headerCtrl.forward();

    // Init alert status for all unpaid habitants
    for (final h in _impayes) {
      _alertStatus[h['nom']] = AlertStatus.none;
    }
    // Paid habitants have a different kind of alert (confirmation)
    for (final h in _payes) {
      _alertStatus[h['nom']] = AlertStatus.none;
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  // ── SEND NOTIFICATION ─────────────────────────────────────────
  Future<void> _sendAlert(String name, bool hasPaid) async {
    if (_alertStatus[name] == AlertStatus.sent) return;

    HapticFeedback.mediumImpact();
    setState(() => _alertStatus[name] = AlertStatus.sending);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _alertStatus[name] = AlertStatus.sent);

    final msg = hasPaid
        ? "Confirmation de paiement envoyée à $name ✓"
        : "Rappel de paiement envoyé à $name";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(hasPaid ? Icons.check_circle_rounded : Icons.notifications_active_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ]),
        backgroundColor: hasPaid ? _DC.green : _DC.amber,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── SHOW ALERT DIALOG ─────────────────────────────────────────
  void _showAlertDialog(String name, bool hasPaid, String apt) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _DC.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: hasPaid ? _DC.greenBg : _DC.amberBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasPaid ? Icons.check_circle_outline_rounded : Icons.notifications_none_rounded,
                  size: 32,
                  color: hasPaid ? _DC.green : _DC.amber,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                hasPaid ? "Envoyer une confirmation" : "Envoyer un rappel",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _DC.textPrimary),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                hasPaid
                    ? "Envoyer une notification de confirmation de paiement à $name (Apt. $apt) ?"
                    : "Envoyer un rappel de paiement de la charge \"${widget.title}\" à $name (Apt. $apt) ?",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _DC.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),

              // Message preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _DC.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _DC.border),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.message_outlined, size: 16, color: _DC.textMuted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    hasPaid
                        ? "Bonjour $name, votre paiement de ${_impayes.isNotEmpty ? _payes.firstWhere((h) => h['nom'] == name, orElse: () => {'montant': 1000})['montant'] : 1000} MAD pour la charge ${widget.title} (${widget.date}) a bien été enregistré. Merci !"
                        : "Bonjour $name, nous vous rappelons que votre charge ${widget.title} (${widget.date}) d'un montant de 1000 MAD est toujours en attente. Merci de régulariser votre situation.",
                    style: const TextStyle(fontSize: 12, color: _DC.textSecondary, height: 1.5),
                  )),
                ]),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _DC.border),
                      foregroundColor: _DC.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Annuler", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _sendAlert(name, hasPaid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasPaid ? _DC.green : _DC.amber,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      hasPaid ? "Confirmer" : "Envoyer",
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DC.bg,
      body: Stack(
        children: [
          _buildHeaderBg(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 8),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER BACKGROUND ─────────────────────────────────────────
  Widget _buildHeaderBg() {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset("assets/j.jpg", fit: BoxFit.cover, width: double.infinity),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF004E7A).withOpacity(0.55), const Color(0xFF004E7A).withOpacity(0.95)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Decorative circles
          Positioned(top: -30, right: -30,
              child: Container(width: 140, height: 140,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
          Positioned(bottom: 20, left: -20,
              child: Container(width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
        ],
      ),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Bouton retour — simple, sans bulle
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Text("Détail de la charge",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          // Espace symétrique pour centrer le titre
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────
  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── FLOATING HERO CARD ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildHeroCard(),
          ),
          const SizedBox(height: 16),

          // ── DESCRIPTION ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDescriptionCard(),
          ),
          const SizedBox(height: 16),

          // ── PROGRESS BAR CARD ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProgressCard(),
          ),
          const SizedBox(height: 16),

          // ── SECTIONS EXPANDABLES ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExpandableSection(
              title: "Payé",
              subtitle: "${_payes.length} habitant${_payes.length > 1 ? 's' : ''}",
              icon: Icons.check_circle_rounded,
              color: _DC.green,
              bg: _DC.greenBg,
              isExpanded: _isPaidExpanded,
              habitants: _payes,
              hasPaid: true,
              onTap: () => setState(() {
                _isPaidExpanded = !_isPaidExpanded;
                if (_isPaidExpanded) _isUnpaidExpanded = false;
              }),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExpandableSection(
              title: "Non payé",
              subtitle: "${_impayes.length} habitant${_impayes.length > 1 ? 's' : ''}",
              icon: Icons.cancel_rounded,
              color: _DC.red,
              bg: _DC.redBg,
              isExpanded: _isUnpaidExpanded,
              habitants: _impayes,
              hasPaid: false,
              onTap: () => setState(() {
                _isUnpaidExpanded = !_isUnpaidExpanded;
                if (_isUnpaidExpanded) _isPaidExpanded = false;
              }),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DC.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: widget.color.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.color.withOpacity(0.2)),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _DC.textPrimary)),
                    const SizedBox(height: 2),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: _DC.textMuted),
                      const SizedBox(width: 4),
                      Text(widget.date, style: const TextStyle(fontSize: 13, color: _DC.textSecondary)),
                    ]),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.25)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7,
                      decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(_status, style: TextStyle(
                      color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
                ]),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: _DC.border, height: 1),
          const SizedBox(height: 20),

          // Donut + center info
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => _buildDonut(_progressAnim.value),
          ),
        ],
      ),
    );
  }

  // ── DONUT CHART ───────────────────────────────────────────────
  Widget _buildDonut(double value) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Donut
          Expanded(
            child: Center(
              child: SizedBox(
                width: 170, height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: _CleanDonutPainter(
                        progress: value,
                        paidColor: widget.color,
                        unpaidColor: _DC.red,
                        bgColor: _DC.border,
                      ),
                      size: const Size(170, 170),
                    ),
                    // Center text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: value * 100),
                          duration: const Duration(milliseconds: 1400),
                          curve: Curves.easeInOutCubicEmphasized,
                          builder: (_, v, __) => Text("${v.round()}%",
                              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
                                  color: widget.color)),
                        ),
                        Text("collecté",
                            style: const TextStyle(fontSize: 12, color: _DC.textMuted, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Legend
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legendItem(widget.color, "Payé", "${widget.paid.toInt()} MAD"),
              const SizedBox(height: 16),
              _legendItem(_DC.red, "Impayé", "${(widget.total - widget.paid).toInt()} MAD"),
              const SizedBox(height: 16),
              _legendItem(_DC.textMuted, "Total", "${widget.total.toInt()} MAD"),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 11, color: _DC.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _DC.textPrimary)),
        ]),
      ],
    );
  }

  // ── DESCRIPTION CARD ──────────────────────────────────────────
  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DC.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline_rounded, size: 18, color: widget.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Description", style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _DC.textPrimary)),
                const SizedBox(height: 4),
                Text(_description, style: const TextStyle(
                    fontSize: 13, color: _DC.textSecondary, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PROGRESS CARD ─────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DC.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DC.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("Progression du recouvrement",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _DC.textPrimary)),
            const Spacer(),
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, __) => Text(
                "${(_progressAnim.value * 100).round()}%",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: widget.color),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _DC.bg, borderRadius: BorderRadius.circular(20),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progressAnim.value,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [widget.color.withOpacity(0.7), widget.color]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Text("${widget.paid.toInt()} MAD collectés",
                style: const TextStyle(fontSize: 12, color: _DC.textSecondary)),
            const Spacer(),
            Text("${widget.total.toInt()} MAD total",
                style: const TextStyle(fontSize: 12, color: _DC.textMuted)),
          ]),
        ],
      ),
    );
  }

  // ── EXPANDABLE SECTION ────────────────────────────────────────
  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool isExpanded,
    required List<Map<String, dynamic>> habitants,
    required bool hasPaid,
    required VoidCallback onTap,
  }) {
    final total = habitants.fold<int>(0, (s, h) => s + (h['montant'] as int));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _DC.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isExpanded ? color.withOpacity(0.3) : _DC.border,
            width: isExpanded ? 1.5 : 1),
        boxShadow: [
          BoxShadow(color: isExpanded ? color.withOpacity(0.08) : Colors.black.withOpacity(0.03),
              blurRadius: isExpanded ? 16 : 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isExpanded ? color.withOpacity(0.12) : bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            color: isExpanded ? color : _DC.textPrimary)),
                        Text(subtitle, style: const TextStyle(fontSize: 12, color: _DC.textMuted)),
                      ]),
                    ),
                    // Total badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withOpacity(0.2)),
                      ),
                      child: Text("$total MAD",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: _DC.textMuted, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: color.withOpacity(0.15), indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    children: [
                      ...habitants.map((h) => _buildHabitantRow(h, hasPaid, color)),
                      const SizedBox(height: 6),
                      // Total row
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Text("Total ${hasPaid ? 'collecté' : 'impayé'}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _DC.textPrimary)),
                          const Spacer(),
                          Text("$total MAD",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HABITANT ROW ──────────────────────────────────────────────
  Widget _buildHabitantRow(Map<String, dynamic> h, bool hasPaid, Color sectionColor) {
    final String name    = h['nom'];
    final String initials = h['initials'];
    final String apt     = h['apt'];
    final int montant    = h['montant'];
    final String date    = h['date'];
    final AlertStatus status = _alertStatus[name] ?? AlertStatus.none;

    final bool isSent    = status == AlertStatus.sent;
    final bool isSending = status == AlertStatus.sending;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _DC.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DC.border),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sectionColor.withOpacity(0.2), sectionColor.withOpacity(0.1)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: sectionColor.withOpacity(0.25)),
            ),
            child: Center(child: Text(initials,
                style: TextStyle(color: sectionColor, fontWeight: FontWeight.w800, fontSize: 14))),
          ),
          const SizedBox(width: 10),

          // Name + apt + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _DC.textPrimary)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.home_outlined, size: 12, color: _DC.textMuted),
                  const SizedBox(width: 3),
                  Text("Apt. $apt", style: const TextStyle(fontSize: 11, color: _DC.textMuted)),
                  const SizedBox(width: 8),
                  Icon(hasPaid ? Icons.calendar_today_outlined : Icons.warning_amber_rounded,
                      size: 11, color: hasPaid ? _DC.textMuted : _DC.amber),
                  const SizedBox(width: 3),
                  Text(date, style: TextStyle(fontSize: 11,
                      color: hasPaid ? _DC.textMuted : _DC.amber,
                      fontWeight: hasPaid ? FontWeight.normal : FontWeight.w600)),
                ]),
              ],
            ),
          ),

          // Amount
          Text("$montant MAD",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sectionColor)),
          const SizedBox(width: 10),

          // ✅ ALERT BUTTON
          GestureDetector(
            onTap: isSent || isSending ? null : () => _showAlertDialog(name, hasPaid, apt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isSent
                    ? _DC.green.withOpacity(0.12)
                    : (hasPaid ? _DC.green.withOpacity(0.08) : _DC.amber.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSent
                      ? _DC.green.withOpacity(0.3)
                      : (hasPaid ? _DC.green.withOpacity(0.2) : _DC.amber.withOpacity(0.3)),
                ),
              ),
              child: Center(
                child: isSending
                    ? SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                                hasPaid ? _DC.green : _DC.amber)))
                    : Icon(
                        isSent
                            ? Icons.check_rounded
                            : (hasPaid
                                ? Icons.mark_email_read_outlined
                                : Icons.notifications_none_rounded),
                        size: 18,
                        color: isSent
                            ? _DC.green
                            : (hasPaid ? _DC.green : _DC.amber),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLEAN DONUT PAINTER
// ══════════════════════════════════════════════════════════════════
class _CleanDonutPainter extends CustomPainter {
  final double progress;
  final Color paidColor;
  final Color unpaidColor;
  final Color bgColor;

  _CleanDonutPainter({
    required this.progress,
    required this.paidColor,
    required this.unpaidColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;
    const strokeW = 18.0;
    const startAngle = -pi / 2;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..color = bgColor;

    // Background track
    canvas.drawCircle(center, radius, basePaint);

    // Paid arc
    if (progress > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + 2 * pi * progress,
          colors: [paidColor.withOpacity(0.7), paidColor],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * progress,
        false,
        paint,
      );
    }

    // Unpaid arc
    if (progress < 1) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..color = unpaidColor.withOpacity(0.25);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + 2 * pi * progress + 0.03,
        2 * pi * (1 - progress) - 0.03,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CleanDonutPainter old) =>
      old.progress != progress;
}