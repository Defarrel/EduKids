import 'package:edukids_app/core/constant/colors.dart';
import 'package:edukids_app/core/constant/constants.dart';
import 'package:edukids_app/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        AppSize.init(context);
        return MaterialApp(
          title: 'EduKids',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
