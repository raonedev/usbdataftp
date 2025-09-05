import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:usbdataftptest/commom/widgets/animetes_list_item.dart';
import 'dart:async';
import '../../../commom/widgets/animate_button.dart';
import '../../../commom/widgets/categorized_recordings_list.dart';
import '../../data/models/recordings_model.dart';
import '../provider/auth/auth_provider.dart';
import '../provider/auth/get_sys_info_file_management.dart';

// Model classes for API responses
class TransferEvent {
  final String event;
  final String? filename;
  final int? size;
  final int? bytes;
  final double? percent;
  final String? path;
  final String? message;

  TransferEvent({
    required this.event,
    this.filename,
    this.size,
    this.bytes,
    this.percent,
    this.path,
    this.message,
  });

  factory TransferEvent.fromJson(Map<String, dynamic> json) {
    return TransferEvent(
      event: json['event'] ?? '',
      filename: json['filename'],
      size: json['size'],
      bytes: json['bytes'],
      percent: json['percent']?.toDouble(),
      path: json['path'],
      message: json['message'],
    );
  }
}

class Recordingscreen extends StatefulWidget {
  const Recordingscreen({super.key});

  @override
  State<Recordingscreen> createState() => _RecordingscreenState();
}

class _RecordingscreenState extends State<Recordingscreen> {
  late String baseUrl;
  late String? token;
  Set<RecordingFileModel> selectedRecordings = {};

  int? selectedDrive;

  
  final List<String> drivePaths = [
    '/mnt/external/exports',
    '/home/aman/exports',
    '/mnt/usb1/exports',
    '/mnt/usb2/exports',
    '/mnt/backup/exports',
  ];

  // Check if transfer button should be visible
  bool get shouldShowTransferButton {
    return selectedRecordings.isNotEmpty && selectedDrive != null;
  }

  // Transfer multiple files with progress tracking
  Future<void> _transferFiles() async {
    if (selectedRecordings.isEmpty || selectedDrive == null) return;

    final selectedFiles = selectedRecordings
        .map((recording) => recording.name ?? "Unknown")
        .toList();
    final destinationPath = drivePaths[selectedDrive!];

    await _showTransferDialog(selectedFiles, destinationPath);
  }

