import 'package:bierdygame/app/modules/welcome/welcome_screen.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  int get totalPages => onboardingList.length;

  final List<OnboardingModel> onboardingList = [
    OnboardingModel(
      image: 'assets/images/onBoarding_welcome.png',
      title: 'Welcome to Birdie',
      description:
          'Real-time birdie scoring for your golf games.\n Track your progress instantly, anywhere.',
    ),
    OnboardingModel(
      image: 'assets/images/onBoarding_scoring.png',
      title: 'Track Your Scores',
      description:
          "Mark birdies hole by hole and see the entire \ngame live across all player's devices..",
    ),
    OnboardingModel(
      image: 'assets/images/onBoarding_instants.png',
      title: 'Instant Rankings',
      description:
          'Track team and individual rankings automatically.\n No confusion, just fun competition.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // PAGE VIEW
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _buildPage(context, model: onboardingList[index]);
              },
            ),
          ),

          // DOT INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => _dot(isActive: index == currentIndex),
            ),
          ),

          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50, bottom: 84),
            child: CustomElevatedButton(
              onPressed: () {
                if (currentIndex < totalPages - 1) {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Get.to(() => WelcomeView());
                }
              },
              btnName: "",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentIndex == totalPages - 1 ? 'Get Started' : 'Next →',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SINGLE REUSABLE PAGE
  Widget _buildPage(BuildContext context, {required OnboardingModel model}) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          child: Image.asset(
            model.image,
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        const SizedBox(height: 74),

        Text(
          model.title,
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            model.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }

  // DOT WIDGET
  Widget _dot({bool isActive = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 18 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E8E3E) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}
