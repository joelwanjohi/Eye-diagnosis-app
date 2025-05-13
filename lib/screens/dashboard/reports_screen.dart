import 'package:admin_dashboard/services/admin_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../models/diagnosis_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/export_utils.dart';

// For HTML downloads
import 'dart:html' as html;

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _reportFormat = 'pdf';
  bool _includeCharts = true;
  bool _includeUserInfo = true;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final diagnosesAsync = ref.watch(diagnosesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Reports',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create and export eye diagnosis reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Report Configuration
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Date Range
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            context,
                            label: 'Start Date',
                            value: _startDate,
                            onSelect: (date) {
                              setState(() {
                                _startDate = date;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            context,
                            label: 'End Date',
                            value: _endDate,
                            onSelect: (date) {
                              setState(() {
                                _endDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Export Format
                    Text(
                      'Export Format',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'pdf',
                          label: Text('PDF'),
                          icon: Icon(Icons.picture_as_pdf),
                        ),
                        ButtonSegment<String>(
                          value: 'csv',
                          label: Text('CSV'),
                          icon: Icon(Icons.table_chart),
                        ),
                        ButtonSegment<String>(
                          value: 'text',
                          label: Text('Text'),
                          icon: Icon(Icons.text_snippet),
                        ),
                      ],
                      selected: {_reportFormat},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _reportFormat = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Report Options
                    Text(
                      'Report Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Include Charts and Graphs'),
                      subtitle: const Text('Visual representation of data'),
                      value: _includeCharts,
                      onChanged: (value) {
                        setState(() {
                          _includeCharts = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Include User Information'),
                      subtitle: const Text('User details for each diagnosis'),
                      value: _includeUserInfo,
                      onChanged: (value) {
                        setState(() {
                          _includeUserInfo = value ?? true;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),
                    
                    // Generate Report Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating 
                            ? null 
                            : () => _generateReport(diagnosesAsync),
                        icon: _isGenerating 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ) 
                            : const Icon(Icons.download),
                        label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Report Preview
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Preview',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    diagnosesAsync.when(
                      data: (diagnoses) => _buildReportPreview(context, diagnoses),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: SpinKitPulse(
                            color: AppTheme.primaryColor,
                            size: 40.0,
                          ),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load diagnoses: $error',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? value,
    required Function(DateTime) onSelect,
  }) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        
        if (date != null) {
          onSelect(date);
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value != null ? dateFormat.format(value) : 'Select Date',
                    style: value == null
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            )
                        : Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(BuildContext context, List<DiagnosisModel> diagnoses) {
    // Filter diagnoses by date range if selected
    List<DiagnosisModel> filteredDiagnoses = diagnoses;
    if (_startDate != null && _endDate != null) {
      final startStr = DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
          .toIso8601String();
      final endStr = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
          .toIso8601String();

      filteredDiagnoses = diagnoses.where((d) {
        return d.date.compareTo(startStr) >= 0 && d.date.compareTo(endStr) <= 0;
      }).toList();
    }

    if (filteredDiagnoses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppTheme.textSecondaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _startDate != null && _endDate != null
                  ? 'No diagnoses found in the selected date range'
                  : 'No diagnoses found in the database',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Date Range'),
              ),
            ],
          ],
        ),
      );
    }

    // Group diagnoses by date for preview
    final diagnosisByDate = <String, List<DiagnosisModel>>{};
    for (final diagnosis in filteredDiagnoses) {
      final dateStr = diagnosis.date.split('T')[0];
      if (!diagnosisByDate.containsKey(dateStr)) {
        diagnosisByDate[dateStr] = [];
      }
      diagnosisByDate[dateStr]!.add(diagnosis);
    }

    // Sort dates
    final sortedDates = diagnosisByDate.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EyeCheckAI Diagnosis Report',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _startDate != null && _endDate != null
                          ? 'Period: ${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                          : 'All diagnoses',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Records: ${filteredDiagnoses.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Preview content
        for (int i = 0; i < min(sortedDates.length, 3); i++) ...[
          Text(
            'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(sortedDates[i]))}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          for (int j = 0; j < min(diagnosisByDate[sortedDates[i]]!.length, 2); j++) ...[
            _buildDiagnosisPreviewItem(context, diagnosisByDate[sortedDates[i]]![j]),
            const SizedBox(height: 16),
          ],
          if (diagnosisByDate[sortedDates[i]]!.length > 2)
            Text(
              '... and ${diagnosisByDate[sortedDates[i]]!.length - 2} more diagnoses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          const SizedBox(height: 24),
        ],

        if (sortedDates.length > 3)
          Center(
            child: Text(
              '... and ${sortedDates.length - 3} more days',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        const SizedBox(height: 16),
        
        // Preview note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This is a preview of the report. The generated report will contain all ${filteredDiagnoses.length} diagnoses from ${sortedDates.length} different days.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisPreviewItem(BuildContext context, DiagnosisModel diagnosis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  diagnosis.patientName ?? 'Unknown Patient',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('HH:mm').format(DateTime.parse(diagnosis.date)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          if (diagnosis.patientEmail != null) ...[
            const SizedBox(height: 4),
            Text(
              diagnosis.patientEmail!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'Diagnoses:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: diagnosis.diagnosisList.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name),
                    ),
                    Text(
                      '${(item.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (_includeUserInfo) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'User ID: ${diagnosis.userId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateReport(AsyncValue<List<DiagnosisModel>> diagnosesAsync) async {
    if (_isGenerating) return;
    
    if (diagnosesAsync is! AsyncData<List<DiagnosisModel>>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot generate report: Diagnoses data not loaded'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Filter diagnoses by date range if selected
    List<DiagnosisModel> filteredDiagnoses = diagnosesAsync.value;
    if (_startDate != null && _endDate != null) {
      final startStr = DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
          .toIso8601String();
      final endStr = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
          .toIso8601String();

      filteredDiagnoses = diagnosesAsync.value.where((d) {
        return d.date.compareTo(startStr) >= 0 && d.date.compareTo(endStr) <= 0;
      }).toList();
    }
    
    if (filteredDiagnoses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No diagnoses found for the selected criteria'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Generate and export report based on selected format
      switch (_reportFormat) {
        case 'pdf':
          await ExportUtils.generateDiagnosisReport(
            filteredDiagnoses,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case 'csv':
          ExportUtils.exportDiagnosesToCSV(filteredDiagnoses);
          break;
        case 'text':
          final report = await ref.read(adminFirebaseServiceProvider).generatePrintableReport(
                startDate: _startDate,
                endDate: _endDate,
              );
          
          // Create a blob from the text content and download it
          final blob = html.Blob([report], 'text/plain');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'diagnosis_report_${DateTime.now().millisecondsSinceEpoch}.txt')
            ..click();
          html.Url.revokeObjectUrl(url);
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated successfully in $_reportFormat format'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
  
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