  // Show transfer progress dialog
  Future<void> _showTransferDialog(
    List<String> filenames,
    String destination,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TransferProgressDialog(
          filenames: filenames,
          destination: destination,
          onComplete: () {
            // Reset selections after successful transfer
            setState(() {
              selectedRecordings.clear();
              selectedDrive = null;
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialized(context);
  }

  Future<void> initialized(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final getSysInfoFileManagement = context.read<GetSysInfoFileManagement>();
    baseUrl = authProvider.baseUrl;
    token = await authProvider.getAuthToken();
    getSysInfoFileManagement.fetchAllRecordingsMock();
    if (token != null) {
      // getSysInfoFileManagement.fetchAllRecordings(
      //   baseUrl: baseUrl,
      //   token: token!,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final getSysInfoFileManagement = context.watch<GetSysInfoFileManagement>();
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: kToolbarHeight - 8),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      flex: 6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Recordings",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child:
                                getSysInfoFileManagement.recordingFileState ==
                                    RecordingFileState.loading
                                ? Center(child: CupertinoActivityIndicator())
                                : getSysInfoFileManagement.recordingFileState ==
                                      RecordingFileState.failed
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Text("Failed to get Recordings"),
                                    ),
                                  )
                                : getSysInfoFileManagement.allRecordingsFiles ==
                                      null
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Text("No Recordinngs found"),
                                    ),
                                  )
                                : CategorizedRecordingsList(
                                    allRecordingsFiles: getSysInfoFileManagement
                                        .allRecordingsFiles,
                                    selectedRecordings: selectedRecordings,
                                    onSelectionChanged: (recording) {
                                      // Change parameter type
                                      setState(() {
                                        if (selectedRecordings.contains(
                                          recording,
                                        )) {
                                          selectedRecordings.remove(recording);
                                        } else {
                                          selectedRecordings.add(recording);
                                        }
                                      });
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Drives",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child:
                                (getSysInfoFileManagement
                                        .systemInfoModel
                                        .isNotEmpty &&
                                    getSysInfoFileManagement
                                            .systemInfoModel[getSysInfoFileManagement
                                                    .systemInfoModel
                                                    .length -
                                                1]
                                            .hardDisk !=
                                        null &&
                                    getSysInfoFileManagement
                                            .systemInfoModel[getSysInfoFileManagement
                                                    .systemInfoModel
                                                    .length -
                                                1]
                                            .hardDisk
                                            ?.disks !=
                                        null &&
                                    getSysInfoFileManagement
                                        .systemInfoModel[getSysInfoFileManagement
                                                .systemInfoModel
                                                .length -
                                            1]
                                        .hardDisk!
                                        .disks!
                                        .isNotEmpty)
                                ? ListView.builder(
                                    itemCount: getSysInfoFileManagement
                                        .systemInfoModel[getSysInfoFileManagement
                                                .systemInfoModel
                                                .length -
                                            1]
                                        .hardDisk
                                        ?.disks
                                        ?.length, // show latest hardisk
                                    itemBuilder: (context, index) {
                                      bool isSelected = selectedDrive == index;
                                      final disk = getSysInfoFileManagement
                                          .systemInfoModel[getSysInfoFileManagement
                                                  .systemInfoModel
                                                  .length -
                                              1]
                                          .hardDisk
                                          ?.disks![index];
                                      return AnimatedListItem(
                                        delay: Duration(
                                          milliseconds: 250 * index,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: 8,
                                            bottom: 8,
                                            top: index == 0 ? 8 : 0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedDrive = isSelected
                                                    ? null
                                                    : index;
                                              });
                                            },
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.green.withValues(
                                                        alpha: 0.1,
                                                      )
                                                    : Colors.white,
                                                border: isSelected
                                                    ? Border.all(
                                                        color: Colors.green,
                                                        width: 1,
                                                      )
                                                    : Border.all(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 12,
                                              ),
                                              child: Row(
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons.hardDrive,
                                                    size: 16,
                                                    color: isSelected
                                                        ? Colors.green
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        disk?.name ?? "Unknown",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: isSelected
                                                                  ? Colors.green
                                                                  : null,
                                                            ),
                                                      ),
                                                      Text(
                                                        "Available: ${(disk?.totalGb ?? 0) - (disk?.usedGb ?? 0)}GB",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color: isSelected
                                                                  ? Colors.green
                                                                  : null,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(child: Text("No Derives Found !")),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Transfer button - only show when both recordings and drive are selected
          if (shouldShowTransferButton)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 0),
                child: AnimatedTurnOnButton(
                  onPressed: _transferFiles,
                  // onPressed: () async {
                  //   // Navigator.push(context, MaterialPageRoute(builder: (_)=>SystemInfoScreen()));
                  //   try {
                  //     final String response = await rootBundle.loadString(
                  //       'assets/sysinfo.json',
                  //     );
                  //     SystemInfoModel systemInfoModel= SystemInfoModel.fromJson(response);
                  //      dev.log(systemInfoModel.toString());
                  //   } catch (e, s) {
                  //     dev.log(
                  //       "Error loading temporary data",
                  //       error: e,
                  //       stackTrace: s,
                  //     );
                  //   }
                  // },
                  text: "Transfer (${selectedRecordings.length})",
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Transfer Progress Dialog Widget
class TransferProgressDialog extends StatefulWidget {
  final List<String> filenames;
  final String destination;
  final VoidCallback onComplete;

  const TransferProgressDialog({
    super.key,
    required this.filenames,
    required this.destination,
    required this.onComplete,
  });

  @override
  State<TransferProgressDialog> createState() => _TransferProgressDialogState();
}

class _TransferProgressDialogState extends State<TransferProgressDialog> {
  int currentFileIndex = 0;
  double currentProgress = 0.0;
  String currentStatus = 'Preparing...';
  bool isTransferring = false;
  bool hasError = false;
  String? errorMessage;
  int totalBytes = 0;
  int transferredBytes = 0;

  @override
  void initState() {
    super.initState();
    _startTransfer();
  }

  Future<void> _startTransfer() async {
    setState(() {
      isTransferring = true;
      hasError = false;
    });

    try {
      for (int i = 0; i < widget.filenames.length; i++) {
        setState(() {
          currentFileIndex = i;
          currentProgress = 0.0;
          currentStatus = 'Transferring ${widget.filenames[i]}...';
        });

        await _transferSingleFile(widget.filenames[i]);

        if (hasError) break;
      }

      if (!hasError) {
        setState(() {
          currentStatus = 'Transfer completed successfully!';
          currentProgress = 1.0;
        });

        // Wait a moment then close
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onComplete();
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        currentStatus = 'Transfer failed';
      });
    } finally {
      setState(() {
        isTransferring = false;
      });
    }
  }

  Future<void> _transferSingleFile(String filename) async {
    // Mock implementation with realistic scenarios
    await _mockTransferWithProgress(filename);
  }

  Future<void> _mockTransferWithProgress(String filename) async {
    try {
      // Simulate random file sizes (10MB to 500MB)
      final random = DateTime.now().millisecondsSinceEpoch % 1000;
      final fileSize = (10 + (random % 490)) * 1024 * 1024; // 10MB to 500MB

      // Simulate different scenarios based on filename
      if (filename.contains('3') || filename.contains('7')) {
        // Simulate failure for files containing '3' or '7'
        await _simulateFailureScenario(filename, fileSize);
        return;
      }

      // Start event
      await _handleMockEvent({
        'event': 'start',
        'filename': filename,
        'size': fileSize,
      });

      // Simulate transfer with progress updates
      const totalSteps = 50;
      for (int step = 1; step <= totalSteps; step++) {
        if (!mounted) return;

        // Simulate variable transfer speed (sometimes slower, sometimes faster)
        int delay = 50 + (step % 7) * 20; // 50-170ms delays
        await Future.delayed(Duration(milliseconds: delay));

        final progress = step / totalSteps;
        final bytes = (fileSize * progress).round();
        final percent = progress * 100;

        await _handleMockEvent({
          'event': 'progress',
          'bytes': bytes,
          'percent': percent,
        });
      }

      // Done event
      await _handleMockEvent({
        'event': 'done',
        'path': '${widget.destination}/$filename',
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to transfer $filename: $e';
      });
      rethrow;
    }
  }

  Future<void> _simulateFailureScenario(String filename, int fileSize) async {
    // Start normally
    await _handleMockEvent({
      'event': 'start',
      'filename': filename,
      'size': fileSize,
    });

    // Progress for a while
    for (int step = 1; step <= 20; step++) {
      if (!mounted) return;

      await Future.delayed(Duration(milliseconds: 80));

      final progress = step / 50; // Only go to 40%
      final bytes = (fileSize * progress).round();
      final percent = progress * 100;

      await _handleMockEvent({
        'event': 'progress',
        'bytes': bytes,
        'percent': percent,
      });
    }

    // Simulate different types of failures
    final failureMessages = [
      'Network connection lost',
      'Insufficient space on destination drive',
      'File access denied',
      'Destination drive disconnected',
      'Transfer timeout occurred',
    ];

    final errorMessage =
        failureMessages[DateTime.now().millisecondsSinceEpoch %
            failureMessages.length];

    await _handleMockEvent({'event': 'error', 'message': errorMessage});
  }

  Future<void> _handleMockEvent(Map<String, dynamic> eventData) async {
    final event = TransferEvent.fromJson(eventData);

    if (!mounted) return;

    switch (event.event) {
      case 'start':
        setState(() {
          totalBytes = event.size ?? 0;
          currentProgress = 0.0;
        });
        break;

      case 'progress':
        setState(() {
          transferredBytes = event.bytes ?? 0;
          currentProgress = (event.percent ?? 0) / 100;
        });
        break;

      case 'done':
        setState(() {
          currentProgress = 1.0;
        });
        return; // Exit this file's stream

      case 'error':
        setState(() {
          hasError = true;
          errorMessage = event.message ?? 'Unknown error';
        });
        throw Exception(event.message ?? 'Transfer error');
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Transferring Files'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall progress
            Text(
              'File ${currentFileIndex + 1} of ${widget.filenames.length}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Current file name
            if (currentFileIndex < widget.filenames.length)
              Text(
                widget.filenames[currentFileIndex],
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: currentProgress,
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                hasError ? Colors.red : Colors.blue,
              ),
            ),
            SizedBox(height: 8),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(currentProgress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (totalBytes > 0)
                  Text(
                    '${_formatBytes(transferredBytes)} / ${_formatBytes(totalBytes)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Status message
            Text(
              currentStatus,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: hasError ? Colors.red : null,
              ),
            ),

            // Error message
            if (hasError && errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (hasError || (!isTransferring && currentProgress >= 1.0))
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (!hasError) {
                widget.onComplete();
              }
            },
            child: Text(hasError ? 'Close' : 'OK'),
          ),
      ],
    );
  }
}
