import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  ThemeMode _selectedTheme = ThemeMode.system;

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Welcome to ClassMate',
      description: 'Track your attendance, deadlines, and more with ease.',
      imageAsset: 'assets/images/app_icon.png',
    ),
    _OnboardingSlide(
      title: 'Stay Organized',
      description: 'Manage your courses, assignments, and schedule in one place.',
      imageAsset: 'assets/images/app_icon.png',
    ),
    _OnboardingSlide(
      title: 'Analytics & Insights',
      description: 'Get insights on your attendance and academic progress.',
      imageAsset: 'assets/images/app_icon.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final totalSlides = _slides.length + 2; // +1 for theme, +1 for name
    if (_currentPage < totalSlides - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _skip() {
    _pageController.animateToPage(_slides.length, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your full name')));
      return;
    }
    setState(() { _isSaving = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setBool('onboarding_complete', true);
    setState(() { _isSaving = false; });
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final totalSlides = _slides.length + 2; // +1 for theme, +1 for name
        final isLastPage = _currentPage == totalSlides - 1;
        return Scaffold(
          backgroundColor: themeProvider.themeMode == ThemeMode.dark
              ? AppTheme.darkBackgroundColor
              : AppTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: totalSlides,
                    onPageChanged: (index) {
                      setState(() { _currentPage = index; });
                    },
                    itemBuilder: (context, index) {
                      if (index < _slides.length) {
                        final slide = _slides[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(slide.imageAsset, height: 180),
                              const SizedBox(height: 40),
                              Text(
                                slide.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                slide.description,
                                style: GoogleFonts.lexend(
                                  fontSize: 18,
                                  color: themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (index == _slides.length) {
                        // Theme selection slide
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.color_lens, size: 100, color: AppTheme.primaryColor),
                              const SizedBox(height: 32),
                              Text(
                                'Choose Your App Theme',
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Pick a theme that suits your style. You can always change this later in settings.',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  color: themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _themeOptionButton(context, themeProvider, ThemeMode.light, 'Light', Icons.wb_sunny),
                                  const SizedBox(width: 16),
                                  _themeOptionButton(context, themeProvider, ThemeMode.dark, 'Dark', Icons.nightlight_round),
                                  const SizedBox(width: 16),
                                  _themeOptionButton(context, themeProvider, ThemeMode.system, 'System', Icons.phone_android),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Name input slide
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/app_icon.png', height: 120),
                              const SizedBox(height: 32),
                              Text(
                                "Let's get to know you!",
                                style: GoogleFonts.outfit(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Enter your full name to personalize your experience.',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  color: themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  labelStyle: TextStyle(
                                    color: themeProvider.themeMode == ThemeMode.dark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor: themeProvider.themeMode == ThemeMode.dark
                                      ? AppTheme.darkCardColor
                                      : Colors.white,
                                ),
                                style: TextStyle(
                                  color: themeProvider.themeMode == ThemeMode.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isLastPage)
                        TextButton(
                          onPressed: _skip,
                          child: const Text('Skip'),
                        ),
                      Row(
                        children: List.generate(totalSlides, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppTheme.primaryColor : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      if (!isLastPage)
                        ElevatedButton(
                          onPressed: () => _nextPage(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Next'),
                        ),
                      if (isLastPage)
                        ElevatedButton(
                          onPressed: _isSaving ? null : _finishOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Get Started'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOptionButton(BuildContext context, ThemeProvider themeProvider, ThemeMode mode, String label, IconData icon) {
    final isSelected = themeProvider.themeMode == mode;
    return GestureDetector(
      onTap: () {
        themeProvider.setThemeMode(mode);
        setState(() {
          _selectedTheme = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lexend(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String imageAsset;
  const _OnboardingSlide({required this.title, required this.description, required this.imageAsset});
} 