import 'dart:convert';

class SystemInfoModel {
  final Ram? ram;
  final Storage? storage;
  final HardDisk? hardDisk;
  final Network? network;
  final Cpu? cpu;
  final Location? location;
  final Gpu? gpu;

  SystemInfoModel({
    this.ram,
    this.storage,
    this.hardDisk,
    this.network,
    this.cpu,
    this.location,
    this.gpu,
  });

  SystemInfoModel copyWith({
    Ram? ram,
    Storage? storage,
    HardDisk? hardDisk,
    Network? network,
    Cpu? cpu,
    Location? location,
    Gpu? gpu
  }) {
    return SystemInfoModel(
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      hardDisk: hardDisk ?? this.hardDisk,
      network: network ?? this.network,
      cpu: cpu ?? this.cpu,
      location: location ?? this.location,
      gpu: gpu ?? this.gpu
    );
  }


  factory SystemInfoModel.fromMap(Map<String, dynamic> map) {
    return SystemInfoModel(
      ram: map['ram'] != null ? Ram.fromMap(map['ram'] as Map<String,dynamic>) : null,
      storage: map['storage'] != null ? Storage.fromMap(map['storage'] as Map<String,dynamic>) : null,
      // hardDisk: map['hard_disk'] != null ? HardDisk.fromMap(map['hard_disk'] as Map<String,dynamic>) : null,
       hardDisk: map['hard_disk'] != null
        ? HardDisk(disks: List<Disk>.from(
            (map['hard_disk'] as List<dynamic>)
                .map((x) => Disk.fromMap(x as Map<String, dynamic>)),
          ))
        : null,
      network: map['network'] != null ? Network.fromMap(map['network'] as Map<String,dynamic>) : null,
      cpu: map['cpu'] != null ? Cpu.fromMap(map['cpu'] as Map<String,dynamic>) : null,
      location: map['location'] != null ? Location.fromMap(map['location'] as Map<String,dynamic>) : null,
      gpu: map['gpu'] != null ? Gpu.fromMap(map['gpu'] as Map<String,dynamic>) : null,
    );
  }

  factory SystemInfoModel.fromJson(String source) => SystemInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SystemInfoModel(\nram: $ram, \nstorage: $storage, \nhardDisk: $hardDisk, \nnetwork: $network, \ncpu: $cpu, \ngpu: $gpu, \nlocation: $location)';
  }
}

//-------------RAM----------------------
class Ram {
  final double? usagePercentage;
  final double? totalGb;
  final double? usedGb;
  final double? freeGb;

  Ram({this.usagePercentage, this.totalGb, this.usedGb, this.freeGb});

  factory Ram.fromMap(Map<String, dynamic> map) {
    return Ram(
      usagePercentage: map['usage_percent'] != null
          ? map['usage_percent'] as double
          : null,
      totalGb: map['total_gb'] != null ? map['total_gb'] as double : null,
      usedGb: map['used_gb'] != null ? map['used_gb'] as double : null,
      freeGb: map['free_gb'] != null ? map['free_gb'] as double : null,
    );
  }

  factory Ram.fromJson(String source) =>
      Ram.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Ram(usagePercentage:$usagePercentage, totalGb:$totalGb, usedGb:$usedGb, freeGb:$freeGb)';
  }
}

///--------------- Network ---------------
class Network {
  final String? interface;
  final double? uploadSpeedKIB;
  final double? downloadSpeedKib;
  final double? uploadSpeedByte;
  final double? downloadSpeedByte;

  Network({
    this.interface,
    this.uploadSpeedKIB,
    this.downloadSpeedKib,
    this.uploadSpeedByte,
    this.downloadSpeedByte,
  });

  factory Network.fromMap(Map<String, dynamic> map) {
    return Network(
      interface: map['interface'] as String?,
      uploadSpeedKIB: (map['upload_speed_kib'] as num?)?.toDouble(),
      downloadSpeedKib: (map['download_speed_kib'] as num?)?.toDouble(),
      uploadSpeedByte: (map['upload_speed_bytes'] as num?)?.toDouble(),
      downloadSpeedByte: (map['download_speed_bytes'] as num?)?.toDouble(),
    );
  }

  factory Network.fromJson(String source) =>
      Network.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Network(\n\tinterface: $interface, \n\tuploadSpeedKIB: $uploadSpeedKIB, \n\tdownloadSpeedKib: $downloadSpeedKib, \n\tuploadSpeedByte: $uploadSpeedByte, \n\tdownloadSpeedByte: $downloadSpeedByte\n)';
  }
}

//--------------CPU -----------------
class Cpu {
  final int? usagePercent;
  final double? temperatureCelsius;

  Cpu({this.usagePercent, this.temperatureCelsius});

  factory Cpu.fromMap(Map<String, dynamic> map) {
    return Cpu(
      usagePercent: map['usage'] != null ? map['usage'] as int : null,
      temperatureCelsius: map['temperature_celsius'] != null
          ? map['temperature_celsius'] as double
          : null,
    );
  }

