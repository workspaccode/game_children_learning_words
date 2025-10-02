import 'package:flutter/material.dart';

class SystemMetrics extends StatelessWidget {

  const SystemMetrics({super.key, required this.metrics});
  final Map<String, dynamic> metrics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricRow(
              context,
              'CPU Usage',
              metrics['cpuUsage']?.toString() ?? '0%',
              _getUsageColor(metrics['cpuUsage'] as num? ?? 0),
              Icons.memory,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Memory Usage',
              metrics['memoryUsage']?.toString() ?? '0%',
              _getUsageColor(metrics['memoryUsage'] as num? ?? 0),
              Icons.storage,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Storage Usage',
              metrics['storageUsage']?.toString() ?? '0%',
              _getUsageColor(metrics['storageUsage'] as num? ?? 0),
              Icons.sd_storage,
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              context,
              'Network Latency',
              '${metrics['networkLatency']?.toString() ?? '0'} ms',
              _getLatencyColor(metrics['networkLatency'] as num? ?? 0),
              Icons.network_check,
            ),
            if (metrics['errors'] != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Recent Errors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildErrorList(metrics['errors'] as List),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _parseMetricValue(value),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildErrorList(List errors) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: errors.length,
        itemBuilder: (context, index) {
          final error = errors[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _parseMetricValue(String value) {
    try {
      if (value.endsWith('%')) {
        return double.parse(value.replaceAll('%', '')) / 100;
      }
      if (value.endsWith('ms')) {
        final ms = double.parse(value.replaceAll('ms', '').trim());
        return (ms / 1000).clamp(0.0, 1.0);
      }
      return double.parse(value).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  Color _getUsageColor(num value) {
    if (value >= 90) return Colors.red;
    if (value >= 75) return Colors.orange;
    if (value >= 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  Color _getLatencyColor(num value) {
    if (value >= 500) return Colors.red;
    if (value >= 200) return Colors.orange;
    if (value >= 100) return Colors.yellow[700]!;
    return Colors.green;
  }
}
