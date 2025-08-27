import 'dart:convert';


class IpCameras {
  final List<CameraStatusModel>? cameras;
  IpCameras({
    this.cameras,
  });

  factory IpCameras.fromMap(Map<String, dynamic> map) {
    return IpCameras(
      cameras: map['ip_cameras'] != null ? List<CameraStatusModel>.from((map['ip_cameras'] as List<dynamic>).map<CameraStatusModel?>((x) => CameraStatusModel.fromMap(x as Map<String,dynamic>),),) : null,
    );
  }

  factory IpCameras.fromJson(String source) => IpCameras.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IpCameras(cameras: $cameras)';


}

class CameraStatusModel {
  final String? name;
  final String? host;
  final int? port;
  final bool? isActive;
  final bool? isRecording;
  final String? macAddress;
  final String? deviceType;
  final int? legecyId;

  CameraStatusModel({
    this.name,
    this.host,
    this.port,
    this.isActive,
    this.isRecording,
    this.macAddress,
    this.deviceType,
    this.legecyId,
  });



  factory CameraStatusModel.fromMap(Map<String, dynamic> map) {
    return CameraStatusModel(
      name: map['name'] != null ? map['name'] as String : null,
      host: map['host'] != null ? map['host'] as String : null,
      port: map['port'] != null ? map['port'] as int : null,
      isActive: map['isActive'] != null ? map['isActive'] as bool : null,
      isRecording: map['isRecording'] != null ? map['isRecording'] as bool : null,
      macAddress: map['mac_address'] != null ? map['mac_address'] as String : null,
      deviceType: map['device_type'] != null ? map['device_type'] as String : null,
      legecyId: map['legacy_id'] != null ? map['legacy_id'] as int : null,
    );
  }


  factory CameraStatusModel.fromJson(String source) => CameraStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return '\nCameraStatusModel(\n\tname: $name, \n\thost: $host, \n\tport: $port, \n\tisActive: $isActive, \n\tisRecording: $isRecording, \n\tmacAddress: $macAddress, \n\tdeviceType: $deviceType, \n\tlegecyId: $legecyId\n)';
  }

  @override
  bool operator ==(covariant CameraStatusModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.host == host &&
      other.port == port &&
      other.isActive == isActive &&
      other.isRecording == isRecording &&
      other.macAddress == macAddress &&
      other.deviceType == deviceType &&
      other.legecyId == legecyId;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      host.hashCode ^
      port.hashCode ^
      isActive.hashCode ^
      isRecording.hashCode ^
      macAddress.hashCode ^
      deviceType.hashCode ^
      legecyId.hashCode;
  }
}
