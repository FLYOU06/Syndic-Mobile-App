import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SyndiControl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Alike',
        scaffoldBackgroundColor: const Color(0xFFC2E9FF),
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetController;
  late PageController _pageController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLogin = true;
  bool _showAuthForm = false;
  int _currentPage = 0;
  double _logoOffset = 0.0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/logo2.png',
      'text': "Bienvenue dans votre espace de gestion ! Chaque tâche devient plus simple et chaque copropriété mérite une gestion claire et efficace.",
      'width': 300.0,
      'height': 200.0,
    },
    {
      'image': 'assets/logo3.png',
      'text': "Avec SyndiControl, la gestion de votre copropriété devient intuitive et transparente : communiquez facilement avec les copropriétaires.",
      'width': 400.0,
      'height': 200.0,
    },
    {
      'image': 'assets/logo5.png',
      'text': "Le tout depuis une seule application pratique et sécurisée. Cliquez sur Suivant pour vous connecter.",
      'width': 200.0,
      'height': 200.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _pageController = PageController();
    
    // Écouter les changements de position de la fenêtre glissante
    _sheetController.addListener(_updateLogoPosition);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_updateLogoPosition);
    _sheetController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateLogoPosition() {
    if (_sheetController.isAttached) {
      final currentSize = _sheetController.size;
      // Calculer le déplacement du logo en fonction de la position de la fenêtre
      // Lorsque la fenêtre est tout en bas (0.12), le logo est centré
      // Lorsque la fenêtre monte, le logo monte aussi
      double offset = 0.0;
      
      if (currentSize < 0.5) {
        // Entre 0.12 et 0.3 : le logo descend légèrement
        offset = (currentSize - 0.12) * -50;
      } else if (currentSize < 0.6) {
        // Entre 0.3 et 0.6 : le logo monte progressivement
        offset = ((currentSize - 0.3) / 0.3) * -150 - 50;
      } else {
        // Au-dessus de 0.6 : le logo reste en haut
        offset = -150;
      }
      
      setState(() {
        _logoOffset = offset;
      });
    }
  }

  void _showAuthFormScreen() async {
    setState(() {
      _showAuthForm = true;
      _isLogin = true;
    });

    if (_sheetController.isAttached) {
      await _sheetController.animateTo(
        0.60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _performLogin() => Navigator.pushNamed(context, '/home');
  void _performSignup() => Navigator.pushNamed(context, '/home');

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
            maxChildSize: _showAuthForm ? 0.60 : 1.0,
            builder: (context, scrollController) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_sheetController.isAttached && !_showAuthForm) {
                  _sheetController.animateTo(
                    1.0,
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
                child: _showAuthForm
                    ? _buildAuthForm(scrollController)
                    : _buildOnboarding(scrollController),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboarding(ScrollController scrollController) {
    return Column(
      children: [
        const SizedBox(height: 5),
        _buildDragHandle(),
        const SizedBox(height: 5),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 140),
                  Center(
                    child: Image.asset(
                      page['image'],
                      width: page['width'],
                      height: page['height'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      page['text'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                        fontFamily: 'Alike',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPageIndicator(),
                  const SizedBox(height: 25),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          _showAuthFormScreen();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC2E9FF),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? "Suivant"
                            : "Se connecter",
                        style: const TextStyle(
                          color: Color(0xFF004E7A),
                          fontSize: 16,
                          fontFamily: 'Alike',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentPage ? 26 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(i == _currentPage ? 1 : 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
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

  Widget _buildAuthForm(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        _buildDragHandle(),
        const SizedBox(height: 30),
        Center(child: Text(_isLogin ? "Connexion" : "Inscription", style: _titleStyle)),
        const SizedBox(height: 5),
        Center(
          child: Text(
            _isLogin ? "Veuillez vous connecter" : "Créez votre compte",
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
        if (!_isLogin) ...[
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              obscureText: _obscurePassword,
              style: const TextStyle(color: Color(0xFF004E7A), fontFamily: 'Alike'),
              decoration: _inputDecoration("Confirmer mot de passe"),
            ),
          ),
          const SizedBox(height: 15),
        ],
        if (_isLogin)
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
            onPressed: _isLogin ? _performLogin : _performSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2E9FF),
              foregroundColor: const Color(0xFF004E7A),
              shape: const StadiumBorder(),
              minimumSize: const Size(double.infinity, 50),
              elevation: 0,
            ),
            child: Text(_isLogin ? "Connexion" : "S'inscrire",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "Vous n'avez pas de compte ? " : "Vous avez déjà un compte ? ",
              style: _subtitleStyle,
            ),
            GestureDetector(
              onTap: _toggleAuthMode,
              child: Text(
                _isLogin ? "S'inscrire" : "Se connecter",
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