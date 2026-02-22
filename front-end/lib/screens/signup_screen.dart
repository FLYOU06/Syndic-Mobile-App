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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _logoOffset = 0.0;

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

      setState(() {
        _logoOffset = offset;
      });
    }
  }

  // ✅ CORRECTION ICI
void _performSignup() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs")),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
    );
    return;
  }

  try {
    final response = await AuthService.signup(email, password);

    if (response['message'] == "User created") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie !")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Erreur inconnue")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de l'inscription : $e")),
    );
  }
}


  void _goToLogin() {
    Navigator.pop(context);
  }

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.60,
            builder: (context, scrollController) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _sheetController.animateTo(
                  0.60,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF004E7A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
        const SizedBox(height: 55),

        // Email
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _emailController,
            decoration: _inputDecoration("Email"),
          ),
        ),

        const SizedBox(height: 15),

        // Password
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration("Mot de passe").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Confirm Password
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _inputDecoration("Confirmer mot de passe").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Button Signup
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: ElevatedButton(
            onPressed: _performSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2E9FF),
              foregroundColor: const Color(0xFF004E7A),
              shape: const StadiumBorder(),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("S'inscrire"),
          ),
        ),

        const SizedBox(height: 20),

        // Go Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous avez déjà un compte ? ", style: _subtitleStyle),
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
      ],
    );
  }
}
