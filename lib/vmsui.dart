import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/features/login/presentation/screens/login.dart';
import 'commom/widgets/gradient_progressbar.dart';
import 'features/login/presentation/provider/login_provider.dart';
import 'helper.dart';
import 'providers/ftpconnection_provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  bool _hasShownDialog = false;
  bool _hasNavigatedToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          // Check if mobile tethering IP is NOT found AND we haven't navigated yet.
          if (!loginProvider.isMobileTetheringIpFound &&
              !_hasNavigatedToLogin) {
            // Set the flag to true IMMEDIATELY before scheduling the navigation.
            // This is crucial to prevent re-triggering during subsequent rebuilds
            // before the navigation actually completes.
            _hasNavigatedToLogin = true;

            // Use addPostFrameCallback to ensure navigation happens after the current
            // build phase is complete, preventing errors.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Ensure the widget is still in the tree before attempting navigation.
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            });
          }
          return child!;
        },
        child: Consumer<FtpConnectionProvider>(
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
              } else {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // Close previous if any
                }
              }
            }
            return child!;
          },
          child: context.watch<FtpConnectionProvider>().filedata == null
              ? Center(child: CupertinoActivityIndicator(color: Colors.black))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: [
                            /// Active Cameras
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Active\nCameras",
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

                            /// Inactive Cameras
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "In-Active\nCameras",
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

                            /// Storage Usage
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
                                      TitleWidget(title: "Storage Usage"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle:
                                            "Total: ${ftpConnectionProvider.filedata!.totalStorage.toStringAsFixed(0)}GB",
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

                            /// RAM Usage
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
                                      TitleWidget(title: "RAM Usage"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle:
                                            "Total: ${ftpConnectionProvider.filedata!.totalRam.toStringAsFixed(0)}GB",
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

                            /// CPU Health
                            SizedBox(
                              height: 140,
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
                                            "${ftpConnectionProvider.filedata!.cpuUsage}%",
                                      ),
                                      const SizedBox(height: 4),
                                      GradientProgressBar(
                                        value:
                                            ftpConnectionProvider
                                                .filedata!
                                                .cpuUsage /
                                            100,
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Temperature",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.cpuTemperatureCelsius}°C",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// GPU Health
                            SizedBox(
                              height: 140,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "GPU Health"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle: "GPU Usage",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.gpu.usage}%",
                                      ),
                                      const SizedBox(height: 4),
                                      GradientProgressBar(
                                        value:
                                            ftpConnectionProvider
                                                .filedata!
                                                .gpu
                                                .usage /
                                            100,
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Temperature",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.gpu.temperatureCelsius}°C",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// IP Cameras
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
                                      TitleWidget(title: "IP Cameras"),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            Text(
                                              "Active:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ...ftpConnectionProvider
                                                .filedata!
                                                .ipCamera
                                                .active
                                                .map(
                                                  (camera) => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(camera),
                                                          Icon(
                                                            Icons.videocam,
                                                            color: Colors.green,
                                                            size: 16,
                                                          ),
                                                        ],
                                                      ),
                                                      CustomDevider(),
                                                    ],
                                                  ),
                                                ),
                                            Text(
                                              "Inactive:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            ...ftpConnectionProvider
                                                .filedata!
                                                .ipCamera
                                                .inactive
                                                .map(
                                                  (camera) => Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(camera),
                                                          Icon(
                                                            Icons.videocam_off,
                                                            color: Colors.red,
                                                            size: 16,
                                                          ),
                                                        ],
                                                      ),
                                                      CustomDevider(),
                                                    ],
                                                  ),
                                                ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Hard Disk Health
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
                                            final disk = ftpConnectionProvider
                                                .filedata!
                                                .hardDisks[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(disk.name),
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text(
                                                        "${disk.status}\n(${disk.usedGb}/${disk.totalGb}GB)",
                                                        style: TextStyle(
                                                          color:
                                                              disk.status ==
                                                                  'Healthy'
                                                              ? Colors.green
                                                              : Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
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

                            /// Storage Distribution
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
                                      TitleWidget(
                                        title: "Storage Distribution",
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: ListView(
                                          children: ftpConnectionProvider
                                              .filedata!
                                              .storageDistribution
                                              .entries
                                              .map(
                                                (entry) => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(entry.key),
                                                        Text(
                                                          "${entry.value}GB",
                                                        ),
                                                      ],
                                                    ),
                                                    CustomDevider(),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Recording Status
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
                                            final status = ftpConnectionProvider
                                                .filedata!
                                                .recordingStatuses[index];
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(status.name),
                                                    Text(
                                                      status.status
                                                          ? "Recording"
                                                          : "Not Recording",
                                                      style: TextStyle(
                                                        color: status.status
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

                            /// Network Status
                            SizedBox(
                              height: 140,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "Network Status"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle: "Upload Speed",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.network.uploadSpeedMbps} Mbps",
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Download Speed",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.network.downloadSpeedMbps} Mbps",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Data Transfer
                            SizedBox(
                              height: 140,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "Data Transfer"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle: "Last 5 Min",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.dataTransfer.last5MinMb} MB",
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Last Hour",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.dataTransfer.last1HourMb} MB",
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Today",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.dataTransfer.totalTodayGb} GB",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Audio Devices
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
                                      TitleWidget(title: "Audio Devices"),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total: ${ftpConnectionProvider.filedata!.audioDevices.total}",
                                      ),
                                      const SizedBox(height: 4),
                                      Expanded(
                                        child: ListView(
                                          children: ftpConnectionProvider
                                              .filedata!
                                              .audioDevices
                                              .devices
                                              .map(
                                                (device) => Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(device),
                                                        Icon(
                                                          Icons.mic,
                                                          color: Colors.blue,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                                    CustomDevider(),
                                                  ],
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// Location
                            SizedBox(
                              height: 140,
                              width: 180,
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      TitleWidget(title: "Location"),
                                      Spacer(),
                                      SubTitleWeidget(
                                        subtitle: "City",
                                        trailingText: ftpConnectionProvider
                                            .filedata!
                                            .location
                                            .city,
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Country",
                                        trailingText: ftpConnectionProvider
                                            .filedata!
                                            .location
                                            .country,
                                      ),
                                      const SizedBox(height: 8),
                                      SubTitleWeidget(
                                        subtitle: "Coordinates",
                                        trailingText:
                                            "${ftpConnectionProvider.filedata!.location.latitude.toStringAsFixed(2)}, ${ftpConnectionProvider.filedata!.location.longitude.toStringAsFixed(2)}",
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
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_present_rounded),
            label: 'File',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
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
    return Flexible(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(subtitle, style: TextStyle(color: Colors.black, fontSize: 12)),
          Spacer(),
          Text(
            trailingText,
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
        ],
      ),
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
