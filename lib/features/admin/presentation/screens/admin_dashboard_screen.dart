import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readingquest_bilingual_learning/features/admin/presentation/widgets/error_view.dart';
import 'package:readingquest_bilingual_learning/features/admin/presentation/widgets/loading_view.dart';

import '../bloc/admin_bloc.dart';
import '../widgets/activity_list.dart';
import '../widgets/stats_card.dart';
import '../widgets/system_metrics.dart';
import '../widgets/users_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    context.read<AdminBloc>().add(const AdminLoadDashboardEvent());
    context.read<AdminBloc>().add(const AdminWatchSystemStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const LoadingView();
          }

          if (state is AdminError) {
            return ErrorViewWithMessage(message: state.message, onRetry: _loadDashboard);
          }

          if (state is AdminDashboardLoaded) {
            final userStats =
                state.dashboardData['userStats'] as Map<String, dynamic>;
            final activityStats =
                state.dashboardData['activityStats'] as Map<String, dynamic>;
            final systemMetrics =
                state.dashboardData['systemMetrics'] as Map<String, dynamic>;

            return RefreshIndicator(
              onRefresh: () async => _loadDashboard(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Overview
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Total Children',
                              value: userStats['totalChildren'].toString(),
                              icon: Icons.child_care,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              title: 'Total Parents',
                              value: userStats['totalParents'].toString(),
                              icon: Icons.people,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatsCard(
                              title: 'Total Teachers',
                              value: userStats['totalTeachers'].toString(),
                              icon: Icons.school,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Users Chart
                      const Text(
                        'User Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(height: 300, child: UsersChart(data: userStats)),
                      const SizedBox(height: 24),

                      // Recent Activities
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activities',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to detailed activity view
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ActivityList(
                        activities: List<Map<String, dynamic>>.from(
                          activityStats['recentActivities'] as List<dynamic>,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // System Metrics
                      const Text(
                        'System Metrics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SystemMetrics(metrics: systemMetrics),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create report screen
          Navigator.pushNamed(context, '/admin/reports/create');
        },
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
