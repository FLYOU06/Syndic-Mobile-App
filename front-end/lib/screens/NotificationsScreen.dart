import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════
//  TOKENS
// ══════════════════════════════════════════════════════════════════
const _navy   = Color(0xFF004E7A);
const _navyDk = Color(0xFF003255);
const _bg     = Color(0xFFF0F4F8);
const _white  = Color(0xFFFFFFFF);
const _border = Color(0xFFE2EAF2);

const _green  = Color(0xFF10B981);
const _greenL = Color(0xFFD1FAE5);
const _red    = Color(0xFFEF4444);
const _redL   = Color(0xFFFEE2E2);
const _amber  = Color(0xFFF59E0B);
const _amberL = Color(0xFFFEF3C7);
const _blue   = Color(0xFF3B82F6);
const _blueL  = Color(0xFFDBEAFE);

const _t1 = Color(0xFF0D1B2A);
const _t2 = Color(0xFF4B6280);
const _t3 = Color(0xFFAABBCC);

// ══════════════════════════════════════════════════════════════════
//  MODEL
// ══════════════════════════════════════════════════════════════════
class _Notif {
  final String id, title, message, type, date, time;
  bool read;
  _Notif({required this.id, required this.title, required this.message,
      required this.type, required this.date, required this.time,
      this.read = false});
}

// ══════════════════════════════════════════════════════════════════
//  SCREEN
// ══════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override State<NotificationsScreen> createState() => _NotifState();
}

class _NotifState extends State<NotificationsScreen> with TickerProviderStateMixin {

  late final TabController _tab;
  int _sel = 0;

  final List<_Notif> _items = [
    _Notif(id:'1', title:"Paiement reçu", type:"payment", date:"Aujourd'hui",
        time:"09:30", read:false,
        message:"Ahmed El Amrani a réglé 350 DH pour la charge Eau — Janvier 2025."),
    _Notif(id:'2', title:"Charge impayée", type:"warning", date:"Aujourd'hui",
        time:"08:15", read:false,
        message:"L'appartement B12 n'a pas encore payé la charge Eau (120 DH)."),
    _Notif(id:'3', title:"Rappel d'assemblée", type:"assembly", date:"Hier",
        time:"18:00", read:false,
        message:"L'assemblée générale est prévue le 20 Février 2025 à 18h00 — Salle commune."),
    _Notif(id:'4', title:"Nouveau résident", type:"info", date:"Hier",
        time:"10:22", read:true,
        message:"Sara Benali a rejoint la résidence et occupe l'appartement C04."),
    _Notif(id:'5', title:"Paiement reçu", type:"payment", date:"Lundi",
        time:"11:05", read:true,
        message:"Karim El Idrissi a payé 500 DH pour la charge Électricité."),
    _Notif(id:'6', title:"Maintenance planifiée", type:"info", date:"Lundi",
        time:"09:00", read:true,
        message:"L'ascenseur sera en maintenance le 18 Jan de 08h00 à 12h00."),
  ];

