import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:opt_app/library/opt_app.dart';
import 'package:opt_app/models/savedDiagnosis.dart';
import 'package:opt_app/widgets/dashboard_card_widget.dart';
import 'package:opt_app/widgets/line_chart_widget.dart';
import 'package:opt_app/widgets/pie_chart_widget.dart';
import 'package:opt_app/widgets/bar_chart_widget.dart';
import 'package:opt_app/utils/date_range_utils.dart';
import 'package:opt_app/utils/diagnosis_analyzer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late Box<SavedDiagnosis> diagnosesBox;
  late TabController _tabController;
  DateTimeRange _dateRange = DateRangeUtils.getCurrentMonthRange();
  String _searchQuery = '';
  bool _isLoading = true;
  
  // Dashboard data
  late Map<String, dynamic> _dashboardData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    diagnosesBox = Hive.box<SavedDiagnosis>('diagnoses');
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Use DiagnosisAnalyzer to process the data
    final analyzer = DiagnosisAnalyzer(
      diagnoses: diagnosesBox.values.toList(),
      dateRange: _dateRange,
      searchQuery: _searchQuery,
    );

    _dashboardData = await analyzer.generateDashboardData();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  void _updateDateRange(DateTimeRange newRange) {
    setState(() {
      _dateRange = newRange;
    });
    _loadDashboardData();
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadDashboardData();
  }

  Future<void> _exportData(String format) async {
    // Implementation for exporting data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data as $format...'),
      ),
    );
    // Actual export implementation would go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard Insights",
          style: AppTypography().largeSemiBold.copyWith(
                color: AppColors.white,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Trends"),
            Tab(text: "Diagnoses"),
            Tab(text: "Patients"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildExportOptions(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _buildFilterOptions(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrendsTab(),
                _buildDiagnosesTab(),
                _buildPatientsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Stats",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: "Total Diagnoses",
                    value: _dashboardData['totalDiagnoses'].toString(),
                    icon: Icons.analytics,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: "Avg. Per Day",
                    value: _dashboardData['averagePerDay'].toStringAsFixed(1),
                    icon: Icons.calendar_today,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: "Active Patients",
                    value: _dashboardData['uniquePatients'].toString(),
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DashboardCard(
                    title: "Top Diagnosis",
                    value: _dashboardData['mostCommonDiagnosis'] ?? 'N/A',
                    icon: Icons.local_hospital,
                    color: Colors.teal,
                    isSmallText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Visit Trends",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChartWidget(
                data: _dashboardData['visitTrends'],
                dateRange: _dateRange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Diagnosis Distribution",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChartWidget(
                data: _dashboardData['diagnosisDistribution'],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Busiest Days",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChartWidget(
                data: _dashboardData['busiestDays'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient Visit Trends",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChartWidget(
                data: _dashboardData['visitTrends'],
                dateRange: _dateRange,
                showDetails: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Peak Activity Days",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChartWidget(
                data: _dashboardData['busiestDays'],
                showDetails: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Monthly Comparison",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChartWidget(
                data: _dashboardData['monthlyComparison'],
                isGrouped: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosesTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Most Common Diagnoses",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChartWidget(
                data: _dashboardData['diagnosisDistribution'],
                showLegend: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Diagnosis Trends Over Time",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChartWidget(
                data: _dashboardData['diagnosisTrends'],
                dateRange: _dateRange,
                showMultipleLines: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Diagnosis Outcome Heatmap",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.gray.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "Heatmap visualization",
                  style: AppTypography().baseMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    final topPatients = _dashboardData['topReturningPatients'] as List;
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top Returning Patients",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topPatients.length,
              itemBuilder: (context, index) {
                final patient = topPatients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['name'] ?? 'Unknown',
                                style: AppTypography().largeSemiBold.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event_repeat, size: 16, color: AppColors.gray.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Visits: ${patient['visitCount']}',
                                    style: AppTypography().smallMedium.copyWith(
                                      color: AppColors.gray.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.calendar_today, size: 16, color: AppColors.gray.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Last: ${patient['lastVisit']}',
                                    style: AppTypography().smallMedium.copyWith(
                                      color: AppColors.gray.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              if (patient['email'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.email, size: 16, color: AppColors.gray.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      patient['email'],
                                      style: AppTypography().smallMedium.copyWith(
                                        color: AppColors.gray.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (patient['phone'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: AppColors.gray.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      patient['phone'],
                                      style: AppTypography().smallMedium.copyWith(
                                        color: AppColors.gray.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // IconButton(
                        //   icon: Icon(
                        //     Icons.arrow_forward_ios,
                        //     size: 16,
                        //     color: AppColors.primary,
                        //   ),
                        //   onPressed: () {
                        //     // Navigate to patient details
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              "No-Show Rate",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.gray.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(_dashboardData['noShowRate'] * 100).toStringAsFixed(1)}%",
                    style: AppTypography().xxlBold.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No-Show Rate",
                    style: AppTypography().baseMedium,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _dashboardData['noShowRate'],
                    backgroundColor: AppColors.gray.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Follow-Up Suggestions",
              style: AppTypography().largeBold,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dashboardData['followUpSuggestions'].length,
              itemBuilder: (context, index) {
                final suggestion = _dashboardData['followUpSuggestions'][index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: suggestion['isDue'] == true
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: suggestion['isDue'] == true
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion['patientName'] ?? 'Unknown',
                                style: AppTypography().baseSemiBold.copyWith(
                                  color: AppColors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'Due for follow-up: ',
                                    style: AppTypography().smallMedium.copyWith(
                                      color: AppColors.gray.shade700,
                                    ),
                                  ),
                                  Text(
                                    suggestion['dueDate'],
                                    style: AppTypography().smallSemiBold.copyWith(
                                      color: suggestion['isDue'] == true
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Schedule follow-up
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Schedule'),
                        ),
                      ],
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

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter Dashboard",
            style: AppTypography().largeBold,
          ),
          const SizedBox(height: 16),
          Text(
            "Date Range",
            style: AppTypography().baseSemiBold,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateDateRange(DateRangeUtils.getLastWeekRange());
                    Navigator.pop(context);
                  },
                  child: const Text("Last Week"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateDateRange(DateRangeUtils.getCurrentMonthRange());
                    Navigator.pop(context);
                  },
                  child: const Text("This Month"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _updateDateRange(DateRangeUtils.getLastThreeMonthsRange());
                    Navigator.pop(context);
                  },
                  child: const Text("3 Months"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Custom Date Range",
            style: AppTypography().baseSemiBold,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                _updateDateRange(picked);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.date_range),
                const SizedBox(width: 8),
                Text("Select Date Range"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Search Patient",
            style: AppTypography().baseSemiBold,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: "Search by patient name",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _updateSearchQuery(value);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Apply Filters"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Export Dashboard Data",
            style: AppTypography().largeBold,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text("Export as PDF", style: AppTypography().baseSemiBold),
            onTap: () {
              Navigator.pop(context);
              _exportData('PDF');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: Text("Export as CSV", style: AppTypography().baseSemiBold),
            onTap: () {
              Navigator.pop(context);
              _exportData('CSV');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.blue),
            title: Text("Share Report", style: AppTypography().baseSemiBold),
            onTap: () {
              Navigator.pop(context);
              // Implement share functionality
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}