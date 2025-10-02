import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReports(context),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'User Activity'),
                Tab(text: 'Progress Reports'),
                Tab(text: 'Usage Analytics'),
                Tab(text: 'System Metrics'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserActivityReport(),
                  _buildProgressReport(),
                  _buildUsageAnalytics(),
                  _buildSystemMetrics(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterDialog(context),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildUserActivityReport() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Active Users',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  // Add chart widget here
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Active Users Chart')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('User Action ${index + 1}'),
                      subtitle: Text('Action details ${index + 1}'),
                      trailing: Text(
                        '${DateTime.now().subtract(Duration(hours: index))}',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressReport() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  // Add progress chart widget here
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Progress Chart')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageAnalytics() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usage Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  // Add usage statistics widget here
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('Usage Statistics')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemMetrics() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  // Add system metrics widget here
                  color: Colors.grey.shade200,
                  child: const Center(child: Text('System Metrics')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Reports'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date Range',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'User Type',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Metrics',
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                // Apply filters
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _exportReports(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Reports'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () {
                  // Export as PDF
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export as Excel'),
                onTap: () {
                  // Export as Excel
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Export as CSV'),
                onTap: () {
                  // Export as CSV
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
