import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/diagnosis_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(diagnosisStatisticsProvider);
    final users = ref.watch(usersProvider);
    final diagnoses = ref.watch(diagnosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
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
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: statistics.when(
          data: (stats) => _buildStatisticsPage(context, stats, users, diagnoses),
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
                  'Failed to load statistics',
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

  Widget _buildStatisticsPage(
    BuildContext context,
    Map<String, dynamic> stats,
    AsyncValue<List<UserModel>> users,
    AsyncValue<List<DiagnosisModel>> diagnoses,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    // Convert diagnoses per day data to chart format
    List<({String date, int count})> diagnosesPerDayData = [];
    final diagnosesPerDay = stats['diagnosesPerDay'] as Map<String, dynamic>?;
    if (diagnosesPerDay != null) {
      diagnosesPerDayData = diagnosesPerDay.entries
          .map((e) => (date: e.key, count: e.value as int))
          .toList();
    }

    // Convert diagnoses per month data to chart format
    List<({String date, int count})> diagnosesPerMonthData = [];
    final diagnosesPerMonth = stats['diagnosesPerMonth'] as Map<String, dynamic>?;
    if (diagnosesPerMonth != null) {
      diagnosesPerMonthData = diagnosesPerMonth.entries
          .map((e) => (date: e.key, count: e.value as int))
          .toList();
    }

    // Convert diagnosis by type data to chart format
    List<({String name, int count})> diagnosisByTypeData = [];
    final diagnosisByType = stats['diagnosisByType'] as Map<String, dynamic>?;
    if (diagnosisByType != null) {
      diagnosisByTypeData = diagnosisByType.entries
          .map((e) => (name: e.key, count: e.value as int))
          .toList();
      
      // Sort by count in descending order
      diagnosisByTypeData.sort((a, b) => b.count.compareTo(a.count));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EyeCheckAI Statistics',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of diagnoses and user activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 24),

          // Summary Cards
          _buildSummaryCards(context, stats, isWideScreen, isMediumScreen),
          const SizedBox(height: 24),

          // Time Charts
          Text(
            'Time Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LineChartWidget(
                        data: diagnosesPerMonthData,
                        title: 'Monthly Diagnoses',
                        subtitle: 'Number of diagnoses per month',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LineChartWidget(
                        data: diagnosesPerDayData,
                        title: 'Daily Diagnoses',
                        subtitle: 'Number of diagnoses per day',
                      ),
                    ),
                  ],
                )
              // : Column(
              //     children: [
              //       LineChartWidget(
              //         data: diagnosesPerMonthData,
              //         title: 'Monthly Diagnoses',
              //         subtitle: 'Number of diagnoses per month',
              //       ),
              //       const SizedBox(height: 16),
              //       LineChartWidget(
              //         data: diagnosesPerDayData,
              //         title: 'Daily Diagnoses',
              //         subtitle: 'Number of diagnoses per day',
              //       ),
              //     ],
              //   ),
         : const SizedBox(height: 24),

          // Diagnosis Distribution
          Text(
            'Diagnosis Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          PieChartWidget(
            data: diagnosisByTypeData,
            title: 'Diagnosis Types',
            subtitle: 'Distribution of different diagnosis types',
          ),
          const SizedBox(height: 24),

          // Diagnosis Type Table
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most Common Eye Conditions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  diagnosisByTypeData.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Text('No diagnosis data available'),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Rank')),
                              DataColumn(label: Text('Condition')),
                              DataColumn(label: Text('Count')),
                              DataColumn(label: Text('Percentage')),
                            ],
                            rows: [
                              for (int i = 0; i < diagnosisByTypeData.length && i < 10; i++)
                                DataRow(
                                  cells: [
                                    DataCell(Text('${i + 1}')),
                                    DataCell(Text(diagnosisByTypeData[i].name)),
                                    DataCell(Text('${diagnosisByTypeData[i].count}')),
                                    DataCell(Text('${(diagnosisByTypeData[i].count * 100 / (stats['totalDiagnoses'] as int? ?? 1)).toStringAsFixed(1)}%')),
                                  ],
                                ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top Diagnosis and Active Users
          Text(
            'Top Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTopDiagnoses(context, stats),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMostActiveUsers(context, stats),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildTopDiagnoses(context, stats),
                    const SizedBox(height: 16),
                    _buildMostActiveUsers(context, stats),
                  ],
                ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context, 
    Map<String, dynamic> stats, 
    bool isWideScreen, 
    bool isMediumScreen
  ) {
    final totalDiagnoses = stats['totalDiagnoses'] as int? ?? 0;
    final uniqueUsers = stats['uniqueUsers'] as int? ?? 0;
    final totalUsers = stats['totalUsers'] as int? ?? 0;
    final diagnosisTypes = (stats['diagnosisByType'] as Map<String, dynamic>?)?.length ?? 0;

return GridView.count(
  crossAxisCount: isWideScreen ? 3 : (isMediumScreen ? 3 : 1),
  crossAxisSpacing: 16,
  mainAxisSpacing: 16,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    _buildSummaryCard(
      context,
      title: 'Total Diagnoses',
      value: totalDiagnoses.toString(),
      icon: Icons.healing_rounded,
      iconColor: AppTheme.primaryColor,
    ),
    _buildSummaryCard(
      context,
      title: 'Active Users',
      value: uniqueUsers.toString(),
      subtitle: 'Out of $totalUsers total users',
      icon: Icons.people_alt_rounded,
      iconColor: AppTheme.secondaryColor,
    ),
    _buildSummaryCard(
      context,
      title: 'Average Diagnoses',
      value: uniqueUsers > 0 ? (totalDiagnoses / uniqueUsers).toStringAsFixed(1) : '0',
      subtitle: 'Per active user',
      icon: Icons.analytics_rounded,
      iconColor: AppTheme.warningColor,
    ),
  ],
);
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    String? subtitle,
    Color? iconColor,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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

  Widget _buildMostActiveUsers(BuildContext context, Map<String, dynamic> stats) {
    final mostActiveDiagnosers = stats['mostActiveDiagnosers'] as List<dynamic>?;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Active Users',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Users with the most diagnoses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (mostActiveDiagnosers == null || mostActiveDiagnosers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text('No user activity data available'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mostActiveDiagnosers.length,
                itemBuilder: (context, index) {
                  final user = mostActiveDiagnosers[index] as Map<String, dynamic>;
                  final name = user['name'] as String? ?? user['email'] as String? ?? 'Unknown';
                  final count = user['count'] as int? ?? 0;
                  
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}