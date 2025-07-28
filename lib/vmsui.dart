import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/commom/widgets/gradient_progressbar.dart';
import 'package:usbdataftptest/features/login/presentation/provider/login_provider.dart';
import 'package:usbdataftptest/helper.dart';
import 'package:usbdataftptest/providers/ftpconnection_provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<FtpConnectionProvider>().poolingToKnowUSBStatus(context: context);
      context.read<FtpConnectionProvider>().checkingTempData();
    });
  }

  @override
  void dispose() {
    context.read<FtpConnectionProvider>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ftpConnectionProvider = context.watch<FtpConnectionProvider>();
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   title: Text(
      //     "Dashboard ${context.watch<FtpConnectionProvider>().count}",
      //   ),
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         // context.read<FtpConnectionProvider>().poolingToKnowUSBStatus();
      //         context.read<FtpConnectionProvider>().checkingTempData();
      //         // showCustomAlertDialog(
      //         //   context,
      //         //   title: "USB Tethering Not Enabled",
      //         //   message:
      //         //       "To continue, please:\n\n1. Connect your phone to the system using a USB cable.\n2. Open settings and enable USB Tethering under 'Hotspot & Tethering'.",
      //         //   confirmText: "Open Settings",
      //         //   onConfirm: () async {
      //         //     context
      //         //         .read<FtpConnectionProvider>()
      //         //         .poolingToKnowUSBStatus();
      //         //   },
      //         // );
      //       },
      //       icon: Icon(Icons.refresh_rounded),
      //     ),
      //   ],
      // ),
      body: Consumer<FtpConnectionProvider>(
        builder: (context, value, child) {
          if (value.isDialogVisible) {
            if (value.isDialogVisible && !_hasShownDialog) {
              _hasShownDialog = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Close previous if any
                }

                await showCustomAlertDialog(
                  context,
                  title: "USB Tethering Not Enabled",
                  message:
                      "To continue, please:\n\n1. Connect your phone to the system using a USB cable.\n2. Open settings and enable **USB Tethering** under 'Hotspot & Tethering'.",
                  confirmText: "Open Settings",
                  onConfirm: () async {
                    final ftpConnectionProvider = context
                        .read<FtpConnectionProvider>();
                    await openUsbTetherSettings();
                    ftpConnectionProvider.isDialogVisible = false;
                  },
                );

                // After dialog dismissed, reset flag and provider state
                _hasShownDialog = false;
                value.isDialogVisible = false;
              });
            }else{
              if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Close previous if any
                }

            }
          }
          return child!;
        },
        child: context.watch<FtpConnectionProvider>().filedata == null
            ? Center(child: CupertinoActivityIndicator(color: Colors.black))
            : Stack(
              children: [
                /// MAIN BODY
                SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            ///active camera
                            SizedBox(
                              height: 110,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Active\nCamera's",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        ftpConnectionProvider
                                            .filedata!
                                            .activeCamera
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                  
                            /// inactive camera
                            SizedBox(
                              height: 110,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "In-Active\nCamera's",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        ftpConnectionProvider
                                            .filedata!
                                            .unActiveCamera
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                  
                            /// cpu health
                            SizedBox(
                              height: 110,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "CPU Health"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle: "CPU Usage",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.cpuUsage} %",
                                      ),
                                      const SizedBox(height: 4),
                                      GradientProgressBar(
                                        value:
                                            ftpConnectionProvider
                                                .filedata!
                                                .cpuUsage /
                                            100,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                  
                            /// storage usage - RAM usage
                            Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 180,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          TitleWidget(title: "Storage Usage"),
                                          Spacer(),
                                          SubTitleWeidget(
                                            subtitle:
                                                "Total:${ftpConnectionProvider.filedata!.totalStorage.toStringAsFixed(0)}GB",
                                            trailingText:
                                                "${ftpConnectionProvider.filedata!.storageUsage}%",
                                          ),
                                          const SizedBox(height: 4),
                                          GradientProgressBar(
                                            value:
                                                ftpConnectionProvider
                                                    .filedata!
                                                    .storageUsage /
                                                100,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                  
                                SizedBox(
                                  height: 100,
                                  width: 180,
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          TitleWidget(title: "RAM Usage"),
                                          Spacer(),
                                          SubTitleWeidget(
                                            subtitle:
                                                "Total RAM ${ftpConnectionProvider.filedata!.totalRam.toStringAsFixed(0)}GB",
                                            trailingText:
                                                "${ftpConnectionProvider.filedata!.ramUsage}%",
                                          ),
                                           const SizedBox(height: 4),
                                          GradientProgressBar(
                                            value:
                                                ftpConnectionProvider
                                                    .filedata!
                                                    .ramUsage /
                                                100,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                                  
                            /// hardDisk
                            SizedBox(
                              width: 180,
                              height: 200,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "Hard Disk Health"),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: ftpConnectionProvider
                                              .filedata!
                                              .hardDisks
                                              .length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      ftpConnectionProvider
                                                          .filedata!
                                                          .hardDisks[index]
                                                          .name,
                                                    ),
                                                    Text(
                                                      ftpConnectionProvider
                                                          .filedata!
                                                          .hardDisks[index]
                                                          .status,
                                                      style: TextStyle(
                                                        color:
                                                            ftpConnectionProvider
                                                                    .filedata!
                                                                    .hardDisks[index]
                                                                    .status ==
                                                                'Healthy'
                                                            ? Colors.green
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                CustomDevider(),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                                  
                            /// cameras
                            SizedBox(
                              width: 180,
                              height: 200,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "Recording Status"),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: ftpConnectionProvider
                                              .filedata!
                                              .recordingStatuses
                                              .length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      ftpConnectionProvider
                                                          .filedata!
                                                          .recordingStatuses[index]
                                                          .name,
                                                    ),
                                                    Text(
                                                      ftpConnectionProvider
                                                              .filedata!
                                                              .recordingStatuses[index]
                                                              .status
                                                          ? "Recording"
                                                          : "Not Recording",
                                                      style: TextStyle(
                                                        color:
                                                            ftpConnectionProvider
                                                                .filedata!
                                                                .recordingStatuses[index]
                                                                .status
                                                            ? Colors.black
                                                            : Colors.red,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                  
                                                CustomDevider(),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                /// VMS version
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text("VMS version : ${ftpConnectionProvider.filedata!.vmsVersion}"),
                ),
              ],
            ),
        /* : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWidget(title: "Camera Status"),
                      Row(
                        spacing: 16,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 150,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Active",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        ftpConnectionProvider
                                            .filedata!
                                            .activeCamera
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 150,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "In-Active",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        ftpConnectionProvider
                                            .filedata!
                                            .unActiveCamera
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CustomDevider(),

                      // ElevatedButton(
                      //   onPressed: () {
                      //     showCustomAlertDialog(
                      //       context,
                      //       title: "mock parsing!",
                      //       message: ' moking parsing data',
                      //       onConfirm: () {
                      //         context.read<FtpConnectionProvider>().checkingTempData();
                      //       },
                      //       confirmText: "get Data",
                      //     );
                      //   },
                      //   child: Text("showDialog"),
                      // ),

                      /// ---------------- CPU UI starts here
                      TitleWidget(title: "CPU Health"),
                      SubTitleWeidget(
                        subtitle: "CPU Usage",
                        trailingText:
                            "${ftpConnectionProvider.filedata!.cpuUsage} %",
                      ),
                      GradientProgressBar(
                        value: ftpConnectionProvider.filedata!.cpuUsage / 100,
                      ),

                      SizedBox(height: 20),
                      CustomDevider(),

                      /// ---------------- STORAGE UI starts here
                      TitleWidget(title: "Storage Usage"),
                      SubTitleWeidget(
                        subtitle:
                            "Total Storage ${ftpConnectionProvider.filedata!.totalStorage.toStringAsFixed(0)}GB",
                        trailingText:
                            "${ftpConnectionProvider.filedata!.storageUsage}%",
                      ),
                      GradientProgressBar(
                        value:
                            ftpConnectionProvider.filedata!.storageUsage / 100,
                      ),

                      SizedBox(height: 20),
                      CustomDevider(),
                      TitleWidget(title: "Hard Disk Health"),
                      ...List.generate(
                        ftpConnectionProvider.filedata!.hardDisks.length,
                        (index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              ftpConnectionProvider
                                  .filedata!
                                  .hardDisks[index]
                                  .name,
                            ),
                            trailing: Text(
                              ftpConnectionProvider
                                  .filedata!
                                  .hardDisks[index]
                                  .status,
                              style: TextStyle(
                                color:
                                    ftpConnectionProvider
                                            .filedata!
                                            .hardDisks[index]
                                            .status ==
                                        'healthy'
                                    ? Colors.green
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      CustomDevider(),

                      /// ---------------- RAM UI starts here
                      TitleWidget(title: "RAM Usage"),
                      SubTitleWeidget(
                        subtitle:
                            "Total RAM ${ftpConnectionProvider.filedata!.totalRam.toStringAsFixed(0)}GB",
                        trailingText:
                            "${ftpConnectionProvider.filedata!.ramUsage}%",
                      ),
                      GradientProgressBar(
                        value: ftpConnectionProvider.filedata!.ramUsage / 100,
                      ),

                      // LinearProgressIndicator(
                      //   borderRadius: BorderRadius.circular(16),
                      //   backgroundColor: Colors.blueGrey.shade100,
                      //   color: Colors.blue,
                      //   value: ftpConnectionProvider.filedata!.ramUsage / 100,
                      //   minHeight: 10,
                      // ),
                      SizedBox(height: 20),
                      CustomDevider(),

                      /// ---------------- VMS version UI starts here
                      TitleWidget(title: "VMS Version"),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Version"),
                        trailing: Text(
                          ftpConnectionProvider.filedata!.vmsVersion,
                        ),
                      ),

                      SizedBox(height: 20),
                      CustomDevider(),

                      /// ---------------- Recording status UI starts here
                      TitleWidget(title: "Recording Status"),
                      ...List.generate(
                        ftpConnectionProvider
                            .filedata!
                            .recordingStatuses
                            .length,
                        (index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              ftpConnectionProvider
                                  .filedata!
                                  .recordingStatuses[index]
                                  .name,
                            ),
                            trailing: Text(
                              ftpConnectionProvider
                                      .filedata!
                                      .recordingStatuses[index]
                                      .status
                                  ? "Recording"
                                  : "Not Recording",
                              style: TextStyle(
                                color:
                                    ftpConnectionProvider
                                        .filedata!
                                        .recordingStatuses[index]
                                        .status
                                    ? Colors.black
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              */
      ),
    );
  }
}

class CustomDevider extends StatelessWidget {
  const CustomDevider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Color(0xFFF5F5F5),
      thickness: 2,
      radius: BorderRadius.circular(8),
    );
  }
}

class SubTitleWeidget extends StatelessWidget {
  const SubTitleWeidget({
    super.key,
    required this.subtitle,
    required this.trailingText,
  });

  final String subtitle;
  final String trailingText;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(subtitle, style: TextStyle(color: Colors.black, fontSize: 14)),
        Spacer(),
        Text(trailingText, style: TextStyle(color: Colors.black, fontSize: 14)),
      ],
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
