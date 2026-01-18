import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

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
      home: const OnboardingScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetController;
  late PageController _pageController;

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

  void _goToLogin() {
    Navigator.pushNamed(context, '/login');
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
            maxChildSize: 1.0,
            builder: (context, scrollController) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_sheetController.isAttached) {
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
                child: _buildOnboarding(scrollController),
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
                          _goToLogin();
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
}
