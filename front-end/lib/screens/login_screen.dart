import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
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

 void _performLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    // Vérifie que les champs ne sont pas vides
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs")),
    );
    return;
  }

  try {
    final response = await AuthService.login(email, password);

    if (response.containsKey('accessToken')) {
      // Login réussi
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Login échoué
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Erreur inconnue")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de la connexion : $e")),
    );
  }
}


  void _goToSignup() {
    Navigator.pushNamed(context, '/signup');
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
          // Le logo et le titre avec animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: MediaQuery.of(context).size.height * 0.3 + _logoOffset,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 180, height: 180),
                const SizedBox(height: 0),
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
          
          // Fenêtre glissante
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.60,
            builder: (context, scrollController) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_sheetController.isAttached) {
                  _sheetController.animateTo(
                    0.60,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
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
        Center(child: Text("Connexion", style: _titleStyle)),
        const SizedBox(height: 5),
        Center(
          child: Text(
            "Veuillez vous connecter",
            style: _subtitleStyle,
          ),
        ),
        const SizedBox(height: 55),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _emailController,
            style: const TextStyle(color: Color(0xFF004E7A), fontFamily: 'Alike'),
            decoration: _inputDecoration("Email"),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Color(0xFF004E7A), fontFamily: 'Alike'),
            decoration: _inputDecoration("Mot de passe").copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF004E7A),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Mot de passe oublié ?",
              style: _subtitleStyle,
            ),
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          child: ElevatedButton(
            onPressed: _performLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2E9FF),
              foregroundColor: const Color(0xFF004E7A),
              shape: const StadiumBorder(),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            child: const Text("Connexion",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Vous n'avez pas de compte ? ",
              style: _subtitleStyle,
            ),
            GestureDetector(
              onTap: _goToSignup,
              child: Text(
                "S'inscrire",
                style: _subtitleStyle.copyWith(
                    fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}