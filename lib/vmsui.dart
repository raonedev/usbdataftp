import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'commom/widgets/gradient_progressbar.dart';
import 'features/login/presentation/provider/login_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'features/login/presentation/screens/login.dart';

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
            Center(child: Text("Np Recordings Found")),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_present_rounded),
            label: 'Recordings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.loginProvider});

  final LoginProvider loginProvider;

  @override
  Widget build(BuildContext context) {
    return context.watch<LoginProvider>().filedata == null
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Active\nCameras",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  loginProvider.filedata!.activeCamera
                                          ?.toString() ??
                                      '0',
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "In-Active\nCameras",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  loginProvider.filedata!.unactiveCamera
                                          ?.toString() ??
                                      '0',
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
                                TitleWidget(
                                  title: "Storage Usage",
                                  icon: FontAwesomeIcons.database,
                                  iconColor: Colors.blue,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle:
                                      "Total: ${loginProvider.filedata!.storage?.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                  trailingText:
                                      "${((loginProvider.filedata!.storage?.usage ?? 0) / (loginProvider.filedata!.storage?.totalGb ?? 1) * 100).toStringAsFixed(0)}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (loginProvider.filedata!.storage?.usage ??
                                          0) /
                                      (loginProvider
                                              .filedata!
                                              .storage
                                              ?.totalGb ??
                                          1),
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
                                TitleWidget(
                                  title: "RAM Usage",
                                  icon: FontAwesomeIcons.memory,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle:"Total: ${loginProvider.filedata!.ram?.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                  trailingText:"${loginProvider.filedata!.ram?.usage}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value: (loginProvider.filedata!.ram?.usage ??0)/100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// CPU Health with temperature
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
                                TitleWidget(
                                  title: "CPU Health",
                                  icon: FontAwesomeIcons.microchip,
                                  iconColor: Colors.purple,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle: "CPU Usage",
                                  trailingText:
                                      "${loginProvider.filedata!.cpu?.usage?.toStringAsFixed(0) ?? '0'}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (loginProvider.filedata!.cpu?.usage ??
                                          0) /
                                      100,
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Temperature",
                                  trailingText:
                                      "${loginProvider.filedata!.cpu?.temperatureCelsius?.toStringAsFixed(1) ?? '0'}°C",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// GPU Health with temperature
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
                                TitleWidget(
                                  title: "GPU Health",
                                  icon: FontAwesomeIcons.desktop,
                                  iconColor: Colors.teal,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle: "GPU Usage",
                                  trailingText:
                                      "${loginProvider.filedata!.gpu?.usage?.toStringAsFixed(0) ?? '0'}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (loginProvider.filedata!.gpu?.usage ??
                                          0) /
                                      100,
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Temperature",
                                  trailingText:
                                      "${loginProvider.filedata!.gpu?.temperatureCelsius?.toStringAsFixed(1) ?? '0'}°C",
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
                                TitleWidget(
                                  title: "IP Cameras",
                                  icon: FontAwesomeIcons.video,
                                  iconColor: Colors.green,
                                ),
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
                                      ...?loginProvider.filedata!.ipCameras
                                          ?.where(
                                            (camera) => camera.isActive == true,
                                          )
                                          .map(
                                            (camera) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      camera.name ?? 'Unknown',
                                                    ),
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
                                      ...?loginProvider.filedata!.ipCameras
                                          ?.where(
                                            (camera) => camera.isActive != true,
                                          )
                                          .map(
                                            (camera) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      camera.name ?? 'Unknown',
                                                    ),
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
                                TitleWidget(
                                  title: "Hard Disk Health",
                                  icon: FontAwesomeIcons.hardDrive,
                                  iconColor: Colors.orange,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Chart
                                      SizedBox(
                                        width: 110,
                                        height: 140,
                                        child: SfCircularChart(
                                          tooltipBehavior: TooltipBehavior(
                                            enable: true,
                                            builder:
                                                (
                                                  dynamic data,
                                                  dynamic point,
                                                  dynamic series,
                                                  int pointIndex,
                                                  int seriesIndex,
                                                ) {
                                                  final value = point.y
                                                      .toStringAsFixed(1);
                                                  return Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '$value%',
                                                      style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                },
                                            activationMode:
                                                ActivationMode.singleTap,
                                          ),
                                          series: <CircularSeries>[
                                            RadialBarSeries<ChartData, String>(
                                              dataSource:
                                                  loginProvider
                                                      .filedata!
                                                      .hardDisk
                                                      ?.asMap()
                                                      .entries
                                                      .map((entry) {
                                                        final disk =
                                                            entry.value;
                                                        return ChartData(
                                                          disk.name ??
                                                              'Unknown',
                                                          ((disk.usedGb ?? 0) /
                                                                  (disk.totalGb ??
                                                                      1) *
                                                                  100)
                                                              .clamp(0, 100),
                                                          disk.status ??
                                                              'Unknown',
                                                        );
                                                      })
                                                      .toList() ??
                                                  [],
                                              xValueMapper:
                                                  (ChartData data, _) => data.x,
                                              yValueMapper:
                                                  (ChartData data, _) => data.y,
                                              cornerStyle:
                                                  CornerStyle.bothCurve,
                                              gap: "5%",
                                              radius: '100%',
                                              innerRadius: '30%',
                                              pointColorMapper:
                                                  (ChartData data, _) =>
                                                      data.status == 'Healthy'
                                                      ? Colors.green
                                                      : Colors.red,
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                    isVisible: false,
                                                  ),
                                              maximumValue: 100,
                                            ),
                                          ],
                                          annotations:
                                              <CircularChartAnnotation>[],
                                        ),
                                      ),
                                      // Annotations outside and to the right
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children:
                                                loginProvider.filedata!.hardDisk
                                                    ?.asMap()
                                                    .entries
                                                    .map(
                                                      (entry) => Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 2,
                                                            ),
                                                        child: Text(
                                                          "${entry.value.name ?? 'Unknown'}: ${entry.value.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                entry
                                                                        .value
                                                                        .status ==
                                                                    'Healthy'
                                                                ? Colors.green
                                                                : Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList() ??
                                                [],
                                          ),
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

                      /// Storage Distribution
                      // Note: storageDistribution is not present in the new model.
                      // This section is commented out as it cannot be directly supported.
                      /*
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
                                    icon: FontAwesomeIcons.chartPie,
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: ListView(
                                      children: loginProvider.filedata!.storageDistribution.entries
                                          .map(
                                            (entry) => Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SubTitleWeidget(
                                                  subtitle: entry.key,
                                                  trailingText: "${entry.value}%",
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
                      */

                      /// Recording Status
                      // Note: recordingStatuses is not present in the new model.
                      // We can derive it from ipCameras' isRecording property.
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
                                  title: "Recordings",
                                  icon: FontAwesomeIcons.video,
                                  iconColor: Colors.red,
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    itemCount:
                                        loginProvider
                                            .filedata!
                                            .ipCameras
                                            ?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final camera = loginProvider
                                          .filedata!
                                          .ipCameras![index];
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                camera.name ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                camera.isRecording == true
                                                    ? "Recording"
                                                    : "Not Recording",
                                                style: TextStyle(
                                                  color:
                                                      camera.isRecording == true
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
                        height: 180,
                        width: 180,
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TitleWidget(
                                  title: "Network Status",
                                  icon: FontAwesomeIcons.wifi,
                                  iconColor: Colors.green,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle: "Upload Speed",
                                  trailingText:
                                      "${loginProvider.filedata!.network?.uploadSpeedMbps?.toStringAsFixed(1) ?? '0'} Mbps",
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Download Speed",
                                  trailingText:
                                      "${loginProvider.filedata!.network?.downloadSpeedMbps?.toStringAsFixed(1) ?? '0'} Mbps",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Audio Devices
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TitleWidget(
                                  title: "Audio Devices",
                                  icon: FontAwesomeIcons.microphone,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Total: ${loginProvider.filedata!.audioDevices?.total?.toString() ?? '0'}",
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: ListView(
                                    children:
                                        loginProvider
                                            .filedata!
                                            .audioDevices
                                            ?.devices
                                            ?.map(
                                              (device) => Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        device,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
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
                                            .toList() ??
                                        [],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Location
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TitleWidget(
                                  title: "Location",
                                  icon: FontAwesomeIcons.locationDot,
                                  iconColor: Colors.red,
                                ),
                                Spacer(),
                                SubTitleWeidget(
                                  subtitle: "City",
                                  trailingText:
                                      loginProvider.filedata!.location?.city ??
                                      'Unknown',
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Coordinates",
                                  trailingText:
                                      "${loginProvider.filedata!.location?.latitude?.toStringAsFixed(2) ?? '0'}, ${loginProvider.filedata!.location?.longitude?.toStringAsFixed(2) ?? '0'}",
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
          );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.status);
  final String x; // Disk name
  final double y; // Usage percentage
  final String status; // Disk status (e.g., 'Healthy')
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
            style: TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.title,
    this.icon,
    this.iconColor,
  });
  final String title;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          FaIcon(icon, color: iconColor ?? Colors.blue, size: 16),
          SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
