import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF004E7A);
const Color bgLight = Color(0xFFF6F8FC);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Paiement reçu",
      "message": "Ahmed El Amrani a payé 350 DH",
      "type": "payment",
      "date": "Aujourd’hui 09:30",
      "read": false,
    },
    {
      "title": "Charge impayée",
      "message": "Appartement B12 – Eau (120 DH)",
      "type": "warning",
      "date": "Hier 18:10",
      "read": false,
    },
    {
      "title": "Rappel d’assemblée",
      "message": "Assemblée générale le 20 Février",
      "type": "info",
      "date": "Hier 10:00",
      "read": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final unread = notifications.where((n) => !n["read"]).toList();

    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          _header(context),
          _tabsBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _notificationList(notifications),
                _notificationList(unread),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
// ================= HEADER =================
// ================= HEADER =================
Widget _header(BuildContext context) {
  return SizedBox(
    height: 190,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          "assets/j.jpg",
          fit: BoxFit.cover,
        ),
        Container(color: primaryBlue.withOpacity(0.65)),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // 🔝 LIGNE DU HAUT
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 4),

                // 🔹 SOUS-TITRE
                const Center(
                  child: Text(
                    "Paiements, alertes et annonces",
                    style: TextStyle(
                      color: Color.fromARGB(255, 241, 243, 244),
                      fontSize: 16,
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

  // ================= TABS =================
  Widget _tabsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: primaryBlue,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: "Toutes"),
            Tab(text: "Non lues"),
          ],
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _notificationList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Aucune notification",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _NotificationTile(item: list[index]);
      },
    );
  }
}

// ================= TILE =================
class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool unread = !item["read"];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unread
            ? Border.all(color: primaryBlue.withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _icon(item["type"]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item["title"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
                    if (unread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item["message"]),
                const SizedBox(height: 6),
                Text(
                  item["date"],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case "payment":
        icon = Icons.payments_rounded;
        color = Colors.green;
        break;
      case "warning":
        icon = Icons.warning_rounded;
        color = Colors.redAccent;
        break;
      default:
        icon = Icons.notifications;
        color = primaryBlue;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}