import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color primaryBlue = Color(0xFF004E7A);
const Color bgLight     = Color(0xFFF4F6FA);
const _green = Color(0xFF00B87A);
const _red   = Color(0xFFEF4444);
const _amber = Color(0xFFF59E0B);

class AddChargeScreen extends StatefulWidget {
  const AddChargeScreen({super.key});

  @override
  State<AddChargeScreen> createState() => _AddChargeScreenState();
}

class _AddChargeScreenState extends State<AddChargeScreen> {
  final TextEditingController _nameController        = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  double _amount           = 0;
  String _date             = "";
  String _selectedBuilding = "Sélectionner un immeuble";
  Color  _selectedColor    = primaryBlue;
  IconData _selectedIcon   = Icons.water_drop;
  bool _isSending          = false;

  final List<Color> _availableColors = [
    const Color(0xFF004E7A),
    const Color(0xFF0B74A8),
    const Color(0xFFF6D937),
    const Color(0xFF1B8F6A),
    const Color(0xFFCB5878),
    const Color(0xFF9C27B0),
    const Color(0xFFFF5722),
    const Color(0xFF795548),
  ];

  final List<Map<String, dynamic>> _availableIcons = [
    {"icon": Icons.water_drop,        "name": "Eau"},
    {"icon": Icons.flash_on,          "name": "Électricité"},
    {"icon": Icons.local_florist,     "name": "Jardin"},
    {"icon": Icons.build,             "name": "Entretien"},
    {"icon": Icons.cleaning_services, "name": "Nettoyage"},
    {"icon": Icons.security,          "name": "Sécurité"},
    {"icon": Icons.pool,              "name": "Piscine"},
    {"icon": Icons.sports_tennis,     "name": "Sport"},
    {"icon": Icons.restaurant,        "name": "Restaurant"},
    {"icon": Icons.park,              "name": "Parc"},
    {"icon": Icons.garage,            "name": "Garage"},
    {"icon": Icons.elevator,          "name": "Ascenseur"},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  TOAST
  // ══════════════════════════════════════════════════════════════
  void _showToast({required String message, required _ToastType type}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  // ══════════════════════════════════════════════════════════════
  //  DATE PICKER
  // ══════════════════════════════════════════════════════════════
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: primaryBlue, onPrimary: Colors.white,
              onSurface: primaryBlue),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryBlue)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _date = DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  COLOR PICKER
  // ══════════════════════════════════════════════════════════════
  void _showColorPickerDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Choisir une couleur",
                style: TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w800, color: primaryBlue)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _availableColors.map((color) {
                final bool sel = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: color.withOpacity(sel ? 0.5 : 0.2),
                            blurRadius: sel ? 12 : 4,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10)),
              child: const Text("Annuler",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  ICON PICKER
  // ══════════════════════════════════════════════════════════════
  void _showIconPickerDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Choisir une icône",
                style: TextStyle(fontSize: 17,
                    fontWeight: FontWeight.w800, color: primaryBlue)),
            const SizedBox(height: 16),
            SizedBox(
              height: 360,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: _availableIcons.length,
                itemBuilder: (_, index) {
                  final iconData = _availableIcons[index]["icon"] as IconData;
                  final iconName = _availableIcons[index]["name"] as String;
                  final bool sel = _selectedIcon == iconData;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIcon = iconData);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: sel
                            ? primaryBlue.withOpacity(0.10)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: sel ? primaryBlue : Colors.grey.shade200,
                            width: sel ? 2 : 1),
                        boxShadow: sel
                            ? [BoxShadow(
                                color: primaryBlue.withOpacity(0.15),
                                blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Icon(iconData, size: 28,
                            color: sel ? primaryBlue : Colors.grey.shade600),
                        const SizedBox(height: 5),
                        Text(iconName,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: sel
                                    ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? primaryBlue : Colors.grey.shade500)),
                        if (sel) ...[
                          const SizedBox(height: 3),
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: primaryBlue),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10)),
              child: const Text("Annuler",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  VALIDATION
  // ══════════════════════════════════════════════════════════════
  bool _validateFields() {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _amount > 0 &&
        _date.isNotEmpty &&
        _selectedBuilding != "Sélectionner un immeuble";
  }

  // ══════════════════════════════════════════════════════════════
  //  AJOUTER + NOTIFICATION HABITANTS
  // ══════════════════════════════════════════════════════════════
  Future<void> _addCharge() async {
    // 1️⃣ Vérifications individuelles → toasts précis
    if (_nameController.text.trim().isEmpty) {
      _showToast(message: "Veuillez saisir le nom de la charge",
          type: _ToastType.warning); return;
    }
    if (_amount <= 0) {
      _showToast(message: "Veuillez saisir un montant supérieur à 0",
          type: _ToastType.warning); return;
    }
    if (_date.isEmpty) {
      _showToast(message: "Veuillez sélectionner une date limite",
          type: _ToastType.warning); return;
    }
    if (_selectedBuilding == "Sélectionner un immeuble") {
      _showToast(message: "Veuillez sélectionner un immeuble",
          type: _ToastType.warning); return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showToast(message: "Veuillez ajouter une description",
          type: _ToastType.warning); return;
    }

    // 2️⃣ Chargement
    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSending = false);

    // 3️⃣ Succès charge ajoutée
    _showToast(
      message: "Charge \"${_nameController.text.trim()}\" ajoutée avec succès !",
      type: _ToastType.success,
    );

    // 4️⃣ Délai puis dialog notification habitants
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _showNotificationHabitantsDialog();
  }

  // ══════════════════════════════════════════════════════════════
  //  DIALOG NOTIFICATION HABITANTS
  // ══════════════════════════════════════════════════════════════
  void _showNotificationHabitantsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.50),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Icône notification
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FF),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: primaryBlue.withOpacity(0.20), width: 1.5)),
              child: const Icon(Icons.notifications_active_rounded,
                  size: 34, color: primaryBlue),
            ),
            const SizedBox(height: 16),

            // Titre
            const Text("Notifier les habitants",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w800, color: primaryBlue)),
            const SizedBox(height: 8),

            // Description
            Text(
              "Voulez-vous envoyer une notification à tous les habitants "
              "de $_selectedBuilding pour les informer de la nouvelle charge ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13,
                  color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 16),

            // Aperçu du message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: primaryBlue.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.mark_email_read_outlined,
                        size: 16, color: primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "📢 Nouvelle charge : \"${_nameController.text.trim()}\" "
                      "d'un montant de ${_amount.toInt()} MAD a été ajoutée. "
                      "Date limite : $_date.",
                      style: const TextStyle(fontSize: 12,
                          color: Color(0xFF4B6280), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 18),

            // Boutons
            Row(children: [
              // Ignorer
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, {
                      "title":    _nameController.text.trim(),
                      "date":     _date,
                      "amount":   "${_amount.toInt()} MAD",
                      "progress": 0.0,
                      "color":    _selectedColor,
                      "icon":     _selectedIcon,
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Ignorer",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              // Envoyer
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendAndReturn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 16),
                      SizedBox(width: 6),
                      Text("Envoyer",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  void _sendAndReturn() {
    _showToast(
      message: "Notification envoyée à tous les habitants de $_selectedBuilding ✓",
      type: _ToastType.success,
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.pop(context, {
          "title":    _nameController.text.trim(),
          "date":     _date,
          "amount":   "${_amount.toInt()} MAD",
          "progress": 0.0,
          "color":    _selectedColor,
          "icon":     _selectedIcon,
        });
      }
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
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

  Widget _buildHeader() {
    return SizedBox(
      height: 220, width: double.infinity,
      child: Stack(children: [
        Image.asset("assets/j.jpg", fit: BoxFit.cover,
            width: double.infinity),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue.withOpacity(0.4),
                primaryBlue.withOpacity(0.9)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    return Column(children: [
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + boutons couleur/icône
                Row(children: [
                  const Text("Informations de la charge",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Bouton couleur
                  GestureDetector(
                    onTap: _showColorPickerDialog,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(
                            color: _selectedColor.withOpacity(0.35),
                            blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: const Icon(Icons.color_lens_outlined,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton icône
                  GestureDetector(
                    onTap: _showIconPickerDialog,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: primaryBlue.withOpacity(0.20)),
                      ),
                      child: Icon(_selectedIcon,
                          color: primaryBlue, size: 20),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),

                _buildTextField(
                  icon: Icons.badge,
                  label: "Nom de la charge",
                  hint: "Ex : Eau, Électricité...",
                  controller: _nameController,
                ),
                const SizedBox(height: 12),
                _buildAmountField(),
                const SizedBox(height: 12),
                _buildSelectableTile(
                  icon: Icons.calendar_today,
                  title: "Date limite",
                  value: _date.isEmpty ? "Choisir..." : _date,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 24),

                const Text("Habitants concernés",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildBuildingDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  icon: Icons.description,
                  label: "Description",
                  hint: "Détails de la charge...",
                  controller: _descriptionController,
                ),
                const SizedBox(height: 30),
                _buildAddButton(),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        const Text("Ajouter une charge",
            style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold)),
        const Spacer(),
        const SizedBox(width: 45),
      ]),
    );
  }

  Widget _buildTextField({
    required IconData icon, required String label,
    required String hint, required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF7F9FD),
          borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: primaryBlue),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none),
        ),
      ]),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF7F9FD),
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.payments_outlined, color: primaryBlue),
        const SizedBox(width: 8),
        const Text("Montant total",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        SizedBox(
          width: 90,
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: primaryBlue),
            onChanged: (val) =>
                setState(() => _amount = double.tryParse(val) ?? 0),
            decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none),
          ),
        ),
        const Text(" MAD",
            style: TextStyle(fontWeight: FontWeight.w600, color: primaryBlue)),
      ]),
    );
  }

  Widget _buildSelectableTile({
    required IconData icon, required String title,
    required String value, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF7F9FD),
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(
              color: value == "Choisir..."
                  ? Colors.grey.shade400 : primaryBlue,
              fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _buildBuildingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: const Color(0xFFF7F9FD),
          borderRadius: BorderRadius.circular(16)),
      child: DropdownButton<String>(
        value: _selectedBuilding,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: primaryBlue, fontSize: 14),
        items: [
          "Sélectionner un immeuble",
          "Immeuble A", "Immeuble B",
          "Immeuble C", "Immeuble D",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _selectedBuilding = v!),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          backgroundColor: primaryBlue,
          elevation: 0,
        ),
        onPressed: _isSending ? null : _addCharge,
        child: _isSending
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : const Text("Ajouter la charge",
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TOAST TYPE
// ══════════════════════════════════════════════════════════════════
enum _ToastType { success, error, warning }

// ══════════════════════════════════════════════════════════════════
//  TOAST WIDGET
// ══════════════════════════════════════════════════════════════════
class _ToastWidget extends StatefulWidget {
  final String message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message, required this.type, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<double>(begin: -80, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 3500), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _bgColor {
    switch (widget.type) {
      case _ToastType.success: return const Color.fromARGB(255, 34, 173, 55);
      case _ToastType.error:   return const Color(0xFFDC2626);
      case _ToastType.warning: return _amber;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case _ToastType.success: return Icons.check_circle_rounded;
      case _ToastType.error:   return Icons.error_rounded;
      case _ToastType.warning: return Icons.warning_amber_rounded;
    }
  }

  String get _label {
    switch (widget.type) {
      case _ToastType.success: return "Succès";
      case _ToastType.error:   return "Erreur";
      case _ToastType.warning: return "Attention";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16, right: 16,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(opacity: _fadeAnim.value, child: child),
        ),
        child: GestureDetector(
          onTap: _dismiss,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: _bgColor.withOpacity(0.40),
                    blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(_icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_label, style: const TextStyle(
                          color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(widget.message, style: TextStyle(
                          color: Colors.white.withOpacity(0.88),
                          fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}