  factory Cpu.fromJson(String source) =>
      Cpu.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Cpu(usagePercent:$usagePercent, temperaturePercentage:$temperatureCelsius)';
}

//-----------------Total storage-------------------
class Storage {
  final int? usedGb;
  final int? totalGb;

  Storage({this.usedGb, this.totalGb});

  factory Storage.fromMap(Map<String, dynamic> map) {
    return Storage(
      usedGb: map['usage'] as int?,
      totalGb: map['total_gb'] as int?,
    );
  }
  factory Storage.fromJson(String source) =>
      Storage.fromMap(json.decode(source));

  @override
  String toString() {
    return "Storage(usedGb:$usedGb, totalGb:$totalGb)";
  }
}

//-----------hard disk------
class HardDisk {
  final List<Disk>? disks;
  HardDisk({this.disks});

  factory HardDisk.fromMap(Map<String, dynamic> map) {
    return HardDisk(
      disks: map['hard_disk'] != null
          ? List<Disk>.from(
              (map['hard_disk'] as List<dynamic>).map<Disk?>(
                (x) => Disk.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
    );
  }
  factory HardDisk.fromJson(String source) =>
      HardDisk.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() => 'HardDisk(\ndisks: $disks\n)';
}

///----------  Disk------------
class Disk {
  final String? name;
  final String? status;
  final int? totalGb;
  final int? usedGb;
  final String? mountedPointPath;

  Disk({
    this.name,
    this.status,
    this.totalGb,
    this.usedGb,
    this.mountedPointPath,
  });

  factory Disk.fromMap(Map<String, dynamic> map) {
    return Disk(
      name: map['name'] != null ? map['name'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      totalGb: map['total_gb'] != null ? map['total_gb'] as int : null,
      usedGb: map['used_gb'] != null ? map['used_gb'] as int : null,
      mountedPointPath: map['mountpoint'] != null
          ? map['mountpoint'] as String
          : null,
    );
  }

  factory Disk.fromJson(String source) =>
      Disk.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '\n\tDisk(name:$name, status:$status, totalGb:$totalGb, usedGb: $usedGb, mountedPointPath: $mountedPointPath)';
  }
}


///---------- location ---------------
class Location {
  String? id;
  String? time;
  double? latitude;
  double? longitude;
  String? fixQuality;
  String? noOfSatellite;
  String? altitude;
  String? course;
  Location({
    this.id,
    this.time,
    this.latitude,
    this.longitude,
    this.fixQuality,
    this.noOfSatellite,
    this.altitude,
    this.course,
  });

  Location copyWith({
    String? id,
    String? time,
    double? latitude,
    double? longitude,
    String? fixQuality,
    String? noOfSatellite,
    String? altitude,
    String? course,
  }) {
    return Location(
      id: id ?? this.id,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fixQuality: fixQuality ?? this.fixQuality,
      noOfSatellite: noOfSatellite ?? this.noOfSatellite,
      altitude: altitude ?? this.altitude,
      course: course ?? this.course,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
      'fixQuality': fixQuality,
      'noOfSatellite': noOfSatellite,
      'altitude': altitude,
      'course': course,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['_id'] != null ? map['_id'] as String : null,
      time: map['Time'] != null ? map['Time'] as String : null,
      latitude: map['Latitude'] != null ? map['Latitude'] as double : null,
      longitude: map['Longitude'] != null ? map['Longitude'] as double : null,
      fixQuality: map['FixQuality'] != null ? map['FixQuality'] as String : null,
      noOfSatellite: map['NoOfSatellite'] != null ? map['NoOfSatellite'] as String : null,
      altitude: map['Altitude'] != null ? map['Altitude'] as String : null,
      course: map['Course'] != null ? map['Course'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) => Location.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Location(\n\tid: $id, \n\ttime: $time, \n\tlatitude: $latitude, \n\tlongitude: $longitude, \n\tfixQuality: $fixQuality, \n\tnoOfSatellite: $noOfSatellite, \n\taltitude: $altitude, \n\tcourse: $course\n)';
  }

  @override
  bool operator ==(covariant Location other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.time == time &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.fixQuality == fixQuality &&
      other.noOfSatellite == noOfSatellite &&
      other.altitude == altitude &&
      other.course == course;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      time.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      fixQuality.hashCode ^
      noOfSatellite.hashCode ^
      altitude.hashCode ^
      course.hashCode;
  }
}


///--------GPU-----------
class Gpu {
  final int? usagePercent;
  final double? temperatureCelsius;

  Gpu({this.usagePercent, this.temperatureCelsius});

  factory Gpu.fromMap(Map<String, dynamic> map) {
    return Gpu(
      usagePercent: map['usage'] != null ? map['usage'] as int : null,
      temperatureCelsius: map['temperature_celsius'] != null
          ? map['temperature_celsius'] as double
          : null,
    );
  }

  factory Gpu.fromJson(String source) =>
      Gpu.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Gpu(usagePercent:$usagePercent, temperaturePercentage:$temperatureCelsius)';
}