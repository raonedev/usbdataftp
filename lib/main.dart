import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/features/presentation/provider/auth/auth_provider.dart';
import 'package:usbdataftptest/features/testing/system_info_provider.dart';
import 'core/apptheme.dart';
import 'features/presentation/provider/home_provider.dart';
import 'features/presentation/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StartUpAppProvider>(create: (_) => StartUpAppProvider()),
        ChangeNotifierProvider<SystemInfoProvider>(create: (_) => SystemInfoProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.lightTheme,
        darkTheme: ThemeConfig.darkTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1)),
            child: child!,
          );
        },
        home: const LoginScreen(),
      ),
    );
  }
}
