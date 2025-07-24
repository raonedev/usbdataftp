import 'dart:convert';
import 'package:flutter/foundation.dart';

class DashboardModel {
  final int activeCamera;
  final int unActiveCamera;
  final double cpuUsage;
  final double storageUsage;
  final double totalStorage;
  final double ramUsage;
  final double totalRam;
  final String vmsVersion;
  final List<DiskDetailModel> hardDisks;
  final List<RecordingStatusModel> recordingStatuses;

  DashboardModel({
    required this.activeCamera,
    required this.unActiveCamera,
    required this.cpuUsage,
    required this.storageUsage,
    required this.totalStorage,
    required this.ramUsage,
    required this.totalRam,
    required this.vmsVersion,
    required this.hardDisks,
    required this.recordingStatuses,
  });

  DashboardModel copyWith({
    int? activeCamera,
    int? unActiveCamera,
    double? cpuUsage,
    double? storageUsage,
    double? totalStorage,
    double? ramUsage,
    double? totalRam,
    String? vmsVersion,
    List<DiskDetailModel>? hardDisks,
    List<RecordingStatusModel>? recordingStatuses,
  }) {
    return DashboardModel(
      activeCamera: activeCamera ?? this.activeCamera,
      unActiveCamera: unActiveCamera ?? this.unActiveCamera,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      storageUsage: storageUsage ?? this.storageUsage,
      totalStorage: totalStorage ?? this.totalStorage,
      ramUsage: ramUsage ?? this.ramUsage,
      totalRam: totalRam ?? this.totalRam,
      vmsVersion: vmsVersion ?? this.vmsVersion,
      hardDisks: hardDisks ?? this.hardDisks,
      recordingStatuses: recordingStatuses ?? this.recordingStatuses,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'active_camera': activeCamera,
      'unactive_camera': unActiveCamera,
      'cpu_usage': cpuUsage,
      'storage_usage': storageUsage,
      'total_storage': totalStorage,
      'ram_usuage': ramUsage,
      'total_ram': totalRam,
      'vms_version': vmsVersion,
      'hard_disk': hardDisks.map((x) => x.toMap()).toList(),
      'recording_status': recordingStatuses.map((x) => x.toMap()).toList(),
    };
  }

  factory DashboardModel.fromMap(Map<String, dynamic> map) {
    return DashboardModel(
      activeCamera: map['active_camera'] as int,
      unActiveCamera: map['unactive_camera'] as int,
      cpuUsage: (map['cpu_usage'] as num).toDouble(),
      storageUsage: (map['storage_usage'] as num).toDouble(),
      totalStorage: (map['total_storage'] as num).toDouble(),
      ramUsage: (map['ram_usuage'] as num).toDouble(),
      totalRam: (map['total_ram'] as num).toDouble(),
      vmsVersion: map['vms_version'] as String,
      hardDisks: List<DiskDetailModel>.from(
        (map['hard_disk'] as List).map<DiskDetailModel>(
          (x) => DiskDetailModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      recordingStatuses: List<RecordingStatusModel>.from(
        (map['recording_status'] as List).map<RecordingStatusModel>(
          (x) => RecordingStatusModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardModel.fromJson(String source) =>
      DashboardModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DashboardModel(activeCamera: $activeCamera, unActiveCamera: $unActiveCamera, cpuUsage: $cpuUsage, storageUsage: $storageUsage, totalStorage: $totalStorage, ramUsage: $ramUsage, totalRam: $totalRam, vmsVersion: $vmsVersion, hardDisks: $hardDisks, recordingStatuses: $recordingStatuses)';
  }

  @override
  bool operator ==(covariant DashboardModel other) {
    if (identical(this, other)) return true;

    return other.activeCamera == activeCamera &&
        other.unActiveCamera == unActiveCamera &&
        other.cpuUsage == cpuUsage &&
        other.storageUsage == storageUsage &&
        other.totalStorage == totalStorage &&
        other.ramUsage == ramUsage &&
        other.totalRam == totalRam &&
        other.vmsVersion == vmsVersion &&
        listEquals(other.hardDisks, hardDisks) &&
        listEquals(other.recordingStatuses, recordingStatuses);
  }

  @override
  int get hashCode {
    return activeCamera.hashCode ^
        unActiveCamera.hashCode ^
        cpuUsage.hashCode ^
        storageUsage.hashCode ^
        totalStorage.hashCode ^
        ramUsage.hashCode ^
        totalRam.hashCode ^
        vmsVersion.hashCode ^
        hardDisks.hashCode ^
        recordingStatuses.hashCode;
  }
}

class DiskDetailModel {
  final String name;
  final String status;

  DiskDetailModel({required this.name, required this.status});

  DiskDetailModel copyWith({String? name, String? status}) {
    return DiskDetailModel(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'status': status};
  }

  factory DiskDetailModel.fromMap(Map<String, dynamic> map) {
    return DiskDetailModel(
      name: map['name'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiskDetailModel.fromJson(String source) =>
      DiskDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DiskDetailModel(name: $name, status: $status)';

  @override
  bool operator ==(covariant DiskDetailModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.status == status;
  }

  @override
  int get hashCode => name.hashCode ^ status.hashCode;
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
