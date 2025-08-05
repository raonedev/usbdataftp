import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/features/presentation/screens/homescreen.dart';
import 'package:usbdataftptest/features/presentation/screens/recordingscreen.dart';
import '../provider/login_provider.dart';


class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _hasNavigatedToLogin = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<LoginProvider>().checkingTempData();
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          // // Check if mobile tethering IP is NOT found AND we haven't navigated yet.
          // if (!loginProvider.isMobileTetheringIpFound && !_hasNavigatedToLogin) {
          //   // Set the flag to true IMMEDIATELY before scheduling the navigation.
          //   // This is crucial to prevent re-triggering during subsequent rebuilds
          //   // before the navigation actually completes.
          //   _hasNavigatedToLogin = true;

          //   // Use addPostFrameCallback to ensure navigation happens after the current
          //   // build phase is complete, preventing errors.
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     // Ensure the widget is still in the tree before attempting navigation.
          //     if (mounted) {
          //       Navigator.pushReplacement(
          //         context,
          //         MaterialPageRoute(builder: (_) => const LoginScreen()),
          //       );
          //     }
          //   });
          // }
          return child!;
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(loginProvider: loginProvider),
            Recordingscreen(),
            // Center(child: Text("Setting screen")),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Recordings',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}

