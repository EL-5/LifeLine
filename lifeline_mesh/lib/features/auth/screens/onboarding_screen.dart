import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final _storage = const FlutterSecureStorage();

  final List<Map<String, dynamic>> _pages = [
    {
      'title': '1. Tap for Help',
      'subtitle': 'In any medical emergency, just tap the SOS button. We\'ll handle the rest.',
      'icon': Icons.warning_rounded,
      'color': AppColors.emergencyRed,
    },
    {
      'title': '2. Fast Ambulances',
      'subtitle': 'The closest ambulance drivers receive your exact location and are instantly routed to you.',
      'icon': Icons.local_shipping_rounded,
      'color': AppColors.trustBlue,
    },
    {
      'title': '3. Hospitals Prepared',
      'subtitle': 'We automatically send your critical medical details to the hospital before you even arrive.',
      'icon': Icons.local_hospital_rounded,
      'color': AppColors.successGreen,
    },
    {
      'title': '4. Family Wallets',
      'subtitle': 'Add your family members and share a joint emergency fund so loved ones are always protected.',
      'icon': Icons.family_restroom_rounded,
      'color': Colors.orange,
    },
    {
      'title': '5. Community Backing',
      'subtitle': 'Join campaigns to help fund medical care for your neighbors. Together, we save lives.',
      'icon': Icons.volunteer_activism_rounded,
      'color': Colors.purple,
    },
  ];

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
    if (mounted) {
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: page['color'].withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page['icon'],
                          size: 100,
                          color: page['color'],
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 48),
                      Text(
                        page['title'],
                        style: AppTextStyles.displayMedium,
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      const SizedBox(height: 16),
                      Text(
                        page['subtitle'],
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Navigation controls
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index 
                            ? AppColors.trustBlue 
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                // Next / Get Started button
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.trustBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    _currentIndex == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ).animate(target: _currentIndex == _pages.length - 1 ? 1 : 0)
                 .shimmer(duration: 1000.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
