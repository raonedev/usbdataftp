import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/features/presentation/provider/auth/auth_provider.dart';
import '../provider/home_provider.dart';
import '../../../core/helper.dart';
import '../../../commom/widgets/my_elevatedbutton.dart';
import '../../../commom/widgets/animate_button.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDialogShown = false;
  late StartUpAppProvider startUpAppProvider;

  @override
  void initState() {
    super.initState();
    startUpAppProvider = context.read<StartUpAppProvider>();
    // startUpAppProvider.addListener(_checkAndShowDialog);
    // startUpAppProvider.initialized();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkAndShowDialog();
    // });
  }

  ///df --output=used /dev/${diskName}* | tail -n 1
  @override
  void dispose() {
    startUpAppProvider.removeListener(_checkAndShowDialog);
    super.dispose();
  }

  void _checkAndShowDialog() {
    if (!startUpAppProvider.isUsbTethering && !startUpAppProvider.isDeviceTethering && !isDialogShown) {
      isDialogShown = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: Consumer<StartUpAppProvider>(
              builder: (context, startUpProvider, _) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              "assets/lottie/loading.json",
                              height: 120,
                              fit: BoxFit.fill,
                            ),
                            if (!startUpProvider.isUsbTethering) ...[
                              Text(
                                "Usb Tethering Not Found",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: Colors.black54),
                                        children: [
                                          TextSpan(
                                            text: 'Step 1: Connect your ',
                                          ),
                                          TextSpan(
                                            text: 'Android',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: ' to this system via'),
                                          TextSpan(
                                            text: ' USB cable.\n',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: 'Step 2: Click on '),
                                          TextSpan(
                                            text: '"Turn on"',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: ' button\n'),
                                          TextSpan(text: 'Step 3: Find '),
                                          TextSpan(
                                            text: 'USB Tethering',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(text: ' and switch it '),
                                          TextSpan(
                                            text: 'ON',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              AnimatedTurnOnButton(
                                // onPressed: () => openUsbTetherSettings(),
                                onPressed: () {
                                  openUsbTetherSettings();
                                  Navigator.pop(context);
                                  isDialogShown = false;
                                },
                              ),
                            ],
                            if (startUpProvider.isUsbTethering &&
                                !startUpProvider.isDeviceTethering)
                              Text(
                                'Authenticating & Searching Device...\nIt generaly take less than 1 minute.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            // if (loginProvider.ftpConnectionState == FtpConnectionState.loading)
                            //   Text('Recoznizing device...'),
                            // if (loginProvider.ftpConnectionState == FtpConnectionState.failed)
                            //   Text(
                            //     'Failed to make connection\nRetrying...',
                            //     textAlign: TextAlign.center,
                            //     style: Theme.of(context).textTheme.labelSmall
                            //         ?.copyWith(
                            //           color: Colors.red,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    // Auto-close dialog when FTP connects
    if (startUpAppProvider.isDeviceTethering && isDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      context.read<AuthProvider>().baseUrl ="http://${startUpAppProvider.deviceTetheringIP}:6742";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ip : ${context.read<AuthProvider>().baseUrl}")),
      );
      isDialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PortraitView(authProvider: authProvider),
        ),
      ),
    );
  }
}

class PortraitView extends StatefulWidget {
  const PortraitView({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<PortraitView> createState() => _PortraitViewState();
}

class _PortraitViewState extends State<PortraitView> {
  bool isHidePassword = true;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500.0),
        child: Card(
          child: Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Login",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Enter Username",
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: isHidePassword,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isHidePassword = !isHidePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MyElevatedButton(
                  width: double.infinity,
                  height: 45,
                  onPressed: widget.authProvider.isLoading
                      ? null
                      : () async {
                          if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please enter a valid credentials",
                                ),
                              ),
                            );
                          } 
                          // else if (!context
                          //     .read<StartUpAppProvider>()
                          //     .isDeviceTethering) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(
                          //         "Please wait for making connection.",
                          //       ),
                          //     ),
                          //   );
                          // } 
                          else {
                            try {
                              // await widget.authProvider.login(
                              //   context,
                              //   usernameController.text.trim(),
                              //   passwordController.text.trim(),
                              // );
                              await widget.authProvider.mockLogin(
                                usernameController.text.trim(),
                                passwordController.text.trim(),
                              );
                              if (widget.authProvider.isAuthenticated) {
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DashBoardScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              if(context.mounted){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                              }
                            }
                          }
                        },
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: widget.authProvider.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
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
                Text(
                  widget.authProvider.errorMessage
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
