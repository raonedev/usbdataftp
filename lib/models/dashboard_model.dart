import 'dart:convert';
import 'package:flutter/foundation.dart';

class DashboardModel {
  final int activeCamera;
  final int unActiveCamera;
  final IpCameraModel ipCamera;
  final double cpuUsage;
  final double cpuTemperatureCelsius;
  final GpuModel gpu;
  final double ramUsage;
  final double totalRam;
  final double storageUsage;
  final double totalStorage;
  final List<DiskDetailModel> hardDisks;
  final Map<String, double> storageDistribution;
  final List<RecordingStatusModel> recordingStatuses;
  final VmsModel vms;
  final NetworkModel network;
  final DataTransferModel dataTransfer;
  final AudioDevicesModel audioDevices;
  final LocationModel location;

  DashboardModel({
    required this.activeCamera,
    required this.unActiveCamera,
    required this.ipCamera,
    required this.cpuUsage,
    required this.cpuTemperatureCelsius,
    required this.gpu,
    required this.ramUsage,
    required this.totalRam,
    required this.storageUsage,
    required this.totalStorage,
    required this.hardDisks,
    required this.storageDistribution,
    required this.recordingStatuses,
    required this.vms,
    required this.network,
    required this.dataTransfer,
    required this.audioDevices,
    required this.location,
  });

  DashboardModel copyWith({
    int? activeCamera,
    int? unActiveCamera,
    IpCameraModel? ipCamera,
    double? cpuUsage,
    double? cpuTemperatureCelsius,
    GpuModel? gpu,
    double? ramUsage,
    double? totalRam,
    double? storageUsage,
    double? totalStorage,
    List<DiskDetailModel>? hardDisks,
    Map<String, double>? storageDistribution,
    List<RecordingStatusModel>? recordingStatuses,
    VmsModel? vms,
    NetworkModel? network,
    DataTransferModel? dataTransfer,
    AudioDevicesModel? audioDevices,
    LocationModel? location,
  }) {
    return DashboardModel(
      activeCamera: activeCamera ?? this.activeCamera,
      unActiveCamera: unActiveCamera ?? this.unActiveCamera,
      ipCamera: ipCamera ?? this.ipCamera,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      cpuTemperatureCelsius: cpuTemperatureCelsius ?? this.cpuTemperatureCelsius,
      gpu: gpu ?? this.gpu,
      ramUsage: ramUsage ?? this.ramUsage,
      totalRam: totalRam ?? this.totalRam,
      storageUsage: storageUsage ?? this.storageUsage,
      totalStorage: totalStorage ?? this.totalStorage,
      hardDisks: hardDisks ?? this.hardDisks,
      storageDistribution: storageDistribution ?? this.storageDistribution,
      recordingStatuses: recordingStatuses ?? this.recordingStatuses,
      vms: vms ?? this.vms,
      network: network ?? this.network,
      dataTransfer: dataTransfer ?? this.dataTransfer,
      audioDevices: audioDevices ?? this.audioDevices,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'active_camera': activeCamera,
      'unactive_camera': unActiveCamera,
      'ip_camera': ipCamera.toMap(),
      'cpu_usage': cpuUsage,
      'cpu_temperature_celsius': cpuTemperatureCelsius,
      'gpu': gpu.toMap(),
      'ram_usuage': ramUsage,
      'total_ram': totalRam,
      'storage_usage': storageUsage,
      'total_storage': totalStorage,
      'hard_disk': hardDisks.map((x) => x.toMap()).toList(),
      'storage_distribution': storageDistribution,
      'recording_status': recordingStatuses.map((x) => x.toMap()).toList(),
      'vms': vms.toMap(),
      'network': network.toMap(),
      'data_transfer': dataTransfer.toMap(),
      'audio_devices': audioDevices.toMap(),
      'location': location.toMap(),
    };
  }

