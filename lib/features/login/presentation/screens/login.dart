import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/commom/widgets/my_elevatedbutton.dart';
import 'package:usbdataftptest/features/login/presentation/provider/login_provider.dart';
import 'package:usbdataftptest/helper.dart';

import '../../../../vmsui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LoginProvider>().initialized();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    // Listen to loginState only
    final loginState = context.select<LoginProvider, LoginState>(
      (provider) => provider.loginState,
    );

    // Navigate after build completes
    if (loginState == LoginState.loginSucess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashBoardScreen()),
        );
      });
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600; // or some threshold
              return isWide
                  ? LandScapeView(loginProvider: loginProvider)
                  : PortraitView(loginProvider: loginProvider);
            },
          ),
        ),
      ),
    );
  }
}

class PortraitView extends StatelessWidget {
  const PortraitView({super.key, required this.loginProvider});

  final LoginProvider loginProvider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
                top: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomSteps(
                        indicator: loginProvider.isUsbTethering
                            ? const Icon(Icons.check, size: 12)
                            : const CupertinoActivityIndicator(radius: 6),
                        title: Text(
                          " Usb  ",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        indicatorColor: loginProvider.isUsbTethering
                            ? Colors.green
                            : Colors.white,
                        indicatorBorderColor: loginProvider.isUsbTethering
                            ? Colors.black
                            : Colors.red,
                      ),
                      const Expanded(child: Divider()),
                      CustomSteps(
                        indicator: loginProvider.isMobileTetheringIpFound
                            ? const Icon(Icons.check, size: 12)
                            : const Icon(
                                Icons.error_rounded,
                                size: 12,
                                color: Colors.red,
                              ),
                        title: Text(
                          "Tethering",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        indicatorColor: loginProvider.isMobileTetheringIpFound
                            ? Colors.green
                            : Colors.white,
                        indicatorBorderColor:
                            loginProvider.isMobileTetheringIpFound
                            ? Colors.black
                            : Colors.red,
                      ),
                      const Expanded(child: Divider()),
                      CustomSteps(
                        indicator: loginProvider.isDeviceTethering
                            ? const Icon(Icons.check, size: 12)
                            : loginProvider.isUsbTethering
                            ? const CupertinoActivityIndicator(
                                radius: 6,
                                color: Colors.black,
                              )
                            : const Icon(
                                Icons.error_rounded,
                                size: 12,
                                color: Colors.red,
                              ),
                        title: Text(
                          "Device detect",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        indicatorColor: loginProvider.isDeviceTethering
                            ? Colors.green
                            : Colors.white,
                        indicatorBorderColor: loginProvider.isUsbTethering
                            ? Colors.black
                            : Colors.red,
                      ),
                      const Expanded(child: Divider()),
                      CustomSteps(
                        indicator: loginProvider.isFTPConnected
                            ? const Icon(Icons.check, size: 12)
                            : const Icon(
                                Icons.error_rounded,
                                size: 12,
                                color: Colors.red,
                              ),
                        title: Text(
                          "FTP",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        indicatorColor: loginProvider.isFTPConnected
                            ? Colors.green
                            : Colors.white,
                        indicatorBorderColor: loginProvider.isFTPConnected
                            ? Colors.black
                            : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!loginProvider.isUsbTethering)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Step 1: Connect android with device via USB\nStep 2: Enable Usb Tethering by Click on "Turn on" button\nStep 3: Find USB Tethering and TURN ON',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            openUsbTetherSettings();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.grey[100],
                          ),
                          child: Text(
                            "Turn on",
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                  if (loginProvider.isUsbTethering &&
                      !loginProvider.isDeviceTethering)
                    Text(
                      'Authenticating & Searching Device \nIt generaly take less than 1 minutes and only once.',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.black54),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kToolbarHeight),
          Card(
            child: Padding(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                children: [
                  Text(
                    "Login",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: loginProvider.usernameController,
                    decoration: InputDecoration(
                      hintText: "Enter Username",
                      hintStyle: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: loginProvider.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter Password",
                      hintStyle: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyElevatedButton(
                    width: double.infinity,
                    height: 45,
                    onPressed: loginProvider.loginState == LoginState.loading
                        ? null
                        : () {
                            if (!loginProvider.isFTPConnected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("FTP is not connected")),
                              );
                            } else {
                              loginProvider.loginSubmit();
                            }
                          },
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: loginProvider.loginState == LoginState.loading
                        ? Transform.scale(
                            scale: 0.7,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Submit",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LandScapeView extends StatelessWidget {
  const LandScapeView({super.key, required this.loginProvider});

  final LoginProvider loginProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vertical Stepper on the left
        SizedBox(
          width: 120,
          child: Card(child: CustomVerticalSteps(loginProvider: loginProvider)),
        ),
        const SizedBox(width: 16),
        // Login content on the right
        Expanded(
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: loginProvider.usernameController,
                      decoration: InputDecoration(
                        hintText: "Enter Username",
                        hintStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: loginProvider.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        hintStyle: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MyElevatedButton(
                      width: double.infinity,
                      height: 45,
                      onPressed: loginProvider.loginState == LoginState.loading
                          ? null
                          : () {
                              if (!loginProvider.isFTPConnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("FTP is not connected"),
                                  ),
                                );
                              } else {
                                loginProvider.loginSubmit();
                              }
                            },
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      child: loginProvider.loginState == LoginState.loading
                          ? Transform.scale(
                              scale: 0.7,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Submit",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),

                    const SizedBox(height: 20),
                    if (!loginProvider.isUsbTethering)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Step 1: Connect android with device via USB\nStep 2: Enable Usb Tethering by Click on "Turn on" button\nStep 3: Find USB Tethering and TURN ON',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () {
                              openUsbTetherSettings();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.black12,
                            ),
                            child: Text(
                              "Turn on",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    if (loginProvider.isUsbTethering &&
                        !loginProvider.isDeviceTethering)
                      Text(
                        'Authenticating & Searching Device \nIt generaly take less than 1 minutes and only once.',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSteps extends StatelessWidget {
  const CustomSteps({
    super.key,
    required this.indicator,
    required this.title,
    this.indicatorColor = Colors.white,
    this.indicatorBorderColor = Colors.black,
    this.radius = 12,
  });

  final Widget indicator;
  final Widget title;
  final Color indicatorColor;
  final Color indicatorBorderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CircleAvatar(
          backgroundColor: indicatorBorderColor,
          maxRadius: radius,
          child: CircleAvatar(
            backgroundColor: indicatorColor,
            maxRadius: (radius - 1).abs(),
            child: Align(alignment: Alignment.center, child: indicator),
          ),
        ),
        const SizedBox(height: 6),
        title,
      ],
    );
  }
}

class CustomVerticalSteps extends StatelessWidget {
  final LoginProvider loginProvider;

  const CustomVerticalSteps({super.key, required this.loginProvider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSteps(
            indicator: loginProvider.isUsbTethering
                ? const Icon(Icons.check, size: 12)
                : const CupertinoActivityIndicator(radius: 6),
            title: Text("Usb", style: Theme.of(context).textTheme.labelLarge),
            indicatorColor: loginProvider.isUsbTethering
                ? Colors.green
                : Colors.white,
            indicatorBorderColor: loginProvider.isUsbTethering
                ? Colors.black
                : Colors.red,
          ),
          const SizedBox(
            height: 16,
            child: VerticalDivider(thickness: 2, color: Colors.grey),
          ),
          CustomSteps(
            indicator: loginProvider.isUsbTethering
                ? const Icon(Icons.check, size: 12)
                : const Icon(Icons.error_rounded, size: 12, color: Colors.red),
            title: Text(
              "Tethering",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            indicatorColor: loginProvider.isUsbTethering
                ? Colors.green
                : Colors.white,
            indicatorBorderColor: loginProvider.isUsbTethering
                ? Colors.black
                : Colors.red,
          ),
          const SizedBox(
            height: 16,
            child: VerticalDivider(thickness: 2, color: Colors.grey),
          ),
          CustomSteps(
            indicator: loginProvider.isDeviceTethering
                ? const Icon(Icons.check, size: 12)
                : loginProvider.isUsbTethering
                ? const CupertinoActivityIndicator(
                    radius: 6,
                    color: Colors.black,
                  )
                : const Icon(Icons.error_rounded, size: 12, color: Colors.red),
            title: Text(
              "Device detect",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            indicatorColor: loginProvider.isDeviceTethering
                ? Colors.green
                : Colors.white,
            indicatorBorderColor: loginProvider.isUsbTethering
                ? Colors.black
                : Colors.red,
          ),
          const SizedBox(
            height: 16,
            child: VerticalDivider(thickness: 2, color: Colors.grey),
          ),
          CustomSteps(
            indicator: loginProvider.isFTPConnected
                ? const Icon(Icons.check, size: 12)
                : const Icon(Icons.error_rounded, size: 12, color: Colors.red),
            title: Text("FTP", style: Theme.of(context).textTheme.labelLarge),
            indicatorColor: loginProvider.isFTPConnected
                ? Colors.green
                : Colors.white,
            indicatorBorderColor: loginProvider.isFTPConnected
                ? Colors.black
                : Colors.red,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
