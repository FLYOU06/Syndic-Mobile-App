import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetController;
  final TextEditingController _emailController          = TextEditingController();
  final TextEditingController _passwordController       = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading              = false;
  double _logoOffset           = 0.0;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_updateLogoPosition);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_updateLogoPosition);
    _sheetController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateLogoPosition() {
    if (_sheetController.isAttached) {
      final currentSize = _sheetController.size;
      double offset = 0.0;
      if (currentSize < 0.5) {
        offset = (currentSize - 0.12) * -50;
      } else if (currentSize < 0.6) {
        offset = ((currentSize - 0.3) / 0.3) * -150 - 50;
      } else {
        offset = -150;
      }
      setState(() => _logoOffset = offset);
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  TOAST (même système que LoginScreen)
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
  //  SIGNUP
  // ══════════════════════════════════════════════════════════════
  void _performSignup() async {
    final email           = _emailController.text.trim();
    final password        = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showToast(
        message: "Veuillez remplir tous les champs",
        type: _ToastType.warning,
      );
      return;
    }

    if (!email.contains('@')) {
      _showToast(
        message: "Veuillez saisir un email valide",
        type: _ToastType.warning,
      );
      return;
    }

    if (password.length < 6) {
      _showToast(
        message: "Le mot de passe doit contenir au moins 6 caractères",
        type: _ToastType.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      _showToast(
        message: "Les mots de passe ne correspondent pas",
        type: _ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signup(email, password);

      if (response['message'] == "User created") {
        _showToast(
          message: "Inscription réussie ! Veuillez vous connecter",
          type: _ToastType.success,
        );
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showToast(
          message: response['message'] ?? "Erreur lors de l'inscription",
          type: _ToastType.error,
        );
      }
    } catch (e) {
      _showToast(
        message: "Impossible de créer le compte. Vérifiez votre connexion.",
        type: _ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToLogin() => Navigator.pop(context);

  // ══════════════════════════════════════════════════════════════
  //  STYLES
  // ══════════════════════════════════════════════════════════════
  TextStyle get _titleStyle => const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w600,
        fontFamily: 'Alike',
      );

  TextStyle get _subtitleStyle => const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Alike',
      );

  // ── Champ texte avec couleur d'écriture 0xFF004E7A ─────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: "   $hint",
      hintStyle: const TextStyle(
        fontFamily: 'Alike',
        color: Color(0xFF004E7A),
      ),
      filled: true,
      fillColor: const Color(0xFFC2E9FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(70),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }

  Widget _buildDragHandle() => Center(
        child: Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Logo animé
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: MediaQuery.of(context).size.height * 0.3 + _logoOffset,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 180, height: 180),
                const Text(
                  "SyndiControl",
                  style: TextStyle(
                    fontFamily: 'Alike',
                    fontSize: 22,
                    color: Color(0xFF004E7A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Sheet glissante
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.65,
            builder: (context, scrollController) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_sheetController.isAttached) {
                  _sheetController.animateTo(
                    0.65,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF004E7A),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildAuthForm(scrollController),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildDragHandle(),
        const SizedBox(height: 30),
        Center(child: Text("Inscription", style: _titleStyle)),
        const SizedBox(height: 5),
        Center(child: Text("Créez votre compte", style: _subtitleStyle)),
        const SizedBox(height: 40),

        // ── Email ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            // ← couleur du texte saisi
            style: const TextStyle(
                color: Color(0xFF004E7A), fontFamily: 'Alike'),
            decoration: _inputDecoration("Email"),
          ),
        ),
        const SizedBox(height: 15),

        // ── Mot de passe ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(
                color: Color(0xFF004E7A), fontFamily: 'Alike'),
            decoration: _inputDecoration("Mot de passe").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF004E7A),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // ── Confirmer mot de passe ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(
                color: Color(0xFF004E7A), fontFamily: 'Alike'),
            decoration:
                _inputDecoration("Confirmer mot de passe").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF004E7A),
                ),
                onPressed: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),

        // ── Bouton S'inscrire ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _performSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2E9FF),
              foregroundColor: const Color(0xFF004E7A),
              shape: const StadiumBorder(),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF004E7A),
                    ),
                  )
                : const Text("S'inscrire",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 20),

        // ── Lien vers login ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous avez déjà un compte ? ",
                style: _subtitleStyle),
            GestureDetector(
              onTap: _goToLogin,
              child: Text(
                "Se connecter",
                style: _subtitleStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  TOAST TYPE
// ══════════════════════════════════════════════════════════════════
enum _ToastType { success, error, warning, info }

// ══════════════════════════════════════════════════════════════════
//  TOAST WIDGET (identique LoginScreen)
// ══════════════════════════════════════════════════════════════════
class _ToastWidget extends StatefulWidget {
  final String message;
  final _ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

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
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.type) {
      case _ToastType.success: return const Color.fromARGB(255, 34, 173, 55);
      case _ToastType.error:   return const Color(0xFFDC2626);
      case _ToastType.warning: return const Color(0xFFF59E0B);
      case _ToastType.info:    return const Color(0xFF3B82F6);
    }
  }

  Color get _iconBgColor => Colors.white.withOpacity(0.15);

  IconData get _icon {
    switch (widget.type) {
      case _ToastType.success: return Icons.check_circle_rounded;
      case _ToastType.error:   return Icons.error_rounded;
      case _ToastType.warning: return Icons.warning_amber_rounded;
      case _ToastType.info:    return Icons.info_rounded;
    }
  }

  String get _label {
    switch (widget.type) {
      case _ToastType.success: return "Succès";
      case _ToastType.error:   return "Erreur";
      case _ToastType.warning: return "Attention";
      case _ToastType.info:    return "Information";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
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
                boxShadow: [
                  BoxShadow(
                    color: _bgColor.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(children: [
                // Icône
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),

                // Texte
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(widget.message,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton fermer
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
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