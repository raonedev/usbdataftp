import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../provider/auth/get_sys_info_file_management.dart';
import '../../../commom/widgets/gradient_progressbar.dart';
import '../provider/home_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.loginProvider});

  final StartUpAppProvider loginProvider;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return context.watch<GetSysInfoFileManagement>().systemInfoModel.isEmpty
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
                                  // loginProvider.filedata!.activeCamera?.toString() ??'0',
                                  "${context.watch<GetSysInfoFileManagement>().ipCameras?.cameras?.where((c) => c.isActive == true && c.deviceType?.toLowerCase() == "camera").length ?? 0}",
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
                                  // loginProvider.filedata!.unactiveCamera?.toString() ?? '0',
                                  "${context.watch<GetSysInfoFileManagement>().ipCameras?.cameras?.where((c) => c.isActive == false && c.deviceType?.toLowerCase() == "camera").length ?? 0}",
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
                                  // subtitle: "Total: ${loginProvider.filedata!.storage?.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                  // trailingText: "${((loginProvider.filedata!.storage?.usage ?? 0) / (loginProvider.filedata!.storage?.totalGb ?? 1) * 100).toStringAsFixed(0)}%",
                                  subtitle:
                                      "Total: ${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].storage?.totalGb ?? 0}",
                                  trailingText:
                                      "${((context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].storage?.usedGb ?? 0) / (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].storage?.totalGb ?? 1) * 100).toStringAsFixed(0)}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                                  1]
                                              .storage
                                              ?.usedGb ??
                                          0) /
                                      (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                                  1]
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
                                SizedBox(
                                  height: 25,
                                  width: 200,
                                  child: _buildLineChart(
                                    context.watch<GetSysInfoFileManagement>().systemInfoModel
                                        .map(
                                          (info) =>
                                              info.ram?.usagePercentage ?? 0.0,
                                        ) // fallback to 0 if null
                                        .toList(),
                                    Colors.blue,
                                    maxY: 100,
                                  ),
                                ),
                                // SubTitleWeidget(
                                //   // subtitle:"Total: ${loginProvider.filedata!.ram?.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                //   // trailingText:"${loginProvider.filedata!.ram?.usage}%",
                                //   subtitle:"Total: ${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length-1].ram?.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                //   trailingText:"${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length-1].ram?.usagePercentage?.toStringAsFixed(2)}%",

                                // ),
                                // const SizedBox(height: 4),
                                // GradientProgressBar(
                                //   value: (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length-1].ram?.usagePercentage ??0) /100,
                                // ),
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
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].cpu?.usagePercent?.toStringAsFixed(0) ?? '0'}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                                  1]
                                              .cpu
                                              ?.usagePercent ??
                                          0) /
                                      100,
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Temperature",
                                  trailingText:
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].cpu?.temperatureCelsius?.toStringAsFixed(1) ?? '0'}°C",
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
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].gpu?.usagePercent?.toStringAsFixed(0) ?? '0'}%",
                                ),
                                const SizedBox(height: 4),
                                GradientProgressBar(
                                  value:
                                      (context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                                  1]
                                              .gpu
                                              ?.usagePercent ??
                                          0) /
                                      100,
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Temperature",
                                  trailingText:
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].gpu?.temperatureCelsius?.toStringAsFixed(1) ?? '0'}°C",
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
                                      // ...?loginProvider.filedata!.ipCameras
                                      ...?context.watch<GetSysInfoFileManagement>().ipCameras?.cameras
                                          ?.where(
                                            (camera) =>
                                                camera.isActive == true &&
                                                camera.deviceType?.toLowerCase() == "camera",
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
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
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
                                      // ...?loginProvider.filedata!.ipCameras
                                      ...?context.watch<GetSysInfoFileManagement>().ipCameras?.cameras
                                          ?.where(
                                            (camera) =>
                                                camera.isActive != true &&
                                                camera.deviceType?.toLowerCase() == "camera",
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
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelMedium,
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
                        child: Builder(
                          builder: (context) {
                            final TooltipBehavior
                            tooltipBehavior = TooltipBehavior(
                              duration: 800,
                              enable: true,
                              activationMode: ActivationMode
                                  .none, // We will control it manually
                              builder:
                                  (
                                    dynamic data,
                                    dynamic point,
                                    dynamic series,
                                    int pointIndex,
                                    int seriesIndex,
                                  ) {
                                    final value = point.y.toStringAsFixed(1);
                                    return Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
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
                            );

                            // final hardDisks =loginProvider.filedata?.hardDisk ?? [];
                            final hardDisks =
                                context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1]
                                    .hardDisk
                                    ?.disks ??
                                [];
                            final chartData = hardDisks
                                .map(
                                  (disk) => ChartData(
                                    disk.name ?? 'Unknown',
                                    ((disk.usedGb ?? 0) /
                                            (disk.totalGb ?? 1) *
                                            100)
                                        .clamp(0, 100),
                                    disk.status ?? 'Unknown',
                                  ),
                                )
                                .toList();

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: TitleWidget(
                                      title: "Hard Disk Health",
                                      icon: FontAwesomeIcons.hardDrive,
                                      iconColor: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Chart
                                        SizedBox(
                                          width: 110,
                                          height: 140,
                                          child: SfCircularChart(
                                            tooltipBehavior: tooltipBehavior,
                                            series: <CircularSeries>[
                                              RadialBarSeries<ChartData,String>(
                                                dataSource: chartData,
                                                xValueMapper:(ChartData data, _) =>data.x,
                                                yValueMapper:(ChartData data, _) =>data.y,
                                                cornerStyle:CornerStyle.bothCurve,
                                                gap: "5%",
                                                radius: '100%',
                                                innerRadius: '40%',
                                                pointColorMapper: (ChartData data, _) =>data.status == 'Healthy'? Colors.green: Colors.red,
                                                dataLabelSettings:
                                                    DataLabelSettings(
                                                      isVisible: false,
                                                    ),
                                                maximumValue: 100,
                                                
                                              ),
                                            ],
                                            annotations:
                                                const <
                                                  CircularChartAnnotation
                                                >[],
                                          ),
                                        ),
                                        // Annotations outside and to the right
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                              bottom: 16,
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: hardDisks
                                                    .asMap()
                                                    .entries
                                                    .map(
                                                      (
                                                        entry,
                                                      ) => GestureDetector(
                                                        onTap: () {
                                                          tooltipBehavior
                                                              .showByIndex(
                                                                0,
                                                                entry.key,
                                                              );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 2,
                                                              ),
                                                          child: Text(
                                                            "${entry.value.name ?? 'Unknown'}: ${entry.value.totalGb?.toStringAsFixed(0) ?? '0'}GB",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
                                    // itemCount: loginProvider.filedata!.ipCameras?.length ??0,
                                    itemCount: context.watch<GetSysInfoFileManagement>().ipCameras?.cameras?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      // final camera = loginProvider.filedata!.ipCameras![index];
                                      final camera = context.watch<GetSysInfoFileManagement>().ipCameras?.cameras![index];
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                camera?.name ?? 'Unknown',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelMedium,
                                              ),
                                              Icon(
                                                camera?.isRecording == true
                                                    ? CupertinoIcons
                                                          .checkmark_circle_fill
                                                    : CupertinoIcons
                                                          .clear_thick_circled,
                                                size: 16,
                                                color:
                                                    camera?.isRecording == true
                                                    ? Colors.green
                                                    : Colors.red,
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
                                  // trailingText: "${loginProvider.filedata!.network?.uploadSpeedMbps?.toStringAsFixed(1) ?? '0'} Mbps",
                                  trailingText:
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].network?.uploadSpeedKIB?.toStringAsFixed(1) ?? '0'} KIBps",
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Download Speed",
                                  trailingText:
                                      "${context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length - 1].network?.downloadSpeedKib?.toStringAsFixed(1) ?? '0'} KIBps",
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
                                  // "Total: ${loginProvider.filedata!.audioDevices?.total?.toString() ?? '0'}",
                                  "Total: ${context.watch<GetSysInfoFileManagement>().ipCameras?.cameras?.where((c) => c.deviceType?.toLowerCase() == "audio").length ?? 0}",
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: ListView(
                                    // children: loginProvider.filedata!.audioDevices?.devices
                                    children:
                                        context.watch<GetSysInfoFileManagement>().ipCameras?.cameras
                                            ?.where(
                                              (camera) =>
                                                  camera.deviceType?.toLowerCase() == "audio",
                                            )
                                            .map(
                                              (device) => Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        device.name ??
                                                            "Unknown",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.mic,
                                                        color:
                                                            device.isActive ==
                                                                true
                                                            ? Colors.blue
                                                            : Colors.red,
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
                                  subtitle: "Logitude",
                                  // trailingText: loginProvider.filedata!.location?.city ?? 'Unknown',
                                  trailingText:
                                      context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                              1]
                                          .location
                                          ?.longitude
                                          ?.toStringAsFixed(7) ??
                                      '0',
                                ),
                                const SizedBox(height: 8),
                                SubTitleWeidget(
                                  subtitle: "Latitude",
                                  // trailingText:"${loginProvider.filedata!.location?.latitude?.toStringAsFixed(2) ?? '0'}, ${loginProvider.filedata!.location?.longitude?.toStringAsFixed(2) ?? '0'}",
                                  trailingText:
                                      context.watch<GetSysInfoFileManagement>().systemInfoModel[context.watch<GetSysInfoFileManagement>().systemInfoModel.length -
                                              1]
                                          .location
                                          ?.latitude
                                          ?.toStringAsFixed(7) ??
                                      '0',
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

Widget _buildLineChart(List<double> data, Color color, {double maxY = 100}) {
  if (data.isEmpty) {
    return const Center(child: Text('No data available'));
  }

  final latestValue = data.last;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(4),
          child: Material(
            color: Colors.grey.withValues(alpha: 0.1),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY ,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.withValues(alpha: 0.3), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 1,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 8),
      // Latest value on right
      Text(
        "${latestValue.toStringAsFixed(1)}%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ],
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
              overflow: TextOverflow.fade,
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
