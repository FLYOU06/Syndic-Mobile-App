import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'add_habitant_screen.dart';
import 'habitant_details_screen.dart';

const Color primaryBlue = Color(0xFF004E7A);
const Color bgLight = Color(0xFFF6F7FB);

class HabitantsScreen extends StatefulWidget {
  const HabitantsScreen({super.key});

  @override
  State<HabitantsScreen> createState() => _HabitantsScreenState();
}

class _HabitantsScreenState extends State<HabitantsScreen> {
  bool showOwners = true;
  String search = "";

  final List<Map<String, String>> owners = [
    {"name": "Ahmed El Amrani", "immeuble": "Immeuble 1", "apt": "B12", "role": "Propriétaire"},
    {"name": "Sophie Dupont", "immeuble": "Immeuble 2", "apt": "A08", "role": "Propriétaire"},
  ];

  final List<Map<String, String>> tenants = [
    {"name": "Youssef Benali", "immeuble": "Immeuble 1", "apt": "C03", "role": "Locataire"},
    {"name": "Nadia Rahmani", "immeuble": "Immeuble 2", "apt": "D10", "role": "Locataire"},
  ];

  List<Map<String, String>> get _currentList => showOwners ? owners : tenants;

  List<Map<String, String>> get _filteredList {
    final q = search.toLowerCase();
    return _currentList.where((h) {
      return h["name"]!.toLowerCase().contains(q) ||
          h["apt"]!.toLowerCase().contains(q) ||
          h["immeuble"]!.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildHeader(),
              Positioned(bottom: -22, left: 16, right: 16, child: _buildSwitch()),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => _buildHabitantCard(_filteredList[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color.fromARGB(255, 20, 81, 118),  // bleu pétrole
        Color.fromARGB(255, 71, 128, 160), // bleu doux
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 20, 81, 118).withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: FloatingActionButton(
    backgroundColor: Colors.transparent,
    elevation: 0,
    onPressed: _addHabitant,
    child: const Icon(
      Icons.add,
      color: Colors.white,
      size: 28,
    ),
  ),
),

    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    final height = MediaQuery.of(context).size.height * 0.23;
    return SizedBox(
      height: height + 40,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: primaryBlue),
          Positioned.fill(child: Image.asset("assets/j.jpg", fit: BoxFit.cover)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue.withOpacity(0.4), primaryBlue.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(Icons.menu, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Habitants",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_currentList.length} ${showOwners ? 'Propriétaires' : 'Locataires'}",
                    style: const TextStyle(color: Color.fromARGB(179, 248, 250, 251), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(
          hintText: "Rechercher un habitant",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= SWITCH =================
 // ================= SWITCH MODERNE =================
Widget _buildSwitch() {
  return Container(
    height: 50,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Le fond animé du bouton sélectionné
        AnimatedAlign(
          alignment: showOwners ? Alignment.centerLeft : Alignment.centerRight,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Container(
            width: (MediaQuery.of(context).size.width - 32) / 2 - 8, // moitié - padding
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 2),
           decoration: BoxDecoration(
  gradient: const LinearGradient(
    colors: [
     Color(0xFF004E7A),// bleu pétrole
      Color(0xFF006DAA),                // bleu ciel doux
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(28),
  boxShadow: [
    BoxShadow(
      color: const Color.fromARGB(255, 20, 81, 118).withOpacity(0.35),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ],
),
          ),
        ),
        // Les deux textes cliquables
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showOwners = true),
                child: Center(
                  child: Text(
                    "Propriétaires",
                    style: TextStyle(
                        color: showOwners ? Colors.white : primaryBlue,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showOwners = false),
                child: Center(
                  child: Text(
                    "Locataires",
                    style: TextStyle(
                        color: showOwners ? primaryBlue : Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // ================= HABITANT CARD =================
Widget _buildHabitantCard(Map<String, String> h) {
  final bool isOwner = h["role"] == "Propriétaire";
  final listRef = isOwner ? owners : tenants;

  return Container(
    padding: const EdgeInsets.all(16),
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
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final index = listRef.indexOf(h);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => HabitantDetailsScreen(habitant: h)),
        );
        if (result is Map<String, String>) {
          setState(() => listRef[index] = result);
        }
        if (result == "delete") {
          setState(() => listRef.removeAt(index));
        }
      },
      child: Row(
        children: [

          // ===== AVATAR =====
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color.fromARGB(255, 246, 250, 252).withOpacity(0.25),
            child: Text(
              h["name"]![0],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ===== INFOS =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h["name"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.apartment,
                        size: 14, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 4),
                    Text(
                      h["immeuble"]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.meeting_room,
                        size: 14, color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 4),
                    Text(
                      h["apt"]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== BADGE =====
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOwner
                  ? const Color.fromARGB(255, 246, 250, 252).withOpacity(0.25)   // doré doux
                  : const Color.fromARGB(255, 250, 253, 254).withOpacity(0.25),  // vert doux
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOwner ? "Prop" : "Loc",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white.withOpacity(0.85),
          ),
        ],
      ),
    ),
  );
}
  // ================= DRAWER =================
  Widget _buildDrawer() {
    return AppDrawer(
      selectedMenu: "Habitants",
      onMenuSelected: (menu) {
        if (menu == "Dashboard") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()));
        }
      },
    );
  }

  // ================= ADD HABITANT =================
  Future<void> _addHabitant() async {
    final newHabitant = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddHabitantScreen()));
    if (newHabitant != null && newHabitant is Map<String, String>) {
      setState(() {
        if (newHabitant["role"] == "Propriétaire") {
          owners.add(newHabitant);
          showOwners = true;
        } else {
          tenants.add(newHabitant);
          showOwners = false;
        }
      });
    }
  }
}
