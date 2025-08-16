import 'dart:convert';
import 'package:flutter/foundation.dart';

class DashboardNewModel {
  final int? activeCamera;
  final int? unactiveCamera;
  final List<IpCamera>? ipCameras;
  final Cpu? cpu;
  final Gpu? gpu;
  final Ram? ram;
  final Storage? storage;
  final List<HardDisk>? hardDisk;
  final Vms? vms;
  final Network? network;
  final AudioDevices? audioDevices;
  final Location? location;

  DashboardNewModel({
    this.activeCamera,
    this.unactiveCamera,
    this.ipCameras,
    this.cpu,
    this.gpu,
    this.ram,
    this.storage,
    this.hardDisk,
    this.vms,
    this.network,
    this.audioDevices,
    this.location,
  });

  DashboardNewModel copyWith({
    int? activeCamera,
    int? unactiveCamera,
    List<IpCamera>? ipCameras,
    Cpu? cpu,
    Gpu? gpu,
    Ram? ram,
    Storage? storage,
    List<HardDisk>? hardDisk,
    Vms? vms,
    Network? network,
    AudioDevices? audioDevices,
    Location? location,
  }) {
    return DashboardNewModel(
      activeCamera: activeCamera ?? this.activeCamera,
      unactiveCamera: unactiveCamera ?? this.unactiveCamera,
      ipCameras: ipCameras ?? this.ipCameras,
      cpu: cpu ?? this.cpu,
      gpu: gpu ?? this.gpu,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      hardDisk: hardDisk ?? this.hardDisk,
      vms: vms ?? this.vms,
      network: network ?? this.network,
      audioDevices: audioDevices ?? this.audioDevices,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active_camera': activeCamera,
      'unactive_camera': unactiveCamera,
      'ip_cameras': ipCameras?.map((e) => e.toMap()).toList(),
      'cpu': cpu?.toMap(),
      'gpu': gpu?.toMap(),
      'ram': ram?.toMap(),
      'storage': storage?.toMap(),
      'hard_disk': hardDisk?.map((e) => e.toMap()).toList(),
      'vms': vms?.toMap(),
      'network': network?.toMap(),
      'audio_devices': audioDevices?.toMap(),
      'location': location?.toMap(),
    };
  }

