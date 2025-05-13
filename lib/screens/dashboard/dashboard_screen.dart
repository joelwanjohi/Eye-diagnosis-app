import 'package:admin_dashboard/services/admin_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/diagnosis_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(diagnosisStatisticsProvider);
    final users = ref.watch(usersProvider);
    final diagnoses = ref.watch(diagnosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(diagnosisStatisticsProvider);
              ref.refresh(usersProvider);
              ref.refresh(diagnosesProvider);
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context, ref),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: statistics.when(
          data: (stats) => _buildDashboard(context, stats, ref, users, diagnoses),
          loading: () => const Center(
            child: SpinKitPulse(
              color: AppTheme.primaryColor,
              size: 50.0,
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppTheme.errorColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load dashboard data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(diagnosisStatisticsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminFirebaseServiceProvider).logout();
      if (context.mounted) {
        context.go(AppConstants.loginRoute);
      }
    }
  }

  Widget _buildDashboard(
    BuildContext context,
    Map<String, dynamic> stats,
    WidgetRef ref,
    AsyncValue<List<UserModel>> users,
    AsyncValue<List<DiagnosisModel>> diagnoses,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Card(
            elevation: 0,
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    radius: 24,
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to EyeCheckAI Admin',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage users, diagnoses, and view statistics',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => context.push(AppConstants.reportsRoute),
                    icon: const Icon(Icons.summarize),
                    label: const Text('View Reports'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Overview Cards
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
// For three cards to fill the whole width
GridView.count(
  crossAxisCount: isWideScreen ? 3 : (isMediumScreen ? 3 : 1),
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    DashboardCard(
      title: 'Total Diagnoses',
      value: stats['totalDiagnoses']?.toString() ?? '0',
      icon: Icons.healing_rounded,
      iconColor: AppTheme.primaryColor,
      subtitle: 'All time',
      onTap: () => context.push(AppConstants.diagnosesRoute),
    ),
    DashboardCard(
      title: 'Total Users',
      value: stats['totalUsers']?.toString() ?? '0',
      icon: Icons.people_alt_rounded,
      iconColor: AppTheme.secondaryColor,
      onTap: () => context.push(AppConstants.usersRoute),
    ),
    DashboardCard(
      title: 'Active Users',
      value: stats['uniqueUsers']?.toString() ?? '0',
      icon: Icons.person_rounded,
      iconColor: AppTheme.accentColor,
      subtitle: 'Users with diagnoses',
    ),
  ],
),
          const SizedBox(height: 24),

          // Charts Section
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildDiagnosisChart(context, stats),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildDiagnosisTypeChart(context, stats),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildDiagnosisChart(context, stats),
                    const SizedBox(height: 16),
                    _buildDiagnosisTypeChart(context, stats),
                  ],
                ),
          const SizedBox(height: 24),

          // Recent Data Section
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildRecentDiagnoses(context, diagnoses),
                          const SizedBox(height: 16),
                          _buildTopDiagnoses(context, stats),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTopUsers(context, stats, users),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildRecentDiagnoses(context, diagnoses),
                    const SizedBox(height: 16),
                    _buildTopDiagnoses(context, stats),
                    const SizedBox(height: 16),
                    _buildTopUsers(context, stats, users),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisChart(BuildContext context, Map<String, dynamic> stats) {
    // Convert data to required format
    List<({String date, int count})> chartData = [];
    
    final diagnosesPerMonth = stats['diagnosesPerMonth'] as Map<String, dynamic>?;
    if (diagnosesPerMonth != null) {
      chartData = diagnosesPerMonth.entries
          .map((e) => (date: e.key, count: e.value as int))
          .toList();
    }

    return LineChartWidget(
      data: chartData,
      title: 'Diagnoses Over Time',
      subtitle: 'Monthly distribution of diagnoses',
    );
  }

  Widget _buildDiagnosisTypeChart(BuildContext context, Map<String, dynamic> stats) {
    // Convert data to required format
    List<({String name, int count})> chartData = [];
    
    final diagnosisByType = stats['diagnosisByType'] as Map<String, dynamic>?;
    if (diagnosisByType != null) {
      chartData = diagnosisByType.entries
          .map((e) => (name: e.key, count: e.value as int))
          .toList();
    }

    return PieChartWidget(
      data: chartData,
      title: 'Diagnosis Distribution',
      subtitle: 'Percentage of each diagnosis type',
    );
  }

  Widget _buildRecentDiagnoses(BuildContext context, AsyncValue<List<DiagnosisModel>> diagnoses) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Diagnoses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(AppConstants.diagnosesRoute),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            diagnoses.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No diagnoses yet'),
                    ),
                  );
                }

                final recentDiagnoses = data.take(5).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentDiagnoses.length,
                  itemBuilder: (context, index) {
                    final diagnosis = recentDiagnoses[index];
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surface,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          diagnosis.patientName ?? 'Unknown Patient',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormatter.formatISOToLocal(diagnosis.date)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: diagnosis.diagnosisList
                                  .take(2)
                                  .map((d) => Chip(
                                        label: Text(
                                          d.name,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                      ))
                                  .toList()
                                  ..addAll(diagnosis.diagnosisList.length > 2
                                      ? [
                                          Chip(
                                            label: Text(
                                              '+${diagnosis.diagnosisList.length - 2} more',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                            backgroundColor: AppTheme.textSecondaryColor.withOpacity(0.1),
                                          )
                                        ]
                                      : []),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => context.push('${AppConstants.diagnosesRoute}/${diagnosis.id}'),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading diagnoses: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUsers(
    BuildContext context,
    Map<String, dynamic> stats,
    AsyncValue<List<UserModel>> users,
  ) {
    final mostActiveDiagnosers = stats['mostActiveDiagnosers'] as List<dynamic>?;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Most Active Users',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push(AppConstants.usersRoute),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (mostActiveDiagnosers == null || mostActiveDiagnosers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No active users yet'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostActiveDiagnosers.length,
                itemBuilder: (context, index) {
                  final user = mostActiveDiagnosers[index] as Map<String, dynamic>;
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (user['name'] as String? ?? user['email'] as String? ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user['name'] as String? ?? user['email'] as String? ?? 'Unknown User',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text('${user['count']} diagnoses'),
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => context.push('${AppConstants.usersRoute}/${user['userId']}'),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDiagnoses(BuildContext context, Map<String, dynamic> stats) {
    final mostCommonDiagnoses = stats['mostCommonDiagnoses'] as List<dynamic>?;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Common Diagnoses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Top diagnoses by frequency',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (mostCommonDiagnoses == null || mostCommonDiagnoses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text('No diagnosis data available'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostCommonDiagnoses.length,
                itemBuilder: (context, index) {
                  final diagnosis = mostCommonDiagnoses[index] as Map<String, dynamic>;
                  final name = diagnosis['name'] as String? ?? 'Unknown';
                  final count = diagnosis['count'] as int? ?? 0;
                  
                  return _buildRankItem(
                    context, 
                    index + 1, 
                    name, 
                    '$count diagnoses',
                    AppTheme.chartColors[index % AppTheme.chartColors.length],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(
    BuildContext context,
    int rank,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rank.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}