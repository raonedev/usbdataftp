import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/providers/ftpconnection_provider.dart';
import 'package:usbdataftptest/vmsui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<FtpConnectionProvider>(
            create: (_) => FtpConnectionProvider(),
          ),
        ],
        child: const DashBoardScreen(),
      ),
    );
  }
}
