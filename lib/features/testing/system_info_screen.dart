import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:usbdataftptest/features/data/models/sys_info_model.dart';
import 'package:usbdataftptest/features/testing/system_info_provider.dart';

// Import your models and provider here
// import 'system_info_provider.dart';
// import 'your_models.dart';

class SystemInfoScreen extends StatefulWidget {
  const SystemInfoScreen({super.key});

  @override
  State<SystemInfoScreen> createState() => _SystemInfoScreenState();
}

class _SystemInfoScreenState extends State<SystemInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemInfoProvider>().startListening();
    });
  }

  @override
  void dispose() {
    // Stop listening when leaving the screen
    context.read<SystemInfoProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Monitor'),
        actions: [
          Consumer<SystemInfoProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Connection status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: provider.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isConnected ? 'Connected' : 'Disconnected',
                    style: TextStyle(
                      color: provider.isConnected ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Reconnect button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: provider.reconnect,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<SystemInfoProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.reconnect,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.currentData == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Waiting for data...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Charts Section
                _buildChartsSection(provider),
                const SizedBox(height: 24),
                // Storage & Disk Info Section
                _buildStorageSection(provider.currentData!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartsSection(SystemInfoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Charts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // RAM Chart
        _buildChartCard(
          title: 'RAM Usage (%)',
          chart: _buildLineChart(
            provider.ramUsageHistory,
            Colors.blue,
            maxY: 100,
          ),
          currentValue: provider.currentData?.ram?.usagePercentage?.toStringAsFixed(1) ?? 'N/A',
          unit: '%',
        ),
        
        const SizedBox(height: 16),
        
        // CPU Chart
        _buildChartCard(
          title: 'CPU Usage (%)',
          chart: _buildLineChart(
            provider.cpuUsageHistory,
            Colors.red,
            maxY: 100,
          ),
          currentValue: provider.currentData?.cpu?.usagePercent?.toString() ?? 'N/A',
          unit: '%',
        ),
        
        const SizedBox(height: 16),
        
        // Network Chart
        _buildNetworkChart(provider),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget chart,
    required String currentValue,
    required String unit,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$currentValue$unit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> data, Color color, {double maxY = 100}) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkChart(SystemInfoProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network Speed (KiB/s)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '↑ ${provider.currentData?.network?.uploadSpeedKIB?.toStringAsFixed(1) ?? 'N/A'} KiB/s',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '↓ ${provider.currentData?.network?.downloadSpeedKib?.toStringAsFixed(1) ?? 'N/A'} KiB/s',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildNetworkLineChart(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkLineChart(SystemInfoProvider provider) {
    final uploadData = provider.networkUploadHistory;
    final downloadData = provider.networkDownloadHistory;
    
    if (uploadData.isEmpty || downloadData.isEmpty) {
      return const Center(child: Text('No network data available'));
    }

    final maxValue = [
      ...uploadData,
      ...downloadData,
    ].reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (uploadData.length - 1).toDouble(),
        minY: 0,
        maxY: maxValue * 1.2,
        lineBarsData: [
          // Upload line
          LineChartBarData(
            spots: uploadData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            // strokeWidth: 2,
            dotData: FlDotData(show: false),
          ),
          // Download line
          LineChartBarData(
            spots: downloadData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value);
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            // strokeWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection(SystemInfoModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Storage Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Overall Storage
        if (data.storage != null) _buildStorageCard(data.storage!),
        
        const SizedBox(height: 16),
        
        // Individual Disks
        const Text(
          'Disk Drives',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        
        if (data.hardDisk?.disks != null) ...[
          ...data.hardDisk!.disks!.map((disk) => _buildDiskCard(disk)),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No disk information available'),
            ),
          ),
      ],
    );
  }

  Widget _buildStorageCard(Storage storage) {
    final usedGB = storage.usedGb ?? 0;
    final totalGB = storage.totalGb ?? 0;
    final usagePercent = totalGB > 0 ? (usedGB / totalGB * 100) : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Storage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usagePercent / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                usagePercent > 80 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Used: ${usedGB}GB'),
                Text('Total: ${totalGB}GB'),
              ],
            ),
            Text(
              'Usage: ${usagePercent.toStringAsFixed(1)}%',
              style: TextStyle(
                color: usagePercent > 80 ? Colors.red : Colors.green, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiskCard(Disk disk) {
    final usedGB = disk.usedGb ?? 0;
    final totalGB = disk.totalGb ?? 0;
    final usagePercent = totalGB > 0 ? (usedGB / totalGB * 100) : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: disk.status == 'Healthy' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  disk.name ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: disk.status == 'Healthy' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    disk.status ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (totalGB > 0) ...[
              LinearProgressIndicator(
                value: usagePercent / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  usagePercent > 80 ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Used: ${usedGB}GB'),
                  Text('Total: ${totalGB}GB'),
                ],
              ),
              Text('Usage: ${usagePercent.toStringAsFixed(1)}%'),
            ] else
              const Text('No size information available'),
            if (disk.mountedPointPath != null) ...[
              const SizedBox(height: 4),
              Text(
                'Mount: ${disk.mountedPointPath}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}