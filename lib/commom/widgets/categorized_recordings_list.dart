import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/data/models/recordings_model.dart';

class CategorizedRecordingsList extends StatefulWidget {
  final AllRecordingsFiles? allRecordingsFiles;
  final Set<RecordingFileModel> selectedRecordings;
  final Function(RecordingFileModel) onSelectionChanged;

  const CategorizedRecordingsList({
    super.key,
    required this.allRecordingsFiles,
    required this.selectedRecordings,
    required this.onSelectionChanged,
  });

  @override
  State<CategorizedRecordingsList> createState() =>
      _CategorizedRecordingsListState();
}

class _CategorizedRecordingsListState extends State<CategorizedRecordingsList> {
  // ignore: constant_identifier_names
  static const int ITEMS_PER_PAGE = 50;

  Map<String, Map<String, List<RecordingFileModel>>> categorizedRecordings = {};
  Map<String, bool> expandedDevices = {};
  Map<String, bool> expandedDates = {};

  // Cache for recording indices to avoid repeated indexOf calls
  // final Map<RecordingFileModel, int> _recordingIndexCache = {};

  // Pagination support
  Map<String, int> currentPage = {};

  @override
  void initState() {
    super.initState();
    _categorizeRecordings();
  }

  @override
  void didUpdateWidget(CategorizedRecordingsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allRecordingsFiles != widget.allRecordingsFiles) {
      _categorizeRecordings();
    }
  }

  @override
  void dispose() {
    // _recordingIndexCache.clear();
    currentPage.clear();
    super.dispose();
  }

  void _categorizeRecordings() {
    categorizedRecordings.clear();
    // _recordingIndexCache.clear();
    currentPage.clear();

    if (widget.allRecordingsFiles?.recordings == null) return;

    // Build index cache for O(1) lookups
    // for (int i = 0; i < widget.allRecordingsFiles!.recordings.length; i++) {
    //   _recordingIndexCache[widget.allRecordingsFiles!.recordings[i]] = i;
    // }

    for (var recording in widget.allRecordingsFiles!.recordings) {
      if (recording.path != null) {
        final pathParts = recording.path!.split('/');
        final videoRecordingIndex = pathParts.indexOf('VideoRecording');

        if (videoRecordingIndex == -1 ||
            pathParts.length < videoRecordingIndex + 3) {
          continue;
        }

        final deviceId = pathParts[videoRecordingIndex + 1];
        final date = pathParts[videoRecordingIndex + 2];

        categorizedRecordings.putIfAbsent(deviceId, () => {});
        categorizedRecordings[deviceId]!.putIfAbsent(date, () => []);
        categorizedRecordings[deviceId]![date]!.add(recording);
      }
    }
  }

  Widget _buildDeviceIcon(bool isExpanded) {
    return HugeIcon(
      icon: isExpanded
          ? HugeIcons.strokeRoundedFolder02
          : HugeIcons.strokeRoundedFolder01,
      color: isExpanded ? Colors.blue : Colors.orangeAccent,
      size: 20,
    );
  }

  Widget _buildArrowIcon(bool isExpanded) {
    return HugeIcon(
      icon: isExpanded
          ? HugeIcons.strokeRoundedArrowDown01
          : HugeIcons.strokeRoundedArrowRight01,
      color: Colors.black54,
      size: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allRecordingsFiles == null || categorizedRecordings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFolderSearch,
              color: Colors.grey,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'No recordings available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: categorizedRecordings.keys.length,
      itemBuilder: (context, index) {
        final deviceId = categorizedRecordings.keys.elementAt(index);
        final isDeviceExpanded = expandedDevices[deviceId] ?? false;
        final totalFiles = categorizedRecordings[deviceId]!.values.fold(
          0,
          (sum, recordings) => sum + recordings.length,
        );

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                '$deviceId \n($totalFiles files)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildArrowIcon(isDeviceExpanded),
                  const SizedBox(width: 8),
                  _buildDeviceIcon(isDeviceExpanded),
                ],
              ),
              trailing: const SizedBox.shrink(),
              onExpansionChanged: (expanded) {
                setState(() {
                  expandedDevices[deviceId] = expanded;
                });
              },
              children: [
                // Only build dates list when device is expanded
                if (isDeviceExpanded)
                  _DatesList(
                    deviceId: deviceId,
                    datesMap: categorizedRecordings[deviceId]!,
                    expandedDates: expandedDates,
                    selectedRecordings: widget.selectedRecordings,
                    onSelectionChanged: widget.onSelectionChanged,
                    // recordingIndexCache: _recordingIndexCache,
                    currentPage: currentPage,
                    itemsPerPage: ITEMS_PER_PAGE,
                    onDateExpansionChanged: (dateKey, expanded) {
                      setState(() {
                        expandedDates[dateKey] = expanded;
                      });
                    },
                    onPageChanged: (dateKey, page) {
                      setState(() {
                        currentPage[dateKey] = page;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Separate widget for dates to improve build performance
class _DatesList extends StatelessWidget {
  final String deviceId;
  final Map<String, List<RecordingFileModel>> datesMap;
  final Map<String, bool> expandedDates;
  final Set<RecordingFileModel> selectedRecordings;
  final Function(RecordingFileModel) onSelectionChanged;
  // final Map<RecordingFileModel, int> recordingIndexCache;
  final Map<String, int> currentPage;
  final int itemsPerPage;
  final Function(String, bool) onDateExpansionChanged;
  final Function(String, int) onPageChanged;

  const _DatesList({
    required this.deviceId,
    required this.datesMap,
    required this.expandedDates,
    required this.selectedRecordings,
    required this.onSelectionChanged,
    // required this.recordingIndexCache,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onDateExpansionChanged,
    required this.onPageChanged,
  });

  Widget _buildArrowIcon(bool isExpanded) {
    return HugeIcon(
      icon: isExpanded
          ? HugeIcons.strokeRoundedArrowDown01
          : HugeIcons.strokeRoundedArrowRight01,
      color: Colors.black54,
      size: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: datesMap.keys.map((date) {
        final dateKey = '$deviceId-$date';
        final isDateExpanded = expandedDates[dateKey] ?? false;
        final recordings = datesMap[date]!;
        final selectedCount = recordings
            .where((r) => selectedRecordings.contains(r))
            .length;

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: ExpansionTile(
            visualDensity: const VisualDensity(horizontal: -4),
            title: Text(
              '$date \n(${recordings.length} files)',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            ),
            leading: _buildArrowIcon(isDateExpanded),
            trailing: selectedCount == 0
                ? SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
            onExpansionChanged: (expanded) {
              onDateExpansionChanged(dateKey, expanded);
            },
            children: [
              // Only build the recordings list when expanded
              if (isDateExpanded)
                _RecordingsList(
                  dateKey: dateKey,
                  recordings: recordings,
                  selectedRecordings: selectedRecordings,
                  onSelectionChanged: onSelectionChanged,
                  // recordingIndexCache: recordingIndexCache,
                  currentPage: currentPage,
                  itemsPerPage: itemsPerPage,
                  onPageChanged: onPageChanged,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Separate widget for recordings with ListView.builder and pagination for large datasets
class _RecordingsList extends StatelessWidget {
  final String dateKey;
  final List<RecordingFileModel> recordings;
  final Set<RecordingFileModel> selectedRecordings;
  final Function(RecordingFileModel) onSelectionChanged;
  // final Map<RecordingFileModel, int> recordingIndexCache;
  final Map<String, int> currentPage;
  final int itemsPerPage;
  final Function(String, int) onPageChanged;

  const _RecordingsList({
    required this.dateKey,
    required this.recordings,
    required this.selectedRecordings,
    required this.onSelectionChanged,
    // required this.recordingIndexCache,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = currentPage[dateKey] ?? 0;
    final totalPages = (recordings.length / itemsPerPage).ceil();
    final startIndex = currentPageIndex * itemsPerPage;
    final endIndex = math.min(startIndex + itemsPerPage, recordings.length);
    final pageRecordings = recordings.sublist(startIndex, endIndex);

    return Column(
      children: [
        // Recordings list
        Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: pageRecordings.length,
            itemBuilder: (context, index) {
              return _RecordingItem(
                recording: pageRecordings[index],
                isSelected: selectedRecordings.contains(
                  pageRecordings[index],
                ), // Direct comparison
                onTap: () {
                  onSelectionChanged(
                    pageRecordings[index],
                  ); // Pass the recording directly
                },
              );
            },
          ),
        ),

        // Pagination controls (only show if more than one page)
        if (totalPages > 1)
          _PaginationControls(
            currentPage: currentPageIndex,
            totalPages: totalPages,
            totalItems: recordings.length,
            itemsPerPage: itemsPerPage,
            onPageChanged: (page) => onPageChanged(dateKey, page),
          ),
      ],
    );
  }
}

// Pagination controls widget
class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;

  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final startItem = (currentPage * itemsPerPage) + 1;
    final endItem = math.min((currentPage + 1) * itemsPerPage, totalItems);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Page info
          Text(
            '$startItem-$endItem of $totalItems',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Spacer(),
          // Navigation buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous page
              InkWell(
                onTap: currentPage > 0
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),

              // Page indicator
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),

              // Next page
              InkWell(
                onTap: currentPage < totalPages - 1
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Separate widget for individual recording items
class _RecordingItem extends StatelessWidget {
  final RecordingFileModel recording;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecordingItem({
    required this.recording,
    required this.isSelected,
    required this.onTap,
  });

  String _formatFileSize(int? sizeInBytes) {
    if (sizeInBytes == null || sizeInBytes == 0) return '';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = sizeInBytes.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return ' • ${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 8, bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected
                    ? Colors.blue
                    : Colors.grey.withValues(alpha: 0.3),
                width: isSelected ? 1 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
              child: Row(
                children: [
                  // File icon
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedVideoReplay,
                    color: isSelected ? Colors.blue : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 12),

                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recording.name ?? "Unknown",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.blue : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (recording.size != null)
                          Text(
                            '${_formatFileSize(recording.size)}}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Checkbox
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoCheckbox(
                      value: isSelected,
                      onChanged: (value) => onTap(),
                      activeColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
