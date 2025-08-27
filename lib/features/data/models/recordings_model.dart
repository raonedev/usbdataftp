import 'dart:convert';

import 'package:flutter/foundation.dart';

class AllRecordingsFiles {
  final List<RecordingFileModel> recordings;
  final int total;
  final int limit;
  final int offset;
  AllRecordingsFiles({
    required this.recordings,
    required this.total,
    required this.limit,
    required this.offset,
  });

  AllRecordingsFiles copyWith({
    List<RecordingFileModel>? recordings,
    int? total,
    int? limit,
    int? offset,
  }) {
    return AllRecordingsFiles(
      recordings: recordings ?? this.recordings,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'recordings': recordings.map((x) => x.toMap()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }

  factory AllRecordingsFiles.fromMap(Map<String, dynamic> map) {
    return AllRecordingsFiles(
      recordings: List<RecordingFileModel>.from(
        (map['recordings'] as List).map<RecordingFileModel>(
          (x) => RecordingFileModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      total: map['total'] as int,
      limit: map['limit'] as int,
      offset: map['offset'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AllRecordingsFiles.fromJson(String source) =>
      AllRecordingsFiles.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AllRecordingsFiles(recordings: $recordings, total: $total, limit: $limit, offset: $offset)';
  }

  @override
  bool operator ==(covariant AllRecordingsFiles other) {
    if (identical(this, other)) return true;

    return listEquals(other.recordings, recordings) &&
        other.total == total &&
        other.limit == limit &&
        other.offset == offset;
  }

  @override
  int get hashCode {
    return recordings.hashCode ^
        total.hashCode ^
        limit.hashCode ^
        offset.hashCode;
  }
}

class RecordingFileModel {
  final String name;
  final String path;
  final String created;
  final String modified;
  final String sizeFormatted;
  final int deviceId;
  final int size;
  RecordingFileModel({
    required this.name,
    required this.path,
    required this.created,
    required this.modified,
    required this.sizeFormatted,
    required this.deviceId,
    required this.size,
  });

  RecordingFileModel copyWith({
    String? name,
    String? path,
    String? created,
    String? modified,
    String? sizeFormatted,
    int? deviceId,
    int? size,
  }) {
    return RecordingFileModel(
      name: name ?? this.name,
      path: path ?? this.path,
      created: created ?? this.created,
      modified: modified ?? this.modified,
      sizeFormatted: sizeFormatted ?? this.sizeFormatted,
      deviceId: deviceId ?? this.deviceId,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'path': path,
      'created': created,
      'modified': modified,
      'sizeFormatted': sizeFormatted,
      'deviceId': deviceId,
      'size': size,
    };
  }

  factory RecordingFileModel.fromMap(Map<String, dynamic> map) {
    return RecordingFileModel(
      name: map['name'] as String,
      path: map['path'] as String,
      created: map['created'] as String,
      modified: map['modified'] as String,
      sizeFormatted: map['sizeFormatted'] as String,
      deviceId: map['deviceId'] as int,
      size: map['size'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory RecordingFileModel.fromJson(String source) =>
      RecordingFileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RecordingFileModel(name: $name, path: $path, created: $created, modified: $modified, sizeFormatted: $sizeFormatted, deviceId: $deviceId, size: $size)';
  }

  @override
  bool operator ==(covariant RecordingFileModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.path == path &&
        other.created == created &&
        other.modified == modified &&
        other.sizeFormatted == sizeFormatted &&
        other.deviceId == deviceId &&
        other.size == size;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        path.hashCode ^
        created.hashCode ^
        modified.hashCode ^
        sizeFormatted.hashCode ^
        deviceId.hashCode ^
        size.hashCode;
  }
}