  factory DashboardModel.fromMap(Map<String, dynamic> map) {
    return DashboardModel(
      activeCamera: map['active_camera'] as int,
      unActiveCamera: map['unactive_camera'] as int,
      ipCamera: IpCameraModel.fromMap(map['ip_camera'] as Map<String, dynamic>),
      cpuUsage: (map['cpu_usage'] as num).toDouble(),
      cpuTemperatureCelsius: (map['cpu_temperature_celsius'] as num).toDouble(),
      gpu: GpuModel.fromMap(map['gpu'] as Map<String, dynamic>),
      ramUsage: (map['ram_usuage'] as num).toDouble(),
      totalRam: (map['total_ram'] as num).toDouble(),
      storageUsage: (map['storage_usage'] as num).toDouble(),
      totalStorage: (map['total_storage'] as num).toDouble(),
      hardDisks: List<DiskDetailModel>.from(
        (map['hard_disk'] as List).map<DiskDetailModel>(
          (x) => DiskDetailModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      storageDistribution: Map<String, double>.from(
        (map['storage_distribution'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      recordingStatuses: List<RecordingStatusModel>.from(
        (map['recording_status'] as List).map<RecordingStatusModel>(
          (x) => RecordingStatusModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      vms: VmsModel.fromMap(map['vms'] as Map<String, dynamic>),
      network: NetworkModel.fromMap(map['network'] as Map<String, dynamic>),
      dataTransfer: DataTransferModel.fromMap(map['data_transfer'] as Map<String, dynamic>),
      audioDevices: AudioDevicesModel.fromMap(map['audio_devices'] as Map<String, dynamic>),
      location: LocationModel.fromMap(map['location'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardModel.fromJson(String source) =>
      DashboardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DashboardModel(activeCamera: $activeCamera, unActiveCamera: $unActiveCamera, ipCamera: $ipCamera, cpuUsage: $cpuUsage, cpuTemperatureCelsius: $cpuTemperatureCelsius, gpu: $gpu, ramUsage: $ramUsage, totalRam: $totalRam, storageUsage: $storageUsage, totalStorage: $totalStorage, hardDisks: $hardDisks, storageDistribution: $storageDistribution, recordingStatuses: $recordingStatuses, vms: $vms, network: $network, dataTransfer: $dataTransfer, audioDevices: $audioDevices, location: $location)';
  }

  @override
  bool operator ==(covariant DashboardModel other) {
    if (identical(this, other)) return true;

    return other.activeCamera == activeCamera &&
        other.unActiveCamera == unActiveCamera &&
        other.ipCamera == ipCamera &&
        other.cpuUsage == cpuUsage &&
        other.cpuTemperatureCelsius == cpuTemperatureCelsius &&
        other.gpu == gpu &&
        other.ramUsage == ramUsage &&
        other.totalRam == totalRam &&
        other.storageUsage == storageUsage &&
        other.totalStorage == totalStorage &&
        listEquals(other.hardDisks, hardDisks) &&
        mapEquals(other.storageDistribution, storageDistribution) &&
        listEquals(other.recordingStatuses, recordingStatuses) &&
        other.vms == vms &&
        other.network == network &&
        other.dataTransfer == dataTransfer &&
        other.audioDevices == audioDevices &&
        other.location == location;
  }

  @override
  int get hashCode {
    return activeCamera.hashCode ^
        unActiveCamera.hashCode ^
        ipCamera.hashCode ^
        cpuUsage.hashCode ^
        cpuTemperatureCelsius.hashCode ^
        gpu.hashCode ^
        ramUsage.hashCode ^
        totalRam.hashCode ^
        storageUsage.hashCode ^
        totalStorage.hashCode ^
        hardDisks.hashCode ^
        storageDistribution.hashCode ^
        recordingStatuses.hashCode ^
        vms.hashCode ^
        network.hashCode ^
        dataTransfer.hashCode ^
        audioDevices.hashCode ^
        location.hashCode;
  }
}

class IpCameraModel {
  final List<String> active;
  final List<String> inactive;

  IpCameraModel({required this.active, required this.inactive});

  IpCameraModel copyWith({List<String>? active, List<String>? inactive}) {
    return IpCameraModel(
      active: active ?? this.active,
      inactive: inactive ?? this.inactive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'active': active, 'inactive': inactive};
  }

  factory IpCameraModel.fromMap(Map<String, dynamic> map) {
    return IpCameraModel(
      active: List<String>.from(map['active'] as List),
      inactive: List<String>.from(map['inactive'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory IpCameraModel.fromJson(String source) =>
      IpCameraModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IpCameraModel(active: $active, inactive: $inactive)';

  @override
  bool operator ==(covariant IpCameraModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.active, active) && listEquals(other.inactive, inactive);
  }

  @override
  int get hashCode => active.hashCode ^ inactive.hashCode;
}

class GpuModel {
  final double usage;
  final double temperatureCelsius;

  GpuModel({required this.usage, required this.temperatureCelsius});

  GpuModel copyWith({double? usage, double? temperatureCelsius}) {
    return GpuModel(
      usage: usage ?? this.usage,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'usage': usage, 'temperature_celsius': temperatureCelsius};
  }

  factory GpuModel.fromMap(Map<String, dynamic> map) {
    return GpuModel(
      usage: (map['usage'] as num).toDouble(),
      temperatureCelsius: (map['temperature_celsius'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory GpuModel.fromJson(String source) =>
      GpuModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'GpuModel(usage: $usage, temperatureCelsius: $temperatureCelsius)';

  @override
  bool operator ==(covariant GpuModel other) {
    if (identical(this, other)) return true;

    return other.usage == usage && other.temperatureCelsius == temperatureCelsius;
  }

  @override
  int get hashCode => usage.hashCode ^ temperatureCelsius.hashCode;
}

class DiskDetailModel {
  final String name;
  final String status;
  final double totalGb;
  final double usedGb;

  DiskDetailModel({
    required this.name,
    required this.status,
    required this.totalGb,
    required this.usedGb,
  });

  DiskDetailModel copyWith({
    String? name,
    String? status,
    double? totalGb,
    double? usedGb,
  }) {
    return DiskDetailModel(
      name: name ?? this.name,
      status: status ?? this.status,
      totalGb: totalGb ?? this.totalGb,
      usedGb: usedGb ?? this.usedGb,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'status': status,
      'total_gb': totalGb,
      'used_gb': usedGb,
    };
  }

  factory DiskDetailModel.fromMap(Map<String, dynamic> map) {
    return DiskDetailModel(
      name: map['name'] as String,
      status: map['status'] as String,
      totalGb: (map['total_gb'] as num).toDouble(),
      usedGb: (map['used_gb'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DiskDetailModel.fromJson(String source) =>
      DiskDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DiskDetailModel(name: $name, status: $status, totalGb: $totalGb, usedGb: $usedGb)';

  @override
  bool operator ==(covariant DiskDetailModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.status == status &&
        other.totalGb == totalGb &&
        other.usedGb == usedGb;
  }

  @override
  int get hashCode => name.hashCode ^ status.hashCode ^ totalGb.hashCode ^ usedGb.hashCode;
}

class RecordingStatusModel {
  final String name;
  final bool status;

  RecordingStatusModel({required this.name, required this.status});

  RecordingStatusModel copyWith({String? name, bool? status}) {
    return RecordingStatusModel(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'status': status};
  }

  factory RecordingStatusModel.fromMap(Map<String, dynamic> map) {
    return RecordingStatusModel(
      name: map['name'] as String,
      status: map['status'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecordingStatusModel.fromJson(String source) =>
      RecordingStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RecordingStatusModel(name: $name, status: $status)';

  @override
  bool operator ==(covariant RecordingStatusModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.status == status;
  }

  @override
  int get hashCode => name.hashCode ^ status.hashCode;
}

class VmsModel {
  final String name;
  final String version;

  VmsModel({required this.name, required this.version});

  VmsModel copyWith({String? name, String? version}) {
    return VmsModel(
      name: name ?? this.name,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'version': version};
  }

  factory VmsModel.fromMap(Map<String, dynamic> map) {
    return VmsModel(
      name: map['name'] as String,
      version: map['version'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory VmsModel.fromJson(String source) =>
      VmsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'VmsModel(name: $name, version: $version)';

  @override
  bool operator ==(covariant VmsModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.version == version;
  }

  @override
  int get hashCode => name.hashCode ^ version.hashCode;
}

class NetworkModel {
  final double uploadSpeedMbps;
  final double downloadSpeedMbps;

  NetworkModel({required this.uploadSpeedMbps, required this.downloadSpeedMbps});

  NetworkModel copyWith({double? uploadSpeedMbps, double? downloadSpeedMbps}) {
    return NetworkModel(
      uploadSpeedMbps: uploadSpeedMbps ?? this.uploadSpeedMbps,
      downloadSpeedMbps: downloadSpeedMbps ?? this.downloadSpeedMbps,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'upload_speed_mbps': uploadSpeedMbps,
      'download_speed_mbps': downloadSpeedMbps,
    };
  }

  factory NetworkModel.fromMap(Map<String, dynamic> map) {
    return NetworkModel(
      uploadSpeedMbps: (map['upload_speed_mbps'] as num).toDouble(),
      downloadSpeedMbps: (map['download_speed_mbps'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NetworkModel.fromJson(String source) =>
      NetworkModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NetworkModel(uploadSpeedMbps: $uploadSpeedMbps, downloadSpeedMbps: $downloadSpeedMbps)';

  @override
  bool operator ==(covariant NetworkModel other) {
    if (identical(this, other)) return true;

    return other.uploadSpeedMbps == uploadSpeedMbps && other.downloadSpeedMbps == downloadSpeedMbps;
  }

  @override
  int get hashCode => uploadSpeedMbps.hashCode ^ downloadSpeedMbps.hashCode;
}

class DataTransferModel {
  final double last5MinMb;
  final double last1HourMb;
  final double totalTodayGb;

  DataTransferModel({
    required this.last5MinMb,
    required this.last1HourMb,
    required this.totalTodayGb,
  });

  DataTransferModel copyWith({
    double? last5MinMb,
    double? last1HourMb,
    double? totalTodayGb,
  }) {
    return DataTransferModel(
      last5MinMb: last5MinMb ?? this.last5MinMb,
      last1HourMb: last1HourMb ?? this.last1HourMb,
      totalTodayGb: totalTodayGb ?? this.totalTodayGb,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'last_5_min_mb': last5MinMb,
      'last_1_hour_mb': last1HourMb,
      'total_today_gb': totalTodayGb,
    };
  }

  factory DataTransferModel.fromMap(Map<String, dynamic> map) {
    return DataTransferModel(
      last5MinMb: (map['last_5_min_mb'] as num).toDouble(),
      last1HourMb: (map['last_1_hour_mb'] as num).toDouble(),
      totalTodayGb: (map['total_today_gb'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DataTransferModel.fromJson(String source) =>
      DataTransferModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DataTransferModel(last5MinMb: $last5MinMb, last1HourMb: $last1HourMb, totalTodayGb: $totalTodayGb)';

  @override
  bool operator ==(covariant DataTransferModel other) {
    if (identical(this, other)) return true;

    return other.last5MinMb == last5MinMb &&
        other.last1HourMb == last1HourMb &&
        other.totalTodayGb == totalTodayGb;
  }

  @override
  int get hashCode => last5MinMb.hashCode ^ last1HourMb.hashCode ^ totalTodayGb.hashCode;
}

class AudioDevicesModel {
  final int total;
  final List<String> devices;

  AudioDevicesModel({required this.total, required this.devices});

  AudioDevicesModel copyWith({int? total, List<String>? devices}) {
    return AudioDevicesModel(
      total: total ?? this.total,
      devices: devices ?? this.devices,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'total': total, 'devices': devices};
  }

  factory AudioDevicesModel.fromMap(Map<String, dynamic> map) {
    return AudioDevicesModel(
      total: map['total'] as int,
      devices: List<String>.from(map['devices'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory AudioDevicesModel.fromJson(String source) =>
      AudioDevicesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AudioDevicesModel(total: $total, devices: $devices)';

  @override
  bool operator ==(covariant AudioDevicesModel other) {
    if (identical(this, other)) return true;

    return other.total == total && listEquals(other.devices, devices);
  }

  @override
  int get hashCode => total.hashCode ^ devices.hashCode;
}

class LocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final String country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'country': country,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      city: map['city'] as String,
      country: map['country'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory LocationModel.fromJson(String source) =>
      LocationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'LocationModel(latitude: $latitude, longitude: $longitude, city: $city, country: $country)';

  @override
  bool operator ==(covariant LocationModel other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude &&
        other.longitude == longitude &&
        other.city == city &&
        other.country == country;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ city.hashCode ^ country.hashCode;
}