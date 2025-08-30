import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/features/presentation/provider/auth/auth_provider.dart';
import 'package:usbdataftptest/features/presentation/provider/auth/get_sys_info_file_management.dart';
import 'homescreen.dart';
import 'recordingscreen.dart';
import '../provider/home_provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  int _selectedIndex = 0;
  late String baseUrl;
  late String? token;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    initialized(context);
  }

  Future<void> initialized(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final getSysInfoFileManagement = context.read<GetSysInfoFileManagement>();
    baseUrl = authProvider.baseUrl;
    token = await authProvider.getAuthToken();
    getSysInfoFileManagement.connectToSysInfoStream(
      baseUrl: baseUrl,
      token: token!,
    );
     _fetchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Call your method here
      getSysInfoFileManagement.fetchIpCameras(
        baseUrl: baseUrl,
        token: token!
      );
    });
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<StartUpAppProvider>();

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Consumer<StartUpAppProvider>(
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
        child: _selectedIndex == 0
            ? HomeScreen(loginProvider: loginProvider)
            : Recordingscreen(),
        // child: IndexedStack(
        //   index: _selectedIndex,
        //   children: [
        //     HomeScreen(loginProvider: loginProvider),
        //     Recordingscreen(),
        //   ],
        // ),
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
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder),
            label: 'Recordings',
          ),
        ],
      ),
    );
  }
}