  int get _unreadCount => _items.where((n) => !n.read).length;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() => _sel = _tab.index));
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _markRead(String id) =>
      setState(() => _items.firstWhere((n) => n.id == id).read = true);

  void _markAll() {
    HapticFeedback.lightImpact();
    setState(() { for (final n in _items) n.read = true; });
  }

  Map<String, dynamic> _theme(String type) => switch (type) {
    'payment'  => {'icon': Icons.payments_rounded,        'color': _green, 'light': _greenL, 'tag': 'Paiement'},
    'warning'  => {'icon': Icons.warning_amber_rounded,   'color': _red,   'light': _redL,   'tag': 'Alerte'},
    'assembly' => {'icon': Icons.groups_2_rounded,        'color': _amber, 'light': _amberL, 'tag': 'Assemblée'},
    _          => {'icon': Icons.info_outline_rounded,    'color': _blue,  'light': _blueL,  'tag': 'Info'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(context),
        _buildTabBar(),
        Expanded(child: TabBarView(
          controller: _tab,
          children: [
            _buildTimeline(_items),
            _buildTimeline(_items.where((n) => !n.read).toList()),
          ],
        )),
      ]),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo de fond — identique à DetailChargeScreen
          Image.asset("assets/j.jpg", fit: BoxFit.cover),

          // Overlay dégradé — identique à DetailChargeScreen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF004E7A).withOpacity(0.55),
                  const Color(0xFF004E7A).withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bouton retour simple — à gauche
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),

                  // Titre centré
                  const Text(
                    "Notifications",
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),

                  // Bouton "Tout lire" à droite (visible si non-lues)
                  if (_unreadCount > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _markAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: const Text("Tout lire",
                              style: TextStyle(color: Colors.white,
                                  fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB BAR ───────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: [
        // 2 boutons pleine largeur côte à côte
        Row(children: [
          Expanded(child: _tabChip(0, "Toutes", null)),
          const SizedBox(width: 10),
          Expanded(child: _tabChip(1, "Non lues", _unreadCount > 0 ? _unreadCount : null)),
        ]),
        const SizedBox(height: 16),
        Container(height: 1, color: _border),
      ]),
    );
  }

  Widget _tabChip(int idx, String label, int? badge) {
    final active = _sel == idx;
    return GestureDetector(
      onTap: () => _tab.animateTo(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: active ? _navy : _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? _navy : _border, width: 1),
          boxShadow: active ? [
            BoxShadow(color: _navy.withOpacity(0.25),
                blurRadius: 10, offset: const Offset(0, 4)),
          ] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: active ? Colors.white : _t2)),
          if (badge != null) ...[
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: active ? Colors.white.withOpacity(0.2) : _red,
                  borderRadius: BorderRadius.circular(10)),
              child: Text("$badge", style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ]),
      ),
    );
  }

  // ── TIMELINE ──────────────────────────────────────────────────
  Widget _buildTimeline(List<_Notif> items) {
    if (items.isEmpty) return _emptyState();

    final Map<String, List<_Notif>> grouped = {};
    for (final n in items) grouped.putIfAbsent(n.date, () => []).add(n);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: grouped.entries.expand<Widget>((e) => [
        _dateLabel(e.key),
        ...e.value.asMap().entries.map((en) =>
            _tile(en.value, en.key, e.value.length)),
      ]).toList(),
    );
  }

  Widget _dateLabel(String date) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 12),
    child: Row(children: [
      Container(width: 4, height: 4,
          decoration: const BoxDecoration(color: _t3, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(date.toUpperCase(), style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w800, color: _t3, letterSpacing: 1.2)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: _border)),
    ]),
  );

  Widget _tile(_Notif n, int idx, int total) {
    final th = _theme(n.type);
    final Color color = th['color'];
    final Color light = th['light'];
    final IconData icon = th['icon'];
    final String tag = th['tag'];
    final bool isLast = idx == total - 1;

    return GestureDetector(
      onTap: () => _markRead(n.id),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── RAIL ────────────────────────────────────────────────
        SizedBox(width: 50, child: Column(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: n.read ? light.withOpacity(0.4) : light,
              shape: BoxShape.circle,
              border: Border.all(
                color: n.read ? color.withOpacity(0.15) : color.withOpacity(0.4),
                width: n.read ? 1.0 : 1.8,
              ),
              boxShadow: n.read ? [] : [
                BoxShadow(color: color.withOpacity(0.22),
                    blurRadius: 12, offset: const Offset(0, 5)),
              ],
            ),
            child: Icon(icon, color: color.withOpacity(n.read ? 0.45 : 1.0), size: 20),
          ),
          if (!isLast)
            Container(
              width: 2, height: 50,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.25), Colors.transparent],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ])),

        const SizedBox(width: 10),

        // ── CARD ─────────────────────────────────────────────────
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: n.read ? _border : color.withOpacity(0.28),
                width: n.read ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: n.read ? Colors.black.withOpacity(0.04) : color.withOpacity(0.1),
                  blurRadius: n.read ? 8 : 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Title + dot
                Row(children: [
                  Expanded(child: Text(n.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: n.read ? _t1 : color))),
                  if (!n.read)
                    Container(width: 9, height: 9,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ]),

                const SizedBox(height: 5),

                // Message
                Text(n.message, style: TextStyle(fontSize: 13,
                    color: n.read ? _t2 : _t1, height: 1.5)),

                const SizedBox(height: 10),

                // Footer
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(color: light, borderRadius: BorderRadius.circular(8)),
                    child: Text(tag, style: TextStyle(fontSize: 10.5,
                        fontWeight: FontWeight.w700, color: color)),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time_rounded, size: 12, color: _t3),
                  const SizedBox(width: 4),
                  Text(n.time, style: const TextStyle(fontSize: 11.5, color: _t3)),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80,
          decoration: BoxDecoration(color: _navy.withOpacity(0.06), shape: BoxShape.circle),
          child: Icon(Icons.notifications_off_outlined, size: 36,
              color: _navy.withOpacity(0.3))),
      const SizedBox(height: 18),
      const Text("Aucune notification",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _t1)),
      const SizedBox(height: 6),
      const Text("Tout est à jour ✓", style: TextStyle(fontSize: 13, color: _t3)),
    ]),
  );
}