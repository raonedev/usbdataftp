
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:usbdataftptest/commom/widgets/animetes_list_item.dart';
import 'dart:async';
import '../../../commom/widgets/animate_button.dart';

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
  // Track selected recordings (using Set to allow multiple selections)
  Set<int> selectedRecordings = {};

  // Track selected drive (only one drive can be selected)
  int? selectedDrive;

  // Sample data - replace with your actual data
  final List<String> recordingNames = List.generate(
    10,
    (index) => "Recording_${index + 1}_08_2025",
  );
  final List<String> driveNames = List.generate(
    5,
    (index) => "Disk ${index + 1}",
  );
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
        .map((index) => recordingNames[index])
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exports Recordings"),
        leading: SizedBox.shrink(),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Recordings",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedRecordings.contains(index);
                          return AnimatedListItem(
                            delay: Duration(milliseconds: 100 * index), 
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                top: index == 0 ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedRecordings.remove(index);
                                    } else {
                                      selectedRecordings.add(index);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : Colors.white,
                                    border: isSelected
                                        ? Border.all(color: Colors.blue, width: 1)
                                        : Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: CupertinoListTile(
                                    padding: EdgeInsets.only(left: 8),
                                    title: Text(
                                      recordingNames[index],
                                      style: Theme.of(context).textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Colors.blue
                                                : null,
                                          ),
                                    ),
                                    subtitle: Text(
                                      "2025-08-02 17:19:48",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: isSelected
                                                ? Colors.blue
                                                : null,
                                          ),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    leadingSize: 60,
                                    trailing: CupertinoCheckbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedRecordings.add(index);
                                          } else {
                                            selectedRecordings.remove(index);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Drives",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedDrive == index;

                          return AnimatedListItem(
                            delay: Duration(milliseconds: 250 * index), 
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 8,
                                bottom: 8,
                                top: index == 0 ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDrive = isSelected ? null : index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.green.withValues(alpha: 0.1)
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
                                    borderRadius: BorderRadius.circular(12),
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
                                        color: isSelected ? Colors.green : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            driveNames[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.green
                                                      : null,
                                                ),
                                          ),
                                          Text(
                                            "Available: ${index + 1}GB",
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
    if (bytes < 1024) return '${bytes} B';
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
