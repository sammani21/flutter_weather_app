import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/onboarding_content.dart';
import '../components/onboarding_card.dart';
import '../components/onboarding_indicator.dart';
import '../components/primary_circle_button.dart';
import '../home_page.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  double _currentPageValue = 0.0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Track Hourly\nForecast',
      description: 'Access accurate hourly updates\nwith detailed insights.',
      image: 'assets/images/getStart1.png',
    ),
    OnboardingContent(
      title: 'Live Weather Map',
      description: 'Visualize rainfall and wind\nin real-time easily.',
      image: 'assets/images/getStart2.png',
    ),
    OnboardingContent(
      title: 'Global Locations',
      description: 'Add multiple cities & swipe\nbetween them smoothly.',
      image: 'assets/images/getStart3.png',
    ),
    OnboardingContent(
      title: 'Plan Confidently',
      description: 'Be ready for any weather\nwith advanced alerts.',
      image: 'assets/images/getStart4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85)
      ..addListener(() {
        setState(() {
          _currentPageValue = _pageController.page!;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topSectionHeight = size.height * 0.6;
    final bottomSectionHeight = size.height * 0.4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.backgroundGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Skip Button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: topSectionHeight,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    // Onboarding carousel
                    SizedBox(
                      height: topSectionHeight * 0.7,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _contents.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (_, index) {
                          double value =
                              (index - _currentPageValue).abs().clamp(0.0, 1.0);
                          double scale = 1 - (value * 0.2);
                          double translate = (1 - scale) * 50 * (index > _currentPageValue ? 1 : -1);

                          return OnboardingCard(
                            imagePath: _contents[index].image,
                            scaleValue: scale,
                            translateValue: translate,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    OnboardingIndicator(
                      length: _contents.length,
                      currentPage: _currentPage,
                    ),
                  ],
                ),
              ),
              // Bottom container
              Container(
                height: bottomSectionHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _contents[_currentPage].title,
                          key: ValueKey(_contents[_currentPage].title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _contents[_currentPage].description,
                          key: ValueKey(_contents[_currentPage].description),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textDark.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      PrimaryCircleButton(
                        progress: (_currentPage + 1) / _contents.length,
                        onPressed: () {
                          if (_currentPage == _contents.length - 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomePage(),
                              ),
                            );
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