  factory DashboardNewModel.fromMap(Map<String, dynamic> map) {
    final ipCamerasList = (map['ip_cameras'] as List?)
        ?.map((e) => IpCamera.fromMap(e))
        .toList();
    
    // Calculate active and inactive cameras
    int activeCameraCount = 0;
    int unactiveCameraCount = 0;
    
    if (ipCamerasList != null) {
      for (var camera in ipCamerasList) {
        if (camera.isActive == true) {
          activeCameraCount++;
        } else {
          unactiveCameraCount++;
        }
      }
    }

    return DashboardNewModel(
      activeCamera: activeCameraCount,
      unactiveCamera: unactiveCameraCount,
      ipCameras: ipCamerasList,
      cpu: map['cpu'] != null ? Cpu.fromMap(map['cpu']) : null,
      gpu: map['gpu'] != null ? Gpu.fromMap(map['gpu']) : null,
      ram: map['ram'] != null ? Ram.fromMap(map['ram']) : null,
      storage: map['storage'] != null ? Storage.fromMap(map['storage']) : null,
      hardDisk: (map['hard_disk'] as List?)
          ?.map((e) => HardDisk.fromMap(e))
          .toList(),
      vms: map['vms'] != null ? Vms.fromMap(map['vms']) : null,
      network: map['network'] != null ? Network.fromMap(map['network']) : null,
      audioDevices: map['audio_devices'] != null
          ? AudioDevices.fromMap(map['audio_devices'])
          : null,
      location: map['location'] != null
          ? Location.fromMap(map['location'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardNewModel.fromJson(String source) =>
      DashboardNewModel.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardNewModel &&
          activeCamera == other.activeCamera &&
          unactiveCamera == other.unactiveCamera &&
          listEquals(ipCameras, other.ipCameras) &&
          cpu == other.cpu &&
          gpu == other.gpu &&
          ram == other.ram &&
          storage == other.storage &&
          listEquals(hardDisk, other.hardDisk) &&
          vms == other.vms &&
          network == other.network &&
          audioDevices == other.audioDevices &&
          location == other.location;

  @override
  int get hashCode => Object.hashAll([
    activeCamera,
    unactiveCamera,
    ipCameras,
    cpu,
    gpu,
    ram,
    storage,
    hardDisk,
    vms,
    network,
    audioDevices,
    location,
  ]);
}

class IpCamera {
  final String? name;
  final String? host;
  final int? port;
  final String? ipAddress;
  final String? macAddress;
  final int? connectionStatusDb;
  final bool? isRecording;
  final bool? isActive;
  final int? legacyId;
  final bool? pingSuccess;
  final bool? httpAccessible;

  IpCamera({
    this.name,
    this.host,
    this.port,
    this.ipAddress,
    this.macAddress,
    this.connectionStatusDb,
    this.isRecording,
    this.isActive,
    this.legacyId,
    this.pingSuccess,
    this.httpAccessible,
  });

  IpCamera copyWith({
    String? name,
    String? host,
    int? port,
    String? ipAddress,
    String? macAddress,
    int? connectionStatusDb,
    bool? isRecording,
    bool? isActive,
    int? legacyId,
    bool? pingSuccess,
    bool? httpAccessible,
  }) {
    return IpCamera(
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      connectionStatusDb: connectionStatusDb ?? this.connectionStatusDb,
      isRecording: isRecording ?? this.isRecording,
      isActive: isActive ?? this.isActive,
      legacyId: legacyId ?? this.legacyId,
      pingSuccess: pingSuccess ?? this.pingSuccess,
      httpAccessible: httpAccessible ?? this.httpAccessible,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'host': host,
    'port': port,
    'ip_address': ipAddress,
    'mac_address': macAddress,
    'connection_status_db': connectionStatusDb,
    'isRecording': isRecording,
    'isActive': isActive,
    'legacy_id': legacyId,
    'ping_success': pingSuccess,
    'http_accessible': httpAccessible,
  };

  factory IpCamera.fromMap(Map<String, dynamic> map) => IpCamera(
    name: map['name'],
    host: map['host'],
    port: map['port'],
    ipAddress: map['ip_address'],
    macAddress: map['mac_address'],
    connectionStatusDb: map['connection_status_db'],
    isRecording: map['isRecording'],
    isActive: map['isActive'],
    legacyId: map['legacy_id'],
    pingSuccess: map['ping_success'],
    httpAccessible: map['http_accessible'],
  );

  String toJson() => json.encode(toMap());

  factory IpCamera.fromJson(String source) =>
      IpCamera.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IpCamera &&
          name == other.name &&
          host == other.host &&
          port == other.port &&
          ipAddress == other.ipAddress &&
          macAddress == other.macAddress &&
          connectionStatusDb == other.connectionStatusDb &&
          isRecording == other.isRecording &&
          isActive == other.isActive &&
          legacyId == other.legacyId &&
          pingSuccess == other.pingSuccess &&
          httpAccessible == other.httpAccessible;

  @override
  int get hashCode => Object.hashAll([
    name,
    host,
    port,
    ipAddress,
    macAddress,
    connectionStatusDb,
    isRecording,
    isActive,
    legacyId,
    pingSuccess,
    httpAccessible,
  ]);
}

class Cpu {
  final double? usage;
  final double? temperatureCelsius;

  Cpu({this.usage, this.temperatureCelsius});

  Cpu copyWith({double? usage, double? temperatureCelsius}) {
    return Cpu(
      usage: usage ?? this.usage,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    );
  }

  Map<String, dynamic> toMap() => {
    'usage': usage,
    'temperature_celsius': temperatureCelsius,
  };

  factory Cpu.fromMap(Map<String, dynamic> map) => Cpu(
    usage: (map['usage'] as num?)?.toDouble(),
    temperatureCelsius: (map['temperature_celsius'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory Cpu.fromJson(String source) => Cpu.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cpu &&
          usage == other.usage &&
          temperatureCelsius == other.temperatureCelsius;

  @override
  int get hashCode => Object.hash(usage, temperatureCelsius);
}

class Gpu {
  final double? usage;
  final double? temperatureCelsius;

  Gpu({this.usage, this.temperatureCelsius});

  Gpu copyWith({double? usage, double? temperatureCelsius}) {
    return Gpu(
      usage: usage ?? this.usage,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    );
  }

  Map<String, dynamic> toMap() => {
    'usage': usage,
    'temperature_celsius': temperatureCelsius,
  };

  factory Gpu.fromMap(Map<String, dynamic> map) => Gpu(
    usage: (map['usage'] as num?)?.toDouble(),
    temperatureCelsius: (map['temperature_celsius'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory Gpu.fromJson(String source) => Gpu.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Gpu &&
          usage == other.usage &&
          temperatureCelsius == other.temperatureCelsius;

  @override
  int get hashCode => Object.hash(usage, temperatureCelsius);
}

class Ram {
  final double? usage;
  final double? totalGb;

  Ram({this.usage, this.totalGb});

  Ram copyWith({double? usage, double? totalGb}) {
    return Ram(usage: usage ?? this.usage, totalGb: totalGb ?? this.totalGb);
  }

  Map<String, dynamic> toMap() => {'usage': usage, 'total_gb': totalGb};

  factory Ram.fromMap(Map<String, dynamic> map) => Ram(
    usage: (map['usage'] as num?)?.toDouble(),
    totalGb: (map['total_gb'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory Ram.fromJson(String source) => Ram.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ram && usage == other.usage && totalGb == other.totalGb;

  @override
  int get hashCode => Object.hash(usage, totalGb);
}

class Storage {
  final double? usage;
  final double? totalGb;

  Storage({this.usage, this.totalGb});

  Storage copyWith({double? usage, double? totalGb}) {
    return Storage(
      usage: usage ?? this.usage,
      totalGb: totalGb ?? this.totalGb,
    );
  }

  Map<String, dynamic> toMap() => {'usage': usage, 'total_gb': totalGb};

  factory Storage.fromMap(Map<String, dynamic> map) => Storage(
    usage: (map['usage'] as num?)?.toDouble(),
    totalGb: (map['total_gb'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory Storage.fromJson(String source) =>
      Storage.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Storage && usage == other.usage && totalGb == other.totalGb;

  @override
  int get hashCode => Object.hash(usage, totalGb);
}

class HardDisk {
  final String? name;
  final String? status;
  final double? totalGb;
  final double? usedGb;

  HardDisk({this.name, this.status, this.totalGb, this.usedGb});

  HardDisk copyWith({String? name, String? status, double? totalGb, double? usedGb}) {
    return HardDisk(
      name: name ?? this.name,
      status: status ?? this.status,
      totalGb: totalGb ?? this.totalGb,
      usedGb: usedGb ?? this.usedGb,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'status': status,
    'total_gb': totalGb,
    'used_gb': usedGb,
  };

  factory HardDisk.fromMap(Map<String, dynamic> map) => HardDisk(
    name: map['name'],
    status: map['status'],
    totalGb: (map['total_gb'] as num?)?.toDouble(),
    usedGb: (map['used_gb'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory HardDisk.fromJson(String source) =>
      HardDisk.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardDisk &&
          name == other.name &&
          status == other.status &&
          totalGb == other.totalGb &&
          usedGb == other.usedGb;

  @override
  int get hashCode => Object.hash(name, status, totalGb, usedGb);
}

class Vms {
  final String? name;
  final String? version;

  Vms({this.name, this.version});

  Vms copyWith({String? name, String? version}) {
    return Vms(name: name ?? this.name, version: version ?? this.version);
  }

  Map<String, dynamic> toMap() => {'name': name, 'version': version};

  factory Vms.fromMap(Map<String, dynamic> map) =>
      Vms(name: map['name'], version: map['version']);

  String toJson() => json.encode(toMap());

  factory Vms.fromJson(String source) => Vms.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vms && name == other.name && version == other.version;

  @override
  int get hashCode => Object.hash(name, version);
}

class Network {
  final double? uploadSpeedMbps;
  final double? downloadSpeedMbps;

  Network({this.uploadSpeedMbps, this.downloadSpeedMbps});

  Network copyWith({double? uploadSpeedMbps, double? downloadSpeedMbps}) {
    return Network(
      uploadSpeedMbps: uploadSpeedMbps ?? this.uploadSpeedMbps,
      downloadSpeedMbps: downloadSpeedMbps ?? this.downloadSpeedMbps,
    );
  }

  Map<String, dynamic> toMap() => {
    'upload_speed_mbps': uploadSpeedMbps,
    'download_speed_mbps': downloadSpeedMbps,
  };

  factory Network.fromMap(Map<String, dynamic> map) => Network(
    uploadSpeedMbps: (map['upload_speed_mbps'] as num?)?.toDouble(),
    downloadSpeedMbps: (map['download_speed_mbps'] as num?)?.toDouble(),
  );

  String toJson() => json.encode(toMap());

  factory Network.fromJson(String source) =>
      Network.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Network &&
          uploadSpeedMbps == other.uploadSpeedMbps &&
          downloadSpeedMbps == other.downloadSpeedMbps;

  @override
  int get hashCode => Object.hash(uploadSpeedMbps, downloadSpeedMbps);
}

class AudioDevices {
  final int? total;
  final List<String>? devices;

  AudioDevices({this.total, this.devices});

  AudioDevices copyWith({int? total, List<String>? devices}) {
    return AudioDevices(
      total: total ?? this.total,
      devices: devices ?? this.devices,
    );
  }

  Map<String, dynamic> toMap() => {'total': total, 'devices': devices};

  factory AudioDevices.fromMap(Map<String, dynamic> map) => AudioDevices(
    total: map['total'],
    devices: List<String>.from(map['devices'] ?? []),
  );

  String toJson() => json.encode(toMap());

  factory AudioDevices.fromJson(String source) =>
      AudioDevices.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioDevices &&
          total == other.total &&
          listEquals(devices, other.devices);

  @override
  int get hashCode => Object.hash(total, devices);
}

class Location {
  final double? latitude;
  final double? longitude;
  final String? city;

  Location({this.latitude, this.longitude, this.city});

  Location copyWith({double? latitude, double? longitude, String? city}) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
  };

  factory Location.fromMap(Map<String, dynamic> map) => Location(
    latitude: (map['latitude'] as num?)?.toDouble(),
    longitude: (map['longitude'] as num?)?.toDouble(),
    city: map['city'],
  );

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source));

  @override
  String toString() => toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          city == other.city;

  @override
  int get hashCode => Object.hash(latitude, longitude, city);
}