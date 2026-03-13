import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'habitants_screen.dart';
import 'charges.dart';
import 'paramètres.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _T {
  static const navy      = Color(0xFF0B1F3A);
  static const blue      = Color(0xFF1A4DD1);
  static const blueLight = Color(0xFF3B6EF5);
  static const accent    = Color(0xFF0ECFCF);
  static const success   = Color(0xFF10B981);
  static const warning   = Color(0xFFF59E0B);
  static const danger    = Color(0xFFEF4444);
  static const white     = Color(0xFFFFFFFF);
  static const bg        = Color(0xFFF0F4FA);
  static const surface   = Color(0xFFFFFFFF);
  static const border    = Color(0xFFE2E8F4);
  static const textPrimary   = Color(0xFF0B1F3A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted     = Color(0xFFA0ABBA);
  static const phaseAvant    = Color(0xFF1A4DD1);
  static const phaseApres    = Color(0xFF10B981);
}

class AssemblyDashboardScreen extends StatefulWidget {
  const AssemblyDashboardScreen({super.key});
  @override
  State<AssemblyDashboardScreen> createState() => _AssemblyDashboardScreenState();
}

class _AssemblyDashboardScreenState extends State<AssemblyDashboardScreen>
    with TickerProviderStateMixin {

  int? expandedIndex;
  String selectedTypeAG = 'Ordinaire';
  String selectedMenu = "Assemblée Générale"; 
  final Color primaryBlue = const Color(0xFF004E7A);

  final TextEditingController dateController  = TextEditingController();
  final TextEditingController heureController = TextEditingController();
  final TextEditingController lieuController  = TextEditingController();
  final List<Map<String, dynamic>> ordreDuJourPoints = [];
  bool convocationsEnvoyees = false;
  int presents   = 0;
  int absents    = 0;
  int procurations = 0;
  int totalCoproprietaires = 20;
  bool pvGenerated = false;

  bool get step1Done => dateController.text.isNotEmpty && heureController.text.isNotEmpty && lieuController.text.isNotEmpty;
  bool get step2Done => ordreDuJourPoints.isNotEmpty;
  bool get step3Done => convocationsEnvoyees;
  bool get step4Done => presents > 0 || procurations > 0;
  bool get step5Done => pvGenerated;

  bool _isStepDone(int index) {
    switch (index) {
      case 0: return step1Done;
      case 1: return step2Done;
      case 2: return step3Done;
      case 3: return step4Done;
      case 4: return step5Done;
      default: return false;
    }
  }

  final List<Map<String, dynamic>> tasks = [
    {"title": "Fixation date et lieu",       "description": "Définir la date, l'heure et le lieu de l'assemblée.",        "icon": Icons.calendar_month_outlined,     "phase": "avant"},
    {"title": "Préparation ordre du jour",   "description": "Organiser les points à discuter et préparer les résolutions.", "icon": Icons.format_list_bulleted_rounded, "phase": "avant"},
    {"title": "Envoi des convocations",      "description": "Envoyer les convocations officielles aux copropriétaires.",   "icon": Icons.mark_email_read_outlined,    "phase": "avant"},
    {"title": "Enregistrement présences",    "description": "Marquer présents, absents et calculer le quorum.",            "icon": Icons.people_alt_outlined,         "phase": "après"},
    {"title": "Rédaction du PV",             "description": "Rédiger le résumé des discussions et votes.",                 "icon": Icons.description_outlined,        "phase": "après"},
  ];

  // ══════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
drawer: AppDrawer(
  selectedMenu: selectedMenu,
  onMenuSelected: (menu) {
    if (menu == selectedMenu) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      selectedMenu = menu;
    });

    Navigator.of(context).pop();

    if (menu == "Habitants") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HabitantsScreen()),
      );
    } else if (menu == "Charges") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChargesScreen()),
      );
    } else if (menu == "Dashboard") {
      Navigator.pop(context); // Retour au dashboard
    }
    else if (menu == "Paramètres") {
           Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ); // Retour au dashboard
    }
    // "Assemblée Générale" reste sur l'écran actuel
  },
),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(),
                Positioned(bottom: -60, left: 20, right: 20, child: _buildProchaineAssembleeCard()),
              ],
            ),
            const SizedBox(height: 80),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: tasks.length,
              itemBuilder: (context, index) =>
                  _buildTimelineItem(tasks[index], index, expandedIndex == index),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  HEADER (original conservé)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset("assets/j.jpg", fit: BoxFit.cover, width: double.infinity),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue.withOpacity(0.4), primaryBlue.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 60, left: 20, right: 20,
            child: Builder(
              builder: (ctx) => Row(
                children: [
                  GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: const Icon(Icons.menu, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text("Assemblée Générale", textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  PROCHAINE ASSEMBLÉE CARD (original conservé)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildProchaineAssembleeCard() {
    final dateText  = dateController.text.isNotEmpty  ? dateController.text  : "25 Mars 2026";
    final heureText = heureController.text.isNotEmpty ? heureController.text : "18:00";
    final lieuText  = lieuController.text.isNotEmpty  ? lieuController.text  : "Salle polyvalente - Résidence";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF004E7A), Color(0xFF006DAA)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(children: [
              Icon(Icons.event_available, color: Colors.white),
              SizedBox(width: 8),
              Text("Prochaine Assemblée Générale",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text("$dateText - $heureText",
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF004E7A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: genererPdfConvocation,
                child: const Text("Voir Convoc", style: TextStyle(fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(lieuText, style: const TextStyle(color: Colors.white, fontSize: 13))),
            ]),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  TIMELINE ITEM (design doc1)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTimelineItem(Map<String, dynamic> task, int index, bool isExpanded) {
    final bool isAvant   = index < 3;
    final Color phaseColor = isAvant ? _T.phaseAvant : _T.phaseApres;
    final bool isDone    = _isStepDone(index);
    final bool isLast    = index == tasks.length - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rail
        SizedBox(
          width: 32,
          child: Column(
            children: [
              if (index > 0)
                Container(width: 2, height: 10, color: isDone ? phaseColor.withOpacity(0.4) : _T.border),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: isDone ? phaseColor : _T.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? phaseColor : _T.border, width: 2),
                  boxShadow: isDone ? [BoxShadow(color: phaseColor.withOpacity(0.3), blurRadius: 8)] : [],
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text("${index + 1}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                            color: isDone ? Colors.white : _T.textMuted)),
                ),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 2,
                  height: isExpanded ? 350 : 70,
                  color: isDone ? phaseColor.withOpacity(0.25) : _T.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Card
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isExpanded ? phaseColor.withOpacity(0.25) : _T.border,
                width: isExpanded ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                if (isExpanded)
                  BoxShadow(color: phaseColor.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: isDone ? phaseColor.withOpacity(0.1) : _T.bg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(task["icon"] as IconData,
                                color: isDone ? phaseColor : _T.textMuted, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: phaseColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(isAvant ? "AVANT AG" : "APRÈS AG",
                                        style: TextStyle(color: phaseColor, fontSize: 9,
                                            fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                                  ),
                                  if (isDone) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _T.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text("Complété",
                                          style: TextStyle(color: _T.success, fontSize: 9, fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ]),
                                const SizedBox(height: 4),
                                Text(task["title"] as String,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _T.textPrimary)),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isExpanded ? phaseColor.withOpacity(0.1) : _T.bg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: isExpanded ? phaseColor : _T.textMuted, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: Text(task["description"] as String,
                          style: const TextStyle(fontSize: 12, color: _T.textSecondary, height: 1.5)),
                    ),
                  if (isExpanded) ...[
                    Container(height: 1, color: _T.border),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTaskContent(task["title"] as String),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskContent(String title) {
    switch (title) {
      case "Fixation date et lieu":       return _buildFixationContent();
      case "Préparation ordre du jour":   return _buildOrdreJourContent();
      case "Envoi des convocations":      return _buildConvocationsContent();
      case "Enregistrement présences":    return _buildPresencesContent();
      case "Rédaction du PV":             return _buildRedactionPVContent();
      default: return const SizedBox();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  1️⃣ FIXATION DATE & LIEU
  // ══════════════════════════════════════════════════════════════════
  Widget _buildFixationContent() {
    String? selectedDuree;
    String? selectedLieu;
    final lieuOptions = ['Salle de réunion résidence', 'Bureau du syndic', 'En ligne (visioconférence)', 'Autre'];
    final autreLieuCtrl = TextEditingController();
    bool showAutre = false;
    String localType = selectedTypeAG;

    return StatefulBuilder(builder: (context, setS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel("Type d'assemblée"),
          const SizedBox(height: 8),
          Row(
            children: ['Ordinaire', 'Extraordinaire'].map((type) {
              final bool sel = localType == type;
              final Color col = type == 'Ordinaire' ? _T.blue : _T.warning;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setS(() { localType = type; selectedTypeAG = type; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: type == 'Ordinaire' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? col.withOpacity(0.08) : _T.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: sel ? col : _T.border, width: sel ? 1.5 : 1),
                    ),
                    child: Column(children: [
                      Icon(type == 'Ordinaire' ? Icons.event_note_rounded : Icons.warning_amber_rounded,
                          size: 20, color: sel ? col : _T.textMuted),
                      const SizedBox(height: 4),
                      Text(type, style: TextStyle(fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? col : _T.textSecondary)),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _sectionLabel("Date & Heure"),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _modernDateField(controller: dateController, label: "Date", icon: Icons.calendar_today_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _modernTimeField(controller: heureController, label: "Heure", icon: Icons.access_time_rounded)),
          ]),
          const SizedBox(height: 14),
          _sectionLabel("Durée estimée"),
          const SizedBox(height: 8),
          _modernDropdown(
            value: selectedDuree, hint: "Sélectionner la durée",
            items: ['1h', '1h30', '2h', '2h30', '3h'],
            icon: Icons.timer_outlined,
            onChanged: (v) => setS(() => selectedDuree = v),
          ),
          const SizedBox(height: 14),
          _sectionLabel("Lieu"),
          const SizedBox(height: 8),
          _modernDropdown(
            value: selectedLieu, hint: "Sélectionner le lieu",
            items: lieuOptions,
            icon: Icons.location_on_outlined,
            onChanged: (v) {
              setS(() {
                selectedLieu = v;
                showAutre = v == 'Autre';
                if (!showAutre && v != null) lieuController.text = v;
              });
            },
          ),
          if (showAutre) ...[
            const SizedBox(height: 10),
            _modernTextField(controller: autreLieuCtrl, label: "Précisez le lieu",
                icon: Icons.edit_location_alt_outlined,
                onChanged: (v) { if (v.isNotEmpty) lieuController.text = v; }),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
            child: const Row(children: [
              Icon(Icons.apartment_rounded, size: 16, color: _T.textSecondary),
              SizedBox(width: 8),
              Text("Résidence Al Amal", style: TextStyle(fontSize: 13, color: _T.textSecondary)),
            ]),
          ),
          const SizedBox(height: 20),
          _primaryButton(
            label: "Confirmer la configuration",
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              setState(() {});
              _showToast(context, "Configuration enregistrée", _T.success, Icons.check_circle_rounded);
            },
          ),
        ],
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════
  //  2️⃣ ORDRE DU JOUR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildOrdreJourContent() {
    final descCtrl = TextEditingController();
    String? selectedPoint;
    String typeAG = selectedTypeAG;

    final pointsOrdinaires = [
      {'titre': 'Rapport du syndic',         'description': 'Présentation du rapport de gestion, travaux réalisés, impayés et contrats en cours.', 'icone': Icons.description_outlined,         'couleur': _T.blue},
      {'titre': 'Approbation des comptes',    'description': 'Examen des dépenses et recettes de l\'exercice écoulé. Vote d\'approbation des comptes.', 'icone': Icons.account_balance_outlined,  'couleur': _T.success},
      {'titre': 'Budget prévisionnel',        'description': 'Détermination du budget pour l\'année à venir. Fixation des charges à payer.',          'icone': Icons.show_chart_rounded,           'couleur': const Color(0xFF8B5CF6)},
      {'titre': 'Entretien courant',          'description': 'Décision concernant les travaux d\'entretien réguliers des parties communes.',           'icone': Icons.build_outlined,               'couleur': _T.warning},
      {'titre': 'Renouvellement contrats',    'description': 'Vote pour renouveler ou changer les prestataires : syndic, nettoyage, assurance.',       'icone': Icons.assignment_turned_in_outlined, 'couleur': const Color(0xFF14B8A6)},
    ];

    final pointsExtraordinaires = [
      {'titre': 'Travaux majeurs',             'description': 'Vote concernant des travaux importants : ravalement, ascenseur, rénovation.',           'icone': Icons.construction_outlined,        'couleur': _T.danger},
      {'titre': 'Appel de fonds exceptionnel', 'description': 'Contribution financière supplémentaire pour travaux urgents ou imprévus.',              'icone': Icons.credit_card_outlined,         'couleur': const Color(0xFFF97316)},
      {'titre': 'Modification règlement',      'description': 'Changement des règles internes de la copropriété.',                                     'icone': Icons.gavel_outlined,               'couleur': const Color(0xFF92400E)},
      {'titre': 'Situation d\'urgence',        'description': 'Décisions après un événement grave : incendie, dégât des eaux, fissure importante.',    'icone': Icons.warning_outlined,             'couleur': _T.warning},
      {'titre': 'Sensibilisation',             'description': 'Informer les copropriétaires sur un sujet important : règlement, énergie, sécurité.',   'icone': Icons.school_outlined,              'couleur': const Color(0xFF4F46E5)},
    ];

    final pointsAG = typeAG == 'Ordinaire' ? pointsOrdinaires : pointsExtraordinaires;

    return StatefulBuilder(builder: (context, setS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: typeAG == 'Ordinaire' ? _T.blue.withOpacity(0.08) : _T.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: typeAG == 'Ordinaire' ? _T.blue.withOpacity(0.2) : _T.warning.withOpacity(0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(typeAG == 'Ordinaire' ? Icons.event_available_rounded : Icons.warning_amber_rounded,
                    size: 14, color: typeAG == 'Ordinaire' ? _T.blue : _T.warning),
                const SizedBox(width: 6),
                Text("AG $typeAG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: typeAG == 'Ordinaire' ? _T.blue : _T.warning)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          if (ordreDuJourPoints.isNotEmpty) ...[
            _sectionLabel("Ordre du jour (${ordreDuJourPoints.length} points)"),
            const SizedBox(height: 8),
            ...ordreDuJourPoints.asMap().entries.map((e) => _buildOrdreJourItem(
              index: e.key, point: e.value,
              onDelete: () => setS(() => ordreDuJourPoints.removeAt(e.key)),
              onMoveUp: e.key > 0 ? () => setS(() {
                var t = ordreDuJourPoints[e.key]; ordreDuJourPoints[e.key] = ordreDuJourPoints[e.key-1]; ordreDuJourPoints[e.key-1] = t;
              }) : null,
              onMoveDown: e.key < ordreDuJourPoints.length - 1 ? () => setS(() {
                var t = ordreDuJourPoints[e.key]; ordreDuJourPoints[e.key] = ordreDuJourPoints[e.key+1]; ordreDuJourPoints[e.key+1] = t;
              }) : null,
            )).toList(),
            const SizedBox(height: 16),
          ],
          _sectionLabel("Ajouter un point"),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selectedPoint != null ? _T.blue.withOpacity(0.3) : _T.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPoint, isExpanded: true,
                hint: Row(children: [
                  const Icon(Icons.add_circle_outline_rounded, size: 16, color: _T.textMuted),
                  const SizedBox(width: 8),
                  const Text("Choisir un point à l'ordre du jour", style: TextStyle(fontSize: 13, color: _T.textMuted)),
                ]),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _T.textSecondary),
                dropdownColor: _T.surface,
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                items: pointsAG.map((p) {
                  final Color c = p['couleur'] as Color;
                  return DropdownMenuItem<String>(
                    value: p['titre'] as String,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                          child: Icon(p['icone'] as IconData, size: 15, color: c),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(p['titre'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _T.textPrimary),
                            overflow: TextOverflow.ellipsis)),
                        if (selectedPoint == p['titre'])
                          const Icon(Icons.check_circle_rounded, size: 16, color: _T.blue),
                      ]),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setS(() {
                    selectedPoint = v;
                    final found = pointsAG.firstWhere((p) => p['titre'] == v);
                    descCtrl.text = found['description'] as String;
                  });
                },
              ),
            ),
          ),
          if (selectedPoint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _T.blue.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.blue.withOpacity(0.12)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: _T.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(descCtrl.text,
                    style: const TextStyle(fontSize: 12, color: _T.blue, height: 1.5))),
              ]),
            ),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _outlineButton(
              label: "Ajouter", icon: Icons.add_rounded,
              enabled: selectedPoint != null,
              onPressed: selectedPoint != null ? () {
                final found = pointsAG.firstWhere((p) => p['titre'] == selectedPoint);
                setS(() {
                  ordreDuJourPoints.add({'texte': selectedPoint, 'description': found['description'], 'icone': found['icone'], 'couleur': found['couleur']});
                  selectedPoint = null; descCtrl.clear();
                });
                _showToast(context, "Point ajouté", _T.success, Icons.check_rounded);
              } : null,
            )),
            if (ordreDuJourPoints.isNotEmpty) ...[
              const SizedBox(width: 10),
              Expanded(child: _primaryButton(
                label: "Valider", icon: Icons.check_circle_outline_rounded,
                onPressed: () => _showToast(context, "Ordre du jour validé ✓", _T.success, Icons.check_circle_rounded),
              )),
            ],
          ]),
        ],
      );
    });
  }

  Widget _buildOrdreJourItem({
    required int index, required Map<String, dynamic> point,
    required VoidCallback onDelete, required VoidCallback? onMoveUp, required VoidCallback? onMoveDown,
  }) {
    final Color c = point['couleur'] as Color? ?? _T.blue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _T.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: c,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text("${index+1}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(point['texte'] ?? "", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _T.textPrimary)),
                const SizedBox(height: 2),
                Text(point['description'] ?? "", style: const TextStyle(fontSize: 11, color: _T.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (onMoveUp != null) _miniAction(Icons.keyboard_arrow_up_rounded, onMoveUp),
            if (onMoveDown != null) _miniAction(Icons.keyboard_arrow_down_rounded, onMoveDown),
          ]),
          _miniAction(Icons.delete_outline_rounded, onDelete, isDelete: true),
          const SizedBox(width: 8),
        ]),
      ),
    );
  }

  Widget _miniAction(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDelete ? _T.danger.withOpacity(0.06) : _T.bg,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 15, color: isDelete ? _T.danger : _T.textSecondary),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  3️⃣ CONVOCATIONS
  // ══════════════════════════════════════════════════════════════════
  Widget _buildConvocationsContent() {
    final bool toutPret = dateController.text.isNotEmpty && heureController.text.isNotEmpty &&
        lieuController.text.isNotEmpty && ordreDuJourPoints.isNotEmpty;

    return Column(children: [
      if (!toutPret) _infoBox("Complétez d'abord la date, le lieu et l'ordre du jour.", _T.warning, Icons.warning_amber_rounded)
      else _buildConvocationPreview(),
      const SizedBox(height: 14),
      _primaryButton(
        label: convocationsEnvoyees ? "Convocation partagée ✓" : "Partager la convocation",
        icon: convocationsEnvoyees ? Icons.check_circle_rounded : Icons.share_rounded,
        enabled: toutPret,
        onPressed: toutPret ? () { partagerConvocation(); setState(() => convocationsEnvoyees = true); } : null,
      ),
      const SizedBox(height: 10),
      _outlineButton(
        label: "Télécharger PDF", icon: Icons.picture_as_pdf_outlined,
        enabled: toutPret,
        onPressed: toutPret ? genererPdfConvocation : null,
      ),
    ]);
  }

  Widget _buildConvocationPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.blue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.blue.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.preview_rounded, size: 16, color: _T.blue),
          const SizedBox(width: 6),
          const Text("Aperçu convocation", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _T.blue)),
        ]),
        const SizedBox(height: 12),
        _previewRow(Icons.calendar_today_rounded, "${dateController.text} à ${heureController.text}"),
        const SizedBox(height: 6),
        _previewRow(Icons.location_on_rounded, lieuController.text),
        const SizedBox(height: 12),
        const Text("Ordre du jour :", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _T.textPrimary)),
        const SizedBox(height: 8),
        ...ordreDuJourPoints.asMap().entries.map((e) {
          final Color c = e.value['couleur'] as Color? ?? _T.blue;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _T.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.border)),
            child: Row(children: [
              Container(width: 24, height: 24,
                  decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(child: Text("${e.key+1}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c)))),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value['texte'] ?? "",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _T.textPrimary))),
            ]),
          );
        }).toList(),
      ]),
    );
  }

  Widget _previewRow(IconData icon, String text) => Row(children: [
    Icon(icon, size: 13, color: _T.textSecondary),
    const SizedBox(width: 6),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: _T.textSecondary))),
  ]);

  // ══════════════════════════════════════════════════════════════════
  //  4️⃣ PRÉSENCES
  // ══════════════════════════════════════════════════════════════════
  Widget _buildPresencesContent() {
    final int totalVotants = presents + procurations;
    final double quorumRatio = totalVotants / totalCoproprietaires;

    return Column(children: [
      Row(children: [
        Expanded(child: _presenceCounter(icon: Icons.people_alt_outlined, label: "Présents", value: presents, color: _T.blue,
            onInc: () => setState(() => presents++), onDec: () { if (presents > 0) setState(() => presents--); })),
        const SizedBox(width: 10),
        Expanded(child: _presenceCounter(icon: Icons.assignment_ind_outlined, label: "Procurations", value: procurations, color: const Color(0xFF8B5CF6),
            onInc: () => setState(() => procurations++), onDec: () { if (procurations > 0) setState(() => procurations--); })),
        const SizedBox(width: 10),
        Expanded(child: _presenceCounter(icon: Icons.person_off_outlined, label: "Absents", value: absents, color: _T.textSecondary,
            onInc: () => setState(() => absents++), onDec: () { if (absents > 0) setState(() => absents--); })),
      ]),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: quorumRatio >= 0.5 ? _T.success.withOpacity(0.06) : _T.danger.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: quorumRatio >= 0.5 ? _T.success.withOpacity(0.2) : _T.danger.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.how_to_vote_rounded, size: 18, color: quorumRatio >= 0.5 ? _T.success : _T.danger),
            const SizedBox(width: 8),
            Text("Quorum de participation", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: quorumRatio >= 0.5 ? _T.success : _T.danger)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: quorumRatio >= 0.5 ? _T.success.withOpacity(0.12) : _T.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text("${(quorumRatio * 100).clamp(0, 100).round()}%",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                      color: quorumRatio >= 0.5 ? _T.success : _T.danger)),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: quorumRatio.clamp(0, 1), minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: quorumRatio >= 0.5 ? _T.success : _T.danger,
            ),
          ),
          const SizedBox(height: 8),
          Text("$totalVotants votants sur $totalCoproprietaires copropriétaires",
              style: const TextStyle(fontSize: 12, color: _T.textSecondary)),
          const SizedBox(height: 4),
          Text(quorumRatio >= 0.5 ? "✓ Quorum atteint — l'assemblée peut délibérer" : "✗ Quorum insuffisant — majorité non atteinte",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: quorumRatio >= 0.5 ? _T.success : _T.danger)),
        ]),
      ),
      const SizedBox(height: 16),
      _primaryButton(label: "Enregistrer les présences", icon: Icons.save_alt_rounded,
          onPressed: () => _showToast(context, "Présences enregistrées", _T.success, Icons.check_circle_rounded)),
    ]);
  }

  Widget _presenceCounter({required IconData icon, required String label, required int value, required Color color,
      required VoidCallback onInc, required VoidCallback onDec}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: _T.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: _T.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text("$value", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _counterBtn(Icons.remove_rounded, onDec),
          const SizedBox(width: 8),
          _counterBtn(Icons.add_rounded, onInc, filled: true, color: color),
        ]),
      ]),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap, {bool filled = false, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: filled ? (color ?? _T.blue) : _T.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: filled ? Colors.white : _T.textSecondary),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  5️⃣ RÉDACTION DU PV
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRedactionPVContent() {
    final bool e1 = dateController.text.isNotEmpty && heureController.text.isNotEmpty && lieuController.text.isNotEmpty;
    final bool e2 = ordreDuJourPoints.isNotEmpty;
    final bool e4 = presents > 0 || procurations > 0;
    final bool allDone = e1 && e2 && e4;

    final int totalVotants = presents + procurations;
    final int abs = (totalCoproprietaires - totalVotants).clamp(0, totalCoproprietaires);
    final double taux = totalCoproprietaires > 0 ? (totalVotants / totalCoproprietaires * 100).clamp(0, 100) : 0;

    const Color bleuProfond = Color(0xFF1A3B5D);
    const Color bleuMoyen   = Color(0xFF004E7A);
    const Color bleuClair   = Color(0xFFEFF6FF);
    const Color bleuBord    = Color(0xFFBDD4F0);
    const Color grisFond    = Color(0xFFF8F9FB);
    const Color grisBord    = Color(0xFFE5E7EB);
    const Color grisMoyen   = Color(0xFF6B7280);
    const Color grisTexte   = Color(0xFF1F2937);
    const Color blanc       = Color(0xFFFFFFFF);
    const Color vert        = Color(0xFF059669);

    final presidentCtrl = TextEditingController();
    final syndicCtrl    = TextEditingController();
    final obsCtrl       = TextEditingController();
    final Map<int, TextEditingController> pointCtrl = {
      for (int i = 0; i < ordreDuJourPoints.length; i++) i: TextEditingController()
    };

    return StatefulBuilder(builder: (context, setS) {
      bool pvEnv = false; bool downloading = false; bool sending = false;

      if (!allDone) {
        return _infoBox(
          "Étapes manquantes : ${[if(!e1) 'date/lieu', if(!e2) 'ordre du jour', if(!e4) 'présences'].join(' · ')}",
          _T.danger, Icons.warning_amber_rounded,
        );
      }

      return StatefulBuilder(builder: (ctx2, setS2) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header PV
            Row(children: [
              Container(width: 4, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [bleuProfond, bleuMoyen],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(2),
                )),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("PROCÈS-VERBAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                    color: grisTexte, letterSpacing: 1)),
                Text("Assemblée Générale ${selectedTypeAG.toUpperCase()}",
                    style: const TextStyle(fontSize: 12, color: grisMoyen)),
              ]),
            ]),
            const SizedBox(height: 20),

            // Meta
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(16), border: Border.all(color: grisBord)),
              child: Column(children: [
                _pvMeta(Icons.calendar_today_rounded, "Date", "${dateController.text}  ·  ${heureController.text}", bleuMoyen),
                const Divider(height: 1, color: grisBord),
                _pvMeta(Icons.location_on_outlined, "Lieu", lieuController.text, bleuMoyen),
                const Divider(height: 1, color: grisBord),
                _pvMeta(Icons.people_alt_outlined, "Votants", "$totalVotants / $totalCoproprietaires  (${taux.toStringAsFixed(0)}%)", bleuMoyen),
                const Divider(height: 1, color: grisBord),
                _pvMeta(Icons.person_off_outlined, "Absents", "$abs copropriétaires", bleuMoyen),
              ]),
            ),
            const SizedBox(height: 20),

            // Bureau
            _pvSectionTitre2("BUREAU DE SÉANCE", Icons.manage_accounts_outlined, bleuProfond, grisBord),
            const SizedBox(height: 12),
            _pvChampEditable(ctrl: presidentCtrl, label: "Président de séance", icon: Icons.person_outline,
                badge: "Président", bleuMoyen: bleuMoyen, bleuClair: bleuClair, bleuBord: bleuBord,
                grisTexte: grisTexte, grisMoyen: grisMoyen, hint: "La personne qui dirige l'AG"),
            const SizedBox(height: 8),
            _pvChampEditable(ctrl: syndicCtrl, label: "Nom du Syndic", icon: Icons.business_center_outlined,
                badge: "SYNDIC", bleuMoyen: bleuMoyen, bleuClair: bleuClair, bleuBord: bleuBord,
                grisTexte: grisTexte, grisMoyen: grisMoyen, hint: "Nom du syndic responsable"),
            const SizedBox(height: 20),

            // ODJ points
            _pvSectionTitre2("DÉROULEMENT DE LA SÉANCE", Icons.format_list_numbered, bleuProfond, grisBord),
            const SizedBox(height: 10),
            ...List.generate(ordreDuJourPoints.length, (i) {
              final pt = ordreDuJourPoints[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: blanc, borderRadius: BorderRadius.circular(14), border: Border.all(color: grisBord)),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: bleuClair, borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(13), topRight: Radius.circular(13))),
                    child: Row(children: [
                      Container(width: 26, height: 26,
                          decoration: BoxDecoration(color: bleuProfond, borderRadius: BorderRadius.circular(7)),
                          child: Center(child: Text("${i+1}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(pt['texte'] ?? "",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: grisTexte))),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: pointCtrl[i], maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: grisTexte),
                      decoration: InputDecoration(
                        hintText: "Discussions, décisions, résultat du vote…",
                        hintStyle: TextStyle(fontSize: 12, color: grisMoyen.withOpacity(0.5)),
                        filled: true, fillColor: grisFond,
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: grisBord)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: grisBord)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: bleuMoyen, width: 1.5)),
                      ),
                    ),
                  ),
                ]),
              );
            }),

            // Observations
            _pvSectionTitre2("OBSERVATIONS GÉNÉRALES", Icons.notes_outlined, bleuProfond, grisBord),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: grisFond, borderRadius: BorderRadius.circular(12), border: Border.all(color: grisBord)),
              child: TextField(
                controller: obsCtrl, maxLines: 3,
                style: const TextStyle(fontSize: 14, color: grisTexte),
                decoration: InputDecoration(
                  hintText: "Incidents de séance, remarques, observations.",
                  hintStyle: TextStyle(fontSize: 13, color: grisMoyen.withOpacity(0.55)),
                  border: InputBorder.none, contentPadding: const EdgeInsets.all(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton PDF
            SizedBox(
              width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: downloading ? bleuMoyen.withOpacity(0.7) : bleuMoyen,
                  foregroundColor: blanc, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: downloading ? null : () async {
                  setS2(() => downloading = true);
                  await _genererEtTelechargerPV(ctx2, presidentCtrl.text, syndicCtrl.text, obsCtrl.text, pointCtrl);
                  setS2(() { downloading = false; pvGenerated = true; setState(() {}); });
                },
                child: downloading
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        SizedBox(width: 12),
                        Text("Génération PDF…", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ])
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.picture_as_pdf_outlined, size: 19),
                        SizedBox(width: 10),
                        Text("TÉLÉCHARGER LE PV (PDF)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                      ]),
              ),
            ),
            const SizedBox(height: 10),

            // Bouton Envoyer
            SizedBox(
              width: double.infinity, height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: pvEnv ? vert : bleuProfond,
                  side: BorderSide(color: pvEnv ? vert : bleuBord, width: 1.5),
                  backgroundColor: pvEnv ? vert.withOpacity(0.05) : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (pvEnv || sending) ? null : () async {
                  setS2(() => sending = true);
                  await _genererEtTelechargerPV(ctx2, presidentCtrl.text, syndicCtrl.text, obsCtrl.text, pointCtrl);
                  setS2(() { sending = false; pvEnv = true; pvGenerated = true; setState(() {}); });
                },
                child: sending
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text("Envoi en cours…", style: TextStyle(fontSize: 13)),
                      ])
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(pvEnv ? Icons.check : Icons.send_outlined, size: 17),
                        const SizedBox(width: 8),
                        Text(pvEnv ? "PV ENVOYÉ ✓" : "ENVOYER LE PV",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
              ),
            ),

            if (pvEnv) ...[
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.check_circle_outline_rounded, color: vert, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Envoyé le ${DateTime.now().day.toString().padLeft(2,'0')}/${DateTime.now().month.toString().padLeft(2,'0')}/${DateTime.now().year}",
                  style: const TextStyle(fontSize: 12, color: vert, fontWeight: FontWeight.w600),
                ),
              ]),
            ],
            const SizedBox(height: 10),
          ],
        );
      });
    });
  }

  Widget _pvMeta(IconData icon, String label, String value, Color bleuMoyen) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        Icon(icon, size: 14, color: bleuMoyen),
        const SizedBox(width: 10),
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _pvSectionTitre2(String titre, IconData icon, Color bleuProfond, Color grisBord) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: bleuProfond.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 14, color: bleuProfond),
      ),
      const SizedBox(width: 8),
      Text(titre, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: bleuProfond, letterSpacing: 0.8)),
      const SizedBox(width: 10),
      Expanded(child: Divider(thickness: 1, color: grisBord)),
    ]);
  }

  Widget _pvChampEditable({
    required TextEditingController ctrl, required String label, required IconData icon, required String badge,
    required Color bleuMoyen, required Color bleuClair, required Color bleuBord,
    required Color grisTexte, required Color grisMoyen, required String hint,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bleuClair, borderRadius: BorderRadius.circular(12), border: Border.all(color: bleuBord),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: bleuMoyen),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: bleuMoyen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            style: TextStyle(fontSize: 14, color: grisTexte, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(fontSize: 13, color: grisMoyen.withOpacity(0.5), fontWeight: FontWeight.normal),
            ),
          ),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: bleuMoyen.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: bleuMoyen, letterSpacing: 0.8)),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  //  SHARED FORM WIDGETS
  // ══════════════════════════════════════════════════════════════════
  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _T.textSecondary, letterSpacing: 0.5));

  Widget _modernTextField({required TextEditingController controller, required String label,
      required IconData icon, bool multiline = false, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
      child: TextField(
        controller: controller, onChanged: onChanged,
        maxLines: multiline ? 3 : 1,
        style: const TextStyle(fontSize: 13, color: _T.textPrimary),
        decoration: InputDecoration(
          hintText: label, hintStyle: const TextStyle(fontSize: 13, color: _T.textMuted),
          prefixIcon: multiline ? null : Icon(icon, size: 16, color: _T.textMuted),
          contentPadding: EdgeInsets.symmetric(horizontal: multiline ? 14 : 0, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _modernDateField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
      child: TextField(
        controller: controller, readOnly: true,
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
          if (d != null) controller.text = "${d.day}/${d.month}/${d.year}";
        },
        style: const TextStyle(fontSize: 13, color: _T.textPrimary),
        decoration: InputDecoration(
          hintText: label, hintStyle: const TextStyle(fontSize: 13, color: _T.textMuted),
          prefixIcon: Icon(icon, size: 15, color: _T.textMuted),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _modernTimeField({required TextEditingController controller, required String label, required IconData icon}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(color: _T.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
      child: TextField(
        controller: controller, readOnly: true,
        onTap: () async {
          final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (t != null) controller.text = t.format(context);
        },
        style: const TextStyle(fontSize: 13, color: _T.textPrimary),
        decoration: InputDecoration(
          hintText: label, hintStyle: const TextStyle(fontSize: 13, color: _T.textMuted),
          prefixIcon: Icon(icon, size: 15, color: _T.textMuted),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _modernDropdown({required String? value, required String hint, required List<String> items,
      required IconData icon, required Function(String?) onChanged}) {
    return Container(
      height: 46, padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _T.bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value != null ? _T.blue.withOpacity(0.4) : _T.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          hint: Row(children: [
            Icon(icon, size: 15, color: _T.textMuted), const SizedBox(width: 8),
            Text(hint, style: const TextStyle(fontSize: 13, color: _T.textMuted)),
          ]),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _T.textSecondary, size: 18),
          dropdownColor: _T.surface, borderRadius: BorderRadius.circular(14), elevation: 4,
          items: items.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Row(children: [
              Icon(icon, size: 15, color: _T.textMuted), const SizedBox(width: 10),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 13, color: _T.textPrimary), overflow: TextOverflow.ellipsis)),
              if (value == item) const Icon(Icons.check_rounded, size: 15, color: _T.blue),
            ]),
          )).toList(),
          onChanged: onChanged,
          selectedItemBuilder: (_) => items.map((item) => Row(children: [
            Icon(icon, size: 15, color: _T.blue.withOpacity(0.6)), const SizedBox(width: 8),
            Text(item, style: const TextStyle(fontSize: 13, color: _T.textPrimary, fontWeight: FontWeight.w500)),
          ])).toList(),
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, required IconData icon, VoidCallback? onPressed, bool enabled = true}) {
    return SizedBox(
      width: double.infinity, height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: (enabled && onPressed != null) ? _T.blue : _T.textMuted.withOpacity(0.3),
          foregroundColor: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: (enabled && onPressed != null) ? onPressed : null,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 17), const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
        ]),
      ),
    );
  }

  Widget _outlineButton({required String label, required IconData icon, VoidCallback? onPressed, bool enabled = true}) {
    return SizedBox(
      width: double.infinity, height: 46,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _T.blue,
          side: BorderSide(color: (enabled && onPressed != null) ? _T.blue.withOpacity(0.4) : _T.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: (enabled && onPressed != null) ? onPressed : null,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 17), const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _infoBox(String message, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Icon(icon, size: 16, color: color), const SizedBox(width: 8),
        Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  void _showToast(BuildContext ctx, String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 8),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    ));
  }

  // ══════════════════════════════════════════════════════════════════
  //  PDF CONVOCATION
  // ══════════════════════════════════════════════════════════════════
  Future<void> genererPdfConvocation() async {
    final pdf = pw.Document();
    final logo = await imageFromAssetBundle("assets/logo.png");
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Row(children: [
            pw.Image(logo, width: 60), pw.SizedBox(width: 10),
            pw.Text("SyndiControl", style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.305, 0.478))),
          ]),
        ]),
        pw.SizedBox(height: 30),
        pw.Center(child: pw.Text("CONVOCATION À L'ASSEMBLÉE GÉNÉRALE",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.305, 0.478)),
            textAlign: pw.TextAlign.center)),
        pw.SizedBox(height: 30),
        pw.Text("Résidence : Al Amal"), pw.Text("Lieu : ${lieuController.text}"),
        pw.Text("Date : ${dateController.text}"), pw.Text("Heure : ${heureController.text}"),
        pw.SizedBox(height: 20),
        pw.Text("Objet : Convocation à l'AG $selectedTypeAG du ${dateController.text}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20), pw.Text("Madame, Monsieur,"), pw.SizedBox(height: 10),
        pw.Text("Par ce courrier, j'ai le plaisir de vous convoquer à l'Assemblée générale $selectedTypeAG de la Résidence Al Amal, le ${dateController.text} à ${heureController.text}, ${lieuController.text}.",
            style: const pw.TextStyle(fontSize: 12), textAlign: pw.TextAlign.justify),
        pw.SizedBox(height: 20),
        pw.Text("Ordre du jour :", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...ordreDuJourPoints.asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text("${e.key+1}. ${e.value['texte']}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: const PdfColor(0, 0.305, 0.478))),
              pw.Text(e.value['description'] ?? "", style: const pw.TextStyle(fontSize: 11)),
            ]))),
        pw.SizedBox(height: 30),
        pw.Align(alignment: pw.Alignment.centerRight,
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [pw.Text("Le Syndic"), pw.SizedBox(height: 20)])),
      ]),
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void partagerConvocation() {
    String texte = "📄 Convocation AG $selectedTypeAG\n📅 Date: ${dateController.text}\n⏰ Heure: ${heureController.text}\n📍 Lieu: ${lieuController.text}\n\n📋 Ordre du jour:\n";
    for (var i = 0; i < ordreDuJourPoints.length; i++) {
      texte += "${i+1}. ${ordreDuJourPoints[i]['texte']} - ${ordreDuJourPoints[i]['description']}\n";
    }
    Share.share(texte, subject: "Convocation AG $selectedTypeAG");
  }

  // ══════════════════════════════════════════════════════════════════
  //  PDF PV — CONTENU DU DOCUMENT 3 (texte officiel + tableau)
  // ══════════════════════════════════════════════════════════════════
  Future<void> _genererEtTelechargerPV(
    BuildContext context,
    String president,
    String syndic,
    String observations,
    Map<int, TextEditingController> pointControllers,
  ) async {
    try {
      final pdf = pw.Document();

      pw.ImageProvider? logoImage;
      try { logoImage = await imageFromAssetBundle("assets/logo.png"); } catch (_) {}

      const PdfColor pdfBleu     = PdfColor(0.10, 0.23, 0.36);
      const PdfColor pdfBleuVif  = PdfColor(0.00, 0.31, 0.48);
      const PdfColor pdfBleuFond = PdfColor(0.94, 0.96, 1.00);
      const PdfColor pdfGris     = PdfColor(0.42, 0.45, 0.50);
      const PdfColor pdfBordure  = PdfColor(0.90, 0.91, 0.92);
      const PdfColor pdfNoir     = PdfColor(0.12, 0.16, 0.24);

      final int totalVotants = presents + procurations;
      final int abs = (totalCoproprietaires - totalVotants).clamp(0, totalCoproprietaires);

      final Map<int, String> anneeEnLettres = {
        2024: "deux mille vingt-quatre", 2025: "deux mille vingt-cinq",
        2026: "deux mille vingt-six",    2027: "deux mille vingt-sept",
        2028: "deux mille vingt-huit",
      };
      final String anneeLettre = anneeEnLettres[DateTime.now().year] ?? DateTime.now().year.toString();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 45),

        header: (_) => pw.Column(children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.Row(children: [
              if (logoImage != null) ...[pw.Image(logoImage, width: 36, height: 36), pw.SizedBox(width: 10)]
              else pw.Container(width: 36, height: 36, decoration: pw.BoxDecoration(color: pdfBleu, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8))),
                  child: pw.Center(child: pw.Text("SC", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)))),
              pw.SizedBox(width: 10),
              pw.Text("SyndiControl", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: pdfBleu)),
            ]),
          ]),
          pw.SizedBox(height: 10), pw.Container(height: 2, color: pdfBleu), pw.SizedBox(height: 16),
        ]),

        footer: (_) => pw.Column(children: [
          pw.Container(height: 1, color: pdfBordure), pw.SizedBox(height: 6),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text("SyndiControl", style: pw.TextStyle(fontSize: 8, color: pdfGris)),
            pw.Text("Page ${_.pageNumber} / ${_.pagesCount}", style: pw.TextStyle(fontSize: 8, color: pdfGris)),
          ]),
        ]),

        build: (_) => [
          // Titre central
          pw.Center(child: pw.Column(children: [
            pw.Text("PROCÈS-VERBAL DE L'ASSEMBLÉE GÉNÉRALE", style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: pdfBleu, letterSpacing: 0.8), textAlign: pw.TextAlign.center),
            pw.Text(selectedTypeAG.toUpperCase(), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: pdfBleuVif, letterSpacing: 1.0), textAlign: pw.TextAlign.center),
          ])),
          pw.SizedBox(height: 6),
          pw.Center(child: pw.Container(width: 60, height: 2, color: pdfBleu)),
          pw.SizedBox(height: 20),

          // Texte introductif officiel
          pw.RichText(text: pw.TextSpan(style: pw.TextStyle(fontSize: 11, color: pdfNoir), children: [
            pw.TextSpan(text: "L'an "),
            pw.TextSpan(text: anneeLettre, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: ", le "),
            pw.TextSpan(text: dateController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: " à "),
            pw.TextSpan(text: heureController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: ", les copropriétaires de la résidence se sont réunis en assemblée générale ${selectedTypeAG.toLowerCase()}, sur convocation régulière du syndic, au lieu suivant : "),
            pw.TextSpan(text: lieuController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: "."),
          ])),
          pw.SizedBox(height: 10),

          pw.RichText(text: pw.TextSpan(style: pw.TextStyle(fontSize: 11, color: pdfNoir), children: [
            pw.TextSpan(text: "L'Assemblée est présidée par "),
            pw.TextSpan(text: president.isEmpty ? "[Président de séance]" : president, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: ". Le syndic de la résidence est représenté par "),
            pw.TextSpan(text: syndic.isEmpty ? "[Syndic]" : syndic, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: "."),
          ])),
          pw.SizedBox(height: 10),

          pw.RichText(text: pw.TextSpan(style: pw.TextStyle(fontSize: 11, color: pdfNoir), children: [
            pw.TextSpan(text: "Il a été établi une feuille de présence signée par tous les membres présents et demeurée annexée au présent procès-verbal. Cette feuille de présence permet de constater que "),
            pw.TextSpan(text: "$totalVotants", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: " copropriétaires sur "),
            pw.TextSpan(text: "$totalCoproprietaires", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: " sont présents ou représentés, dont "),
            pw.TextSpan(text: "$presents présents", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: " et "),
            pw.TextSpan(text: "$procurations procurations", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: ". Le nombre d'absents est de "),
            pw.TextSpan(text: "$abs", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: "."),
          ])),
          pw.SizedBox(height: 20),

          // Tableau récapitulatif
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(border: pw.Border.all(color: pdfBordure), borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
            child: pw.Table(
              border: pw.TableBorder(horizontalInside: const pw.BorderSide(color: PdfColor(0.90, 0.91, 0.92), width: 1)),
              columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(1)},
              children: [
                _pdfRow("Total copropriétaires convoqués", "$totalCoproprietaires", pdfBleuFond, pdfNoir, pdfBleu, header: true),
                _pdfRow("Présents", "$presents", PdfColors.white, pdfNoir, pdfBleu),
                _pdfRow("Procurations", "$procurations", PdfColors.white, pdfNoir, pdfBleu),
                _pdfRow("Total votants", "$totalVotants", pdfBleuFond, pdfNoir, pdfBleu),
                _pdfRow("Absents", "$abs", PdfColors.white, pdfNoir, pdfBleu),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Déroulement
          _pdfSectionTitre("DÉROULEMENT DE LA SÉANCE", pdfBleu),
          pw.SizedBox(height: 12),

          ...ordreDuJourPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final resume = pointControllers[index]?.text ?? "";
            return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: pw.BoxDecoration(color: pdfBleuFond,
                    borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(5), topRight: pw.Radius.circular(5))),
                child: pw.Row(children: [
                  pw.Container(width: 22, height: 22,
                      decoration: pw.BoxDecoration(color: pdfBleu, borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
                      child: pw.Center(child: pw.Text("${index+1}", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)))),
                  pw.SizedBox(width: 10),
                  pw.Expanded(child: pw.Text(point['texte'] ?? "Point ${index+1}",
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: pdfNoir))),
                ]),
              ),
              pw.Container(
                width: double.infinity, padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: pdfBordure),
                    borderRadius: const pw.BorderRadius.only(bottomLeft: pw.Radius.circular(5), bottomRight: pw.Radius.circular(5))),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text("Discussion :", style: pw.TextStyle(fontSize: 9, color: pdfGris, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(resume.isEmpty ? "Aucune note enregistrée." : resume,
                      style: pw.TextStyle(fontSize: 10, color: resume.isEmpty ? pdfGris : pdfNoir)),
                ]),
              ),
              pw.SizedBox(height: 10),
            ]);
          }),

          if (observations.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            _pdfSectionTitre("OBSERVATIONS GÉNÉRALES", pdfBleu),
            pw.SizedBox(height: 8),
            pw.Container(
              width: double.infinity, padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: pdfBordure),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5))),
              child: pw.Text(observations, style: pw.TextStyle(fontSize: 10, color: pdfNoir)),
            ),
          ],
          pw.SizedBox(height: 40),
        ],
      ));

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
      _showToast(context, "PV généré avec succès", _T.success, Icons.picture_as_pdf_outlined);
    } catch (e) {
      _showToast(context, "Erreur génération PDF : $e", _T.danger, Icons.error_outline_rounded);
    }
  }

  pw.TableRow _pdfRow(String label, String val, PdfColor bg, PdfColor text, PdfColor blue, {bool header = false}) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bg),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: pw.Text(label, style: pw.TextStyle(fontSize: 10,
                fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: header ? blue : text))),
        pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: pw.Text(val, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold,
                color: header ? blue : text), textAlign: pw.TextAlign.center)),
      ],
    );
  }

  pw.Widget _pdfSectionTitre(String titre, PdfColor pdfBleu) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(titre, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: pdfBleu, letterSpacing: 1.0)),
      pw.SizedBox(height: 4),
      pw.Container(height: 1.5, color: pdfBleu),
    ]);
  }

  // Legacy helpers
  Widget _buildTextField({required TextEditingController controller, required String hint}) =>
      _modernTextField(controller: controller, label: hint, icon: Icons.edit_outlined);
  Widget _buildDateField({required TextEditingController controller, required String hint}) =>
      _modernDateField(controller: controller, label: hint, icon: Icons.calendar_today_rounded);
  Widget _buildTimeField({required TextEditingController controller, required String hint}) =>
      _modernTimeField(controller: controller, label: hint, icon: Icons.access_time_rounded);
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
      {"icon": Icons.message, "title": "Assemblée Générale"},
      {"icon": Icons.settings, "title": "Paramètres"},
    ];

    return Drawer(
      backgroundColor: const Color(0xFF004E7A),
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