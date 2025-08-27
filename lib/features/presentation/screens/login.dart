import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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

    // // Perform an initial check AFTER registering the listener and starting initialized()
    // // Use addPostFrameCallback to ensure the first frame is built and context is ready for showDialog
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
    if (!startUpAppProvider.isFTPConnected && !isDialogShown) {
      isDialogShown = true;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: Consumer<StartUpAppProvider>(
              builder: (context, loginProvider, _) {
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
                            if (!loginProvider.isUsbTethering) ...[
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
                            if (loginProvider.isUsbTethering &&
                                !loginProvider.isDeviceTethering)
                              Text(
                                'Authenticating & Searching Device...\nIt generaly take less than 1 minute.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            if (loginProvider.ftpConnectionState ==
                                FtpConnectionState.loading)
                              Text('Recoznizing device...'),
                            if (loginProvider.ftpConnectionState ==
                                FtpConnectionState.failed)
                              Text(
                                'Failed to make connection\nRetrying...',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
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
    if (startUpAppProvider.isFTPConnected && isDialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
      isDialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProviderBuild = Provider.of<StartUpAppProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PortraitView(startAppProvider: loginProviderBuild),
          // child: LayoutBuilder(
          //   builder: (context, constraints) {
          //     bool isWide = constraints.maxWidth > 600;
          //     return isWide
          //         ? LandScapeView(loginProvider: loginProviderBuild)
          //         : ;
          //   },
          // ),
        ),
      ),
    );
  }
}

class PortraitView extends StatefulWidget {
  const PortraitView({super.key, required this.startAppProvider});

  final StartUpAppProvider startAppProvider;

  @override
  State<PortraitView> createState() => _PortraitViewState();
}

class _PortraitViewState extends State<PortraitView> {
  bool isHidePassword = true;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500.0, // Sets the maximum width to 300 pixels
        ),
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
                  controller: widget.startAppProvider.usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: "Enter Username",
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: widget.startAppProvider.passwordController,
                  obscureText: isHidePassword,
                  decoration: InputDecoration(
                    hintText: "Enter Password",
                    hintStyle: Theme.of(context).textTheme.labelMedium,
                    suffixIcon: IconButton(
                      icon: Icon(isHidePassword?Icons.visibility_off:Icons.visibility),
                      onPressed: () {
                        setState(
                          (){
                            isHidePassword=!isHidePassword;
                          }
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MyElevatedButton(
                  width: double.infinity,
                  height: 45,
                  onPressed:
                      widget.startAppProvider.loginState == LoginState.loading
                      ? null
                      : () async {
                          await widget.startAppProvider.loginSubmit();
                          if (widget.startAppProvider.loginState ==
                              LoginState.loginSuccess) {
                            if (!context.mounted) return;
                            widget.startAppProvider.checkingTempData();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DashBoardScreen(),
                              ),
                            );
                          }

                          // if (loginProvider.usernameController.text.isEmpty ||
                          //     loginProvider.passwordController.text.isEmpty) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(
                          //         "Please enter a valid credentials",
                          //       ),
                          //     ),
                          //   );
                          // } else if (!loginProvider.isFTPConnected) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     SnackBar(
                          //       content: Text(
                          //         "Please wait for making connection.",
                          //       ),
                          //     ),
                          //   );
                          // } else {
                          //   await loginProvider.loginSubmit();
                          //   if (loginProvider.loginState ==
                          //       LoginState.loginSucess) {
                          //     if (!context.mounted) return;
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (_) => DashBoardScreen(),
                          //       ),
                          //     );
                          //   } else if (loginProvider.loginState ==
                          //       LoginState.loginFailed) {
                          //     if (!context.mounted) return;
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         content: Text(
                          //           loginProvider.loginErrorMessage ??
                          //               "Something went wrong.",
                          //         ),
                          //       ),
                          //     );
                          //   }
                          // }
                        },
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: widget.startAppProvider.loginState == LoginState.loading
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
                const SizedBox(height: 8),
                if (widget.startAppProvider.loginState == LoginState.loginFailed &&
                    widget.startAppProvider.loginErrorMessage != null)
                  Text(
                    widget.startAppProvider.loginErrorMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/*
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
                          : () async {
                              // await loginProvider.loginSubmit();
                              // if (loginProvider.loginState ==
                              //     LoginState.loginSucess) {
                              //   if (!context.mounted) return;
                              //   Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (_) => DashBoardScreen(),
                              //     ),
                              //   );
                              // }
                              if (loginProvider
                                      .usernameController
                                      .text
                                      .isEmpty ||
                                  loginProvider
                                      .passwordController
                                      .text
                                      .isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please enter a valid credentials",
                                    ),
                                  ),
                                );
                              } else if (!loginProvider.isFTPConnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please wait for fetching data.",
                                    ),
                                  ),
                                );
                              } else {
                                await loginProvider.loginSubmit();
                                if (loginProvider.loginState ==
                                    LoginState.loginSucess) {
                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DashBoardScreen(),
                                    ),
                                  );
                                } else if (loginProvider.loginState ==
                                    LoginState.loginFailed) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        loginProvider.loginErrorMessage ??
                                            "Something went wrong.",
                                      ),
                                    ),
                                  );
                                }
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
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.black54),
                                children: [
                                  TextSpan(text: 'Step 1: Connect your '),
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
                          const SizedBox(width: 16),
                          AnimatedTurnOnButton(
                            onPressed: () => openUsbTetherSettings(),
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
              "Find Device",
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
            indicator:
                loginProvider.ftpConnectionState == FtpConnectionState.sucess
                ? const Icon(Icons.check, size: 12)
                : loginProvider.ftpConnectionState == FtpConnectionState.loading
                ? const CupertinoActivityIndicator(
                    radius: 6,
                    color: Colors.black,
                  )
                : const Icon(Icons.error_rounded, size: 12, color: Colors.red),
            title: Text(
              "Fetch health",
              style: Theme.of(context).textTheme.labelLarge,
            ),
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

*/

/*
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
                          "Find Device",
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
                        indicator:
                            loginProvider.ftpConnectionState ==
                                FtpConnectionState.sucess
                            ? const Icon(Icons.check, size: 12)
                            : loginProvider.ftpConnectionState ==
                                  FtpConnectionState.loading
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
                          "Fetch health",
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
                  const SizedBox(height: 12),

                  /// usb tethering is not ON .instruction for turn on usb Tethering
                  if (!loginProvider.isUsbTethering)
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.black54),
                              children: [
                                TextSpan(text: 'Step 1: Connect your '),
                                TextSpan(
                                  text: 'Android',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' to this system via'),
                                TextSpan(
                                  text: ' USB cable.\n',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: 'Step 2: Click on '),
                                TextSpan(
                                  text: '"Turn on"',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' button\n'),
                                TextSpan(text: 'Step 3: Find '),
                                TextSpan(
                                  text: 'USB Tethering',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' and switch it '),
                                TextSpan(
                                  text: 'ON',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        AnimatedTurnOnButton(
                          onPressed: () => openUsbTetherSettings(),
                        ),
                      ],
                    ),

                  // finding device ip
                  if (loginProvider.isUsbTethering &&
                      !loginProvider.isDeviceTethering)
                    Text(
                      'Authenticating & Searching Device \nIt generaly take less than 1 minutes and only once.',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.black54),
                    ),

                  /// ftp connection error
                  // if (loginProvider.ftpConnectionState ==
                  //         FtpConnectionState.fialed &&
                  //     loginProvider.ftpErrorMessage != null)
                  //   Text(
                  //     loginProvider.ftpErrorMessage!,
                  //     style: TextStyle(color: Colors.red),
                  //   ),
                ],
              ),
            ),
          ),
          const SizedBox(height: kToolbarHeight),
          
          */