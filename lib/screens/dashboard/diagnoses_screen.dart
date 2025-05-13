import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../models/diagnosis_model.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../utils/export_utils.dart';

class DiagnosesScreen extends ConsumerStatefulWidget {
  const DiagnosesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DiagnosesScreen> createState() => _DiagnosesScreenState();
}

class _DiagnosesScreenState extends ConsumerState<DiagnosesScreen> {
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = false; // Default to newest first
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedDiagnosisType;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    // Check if there's a selected user from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedUser = ref.read(selectedUserProvider);
      if (selectedUser != null) {
        setState(() {
          _selectedUserId = selectedUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch users for dropdowns
    final usersAsync = ref.watch(usersProvider);
    
    // Get diagnoses based on filters
    AsyncValue<List<DiagnosisModel>> diagnosesAsync;
    
    if (_selectedUserId != null) {
      diagnosesAsync = ref.watch(userDiagnosesProvider(_selectedUserId!));
    } else if (_startDate != null && _endDate != null) {
      diagnosesAsync = ref.watch(dateRangeDiagnosesProvider((
        startDate: DateTime(_startDate!.year, _startDate!.month, _startDate!.day),
        endDate: DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59),
      )));
    } else {
      diagnosesAsync = ref.watch(diagnosesProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnoses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh appropriate provider based on filters
              if (_selectedUserId != null) {
                ref.refresh(userDiagnosesProvider(_selectedUserId!));
              } else if (_startDate != null && _endDate != null) {
                ref.refresh(dateRangeDiagnosesProvider((
                  startDate: _startDate!,
                  endDate: _endDate!,
                )));
              } else {
                ref.refresh(diagnosesProvider);
              }
            },
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(usersAsync),
          Expanded(
            child: diagnosesAsync.when(
              data: (diagnoses) => _buildDiagnosesList(diagnoses),
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
                      'Failed to load diagnoses',
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
                      onPressed: () {
                        if (_selectedUserId != null) {
                          ref.refresh(userDiagnosesProvider(_selectedUserId!));
                        } else if (_startDate != null && _endDate != null) {
                          ref.refresh(dateRangeDiagnosesProvider((
                            startDate: _startDate!,
                            endDate: _endDate!,
                          )));
                        } else {
                          ref.refresh(diagnosesProvider);
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: diagnosesAsync.maybeWhen(
        data: (diagnoses) => diagnoses.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () => _exportDiagnosesData(diagnoses),
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                tooltip: 'Export Diagnoses Data',
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildFiltersSection(AsyncValue<List<UserModel>> usersAsync) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Diagnoses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            isWideScreen
                ? Row(
                    children: [
                      _buildSearchField(),
                      const SizedBox(width: 16),
                      _buildUserDropdown(usersAsync),
                      const SizedBox(width: 16),
                      _buildDateRangePicker(),
                      const SizedBox(width: 16),
                      _buildDiagnosisTypeDropdown(),
                      const SizedBox(width: 16),
                      _buildClearFiltersButton(),
                    ],
                  )
                : isMediumScreen
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildSearchField()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildUserDropdown(usersAsync)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildDateRangePicker()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDiagnosisTypeDropdown()),
                              const SizedBox(width: 16),
                              _buildClearFiltersButton(),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: 16),
                          _buildUserDropdown(usersAsync),
                          const SizedBox(height: 16),
                          _buildDateRangePicker(),
                          const SizedBox(height: 16),
                          _buildDiagnosisTypeDropdown(),
                          const SizedBox(height: 16),
                          _buildClearFiltersButton(),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by patient name or email',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildUserDropdown(AsyncValue<List<UserModel>> usersAsync) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Filter by User',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        value: _selectedUserId,
        isExpanded: true,
        hint: const Text('All Users'),
        items: usersAsync.when(
          data: (users) => [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All Users'),
            ),
            ...users.map(
              (user) => DropdownMenuItem<String>(
                value: user.id,
                child: Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          loading: () => [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Loading users...'),
            )
          ],
          error: (_, __) => [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Error loading users'),
            )
          ],
        ),
        onChanged: (value) {
          setState(() {
            _selectedUserId = value;
            
            // Update the provider selection if necessary
            if (value != null) {
              ref.read(selectedUserProvider.notifier).state = value;
            }
          });
        },
      ),
    );
  }

  Widget _buildDateRangePicker() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateRangeText = _startDate != null && _endDate != null
        ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
        : 'Select Date Range';

    return Expanded(
      child: InkWell(
        onTap: _selectDateRange,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dateRangeText,
                  style: _startDate == null && _endDate == null
                      ? Theme.of(context).inputDecorationTheme.hintStyle
                      : null,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_startDate != null && _endDate != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  iconSize: 18,
                  splashRadius: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisTypeDropdown() {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Diagnosis Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        value: _selectedDiagnosisType,
        isExpanded: true,
        hint: const Text('All Types'),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('All Types'),
          ),
          ...AppConstants.commonDiagnosisTypes.map(
            (type) => DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _selectedDiagnosisType = value;
          });
        },
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    final hasFilters = _searchQuery.isNotEmpty ||
        _selectedUserId != null ||
        _startDate != null ||
        _endDate != null ||
        _selectedDiagnosisType != null;

    return ElevatedButton.icon(
      onPressed: hasFilters
          ? () {
              setState(() {
                _searchQuery = '';
                _selectedUserId = null;
                _startDate = null;
                _endDate = null;
                _selectedDiagnosisType = null;
                
                // Clear the selected user in provider
                ref.read(selectedUserProvider.notifier).state = null;
              });
            }
          : null,
      icon: const Icon(Icons.clear_all),
      label: const Text('Clear Filters'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.errorColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final initialDateRange = _startDate != null && _endDate != null
        ? DateTimeRange(start: _startDate!, end: _endDate!)
        : null;

    final dateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }

  Widget _buildDiagnosesList(List<DiagnosisModel> allDiagnoses) {
    // Filter diagnoses based on search query and diagnosis type
    final filteredDiagnoses = allDiagnoses.where((diagnosis) {
      if (_searchQuery.isNotEmpty) {
        final patientName = diagnosis.patientName?.toLowerCase() ?? '';
        final patientEmail = diagnosis.patientEmail?.toLowerCase() ?? '';
        
        if (!patientName.contains(_searchQuery) && !patientEmail.contains(_searchQuery)) {
          return false;
        }
      }
      
      if (_selectedDiagnosisType != null) {
        return diagnosis.diagnosisList.any(
          (item) => item.name.toLowerCase() == _selectedDiagnosisType!.toLowerCase(),
        );
      }
      
      return true;
    }).toList();

    // Sort diagnoses
    _sortDiagnoses(filteredDiagnoses);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diagnoses (${filteredDiagnoses.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Total Diagnoses: ${allDiagnoses.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredDiagnoses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.healing_outlined,
                            size: 48,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No diagnoses found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_searchQuery.isNotEmpty ||
                              _selectedUserId != null ||
                              _startDate != null ||
                              _selectedDiagnosisType != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Try changing or clearing your filters',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                        ],
                      ),
                    )
                  : DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      headingRowColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                      border: TableBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      columns: [
                        DataColumn2(
                          label: const Text('Date'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn2(
                          label: const Text('Patient'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn2(
                          label: const Text('Email'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn2(
                          label: const Text('Diagnoses'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn2(
                          label: Text('Actions'),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: filteredDiagnoses.map((diagnosis) {
                        return DataRow2(
                          cells: [
                            DataCell(
                              Text(DateFormatter.formatISOToLocal(diagnosis.date)),
                            ),
                            DataCell(
                              Text(
                                diagnosis.patientName ?? 'Unknown',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            DataCell(
                              Text(diagnosis.patientEmail ?? 'N/A'),
                            ),
                            DataCell(
                              diagnosis.diagnosisList.isEmpty
                                  ? const Text('No diagnoses')
                                  : Wrap(
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
                                                    '+${diagnosis.diagnosisList.length - 2}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity: VisualDensity.compact,
                                                  backgroundColor: AppTheme.textSecondaryColor.withOpacity(0.1),
                                                )
                                              ]
                                            : []),
                                    ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _viewDiagnosisDetails(diagnosis),
                                    tooltip: 'View Details',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.person),
                                    onPressed: () => _viewUserDetails(diagnosis.userId),
                                    tooltip: 'View User',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortDiagnoses(List<DiagnosisModel> diagnoses) {
    switch (_sortColumnIndex) {
      case 0: // Date
        diagnoses.sort((a, b) => _sortAscending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case 1: // Patient
        diagnoses.sort((a, b) {
          final nameA = a.patientName ?? '';
          final nameB = b.patientName ?? '';
          return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
      case 2: // Email
        diagnoses.sort((a, b) {
          final emailA = a.patientEmail ?? '';
          final emailB = b.patientEmail ?? '';
          return _sortAscending ? emailA.compareTo(emailB) : emailB.compareTo(emailA);
        });
        break;
      case 3: // Diagnoses count
        diagnoses.sort((a, b) => _sortAscending
            ? a.diagnosisList.length.compareTo(b.diagnosisList.length)
            : b.diagnosisList.length.compareTo(a.diagnosisList.length));
        break;
    }
  }

  void _viewDiagnosisDetails(DiagnosisModel diagnosis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnosis Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Date', DateFormatter.formatISOToLocal(diagnosis.date)),
              _buildDetailRow('Patient', diagnosis.patientName ?? 'Unknown'),
              _buildDetailRow('Email', diagnosis.patientEmail ?? 'N/A'),
              _buildDetailRow('User ID', diagnosis.userId),
              const SizedBox(height: 16),
              const Text(
                'Diagnoses:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...diagnosis.diagnosisList.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 10),
                      const SizedBox(width: 8),
                      Text(d.name),
                      const Spacer(),
                      Text('${(d.confidence * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),
              if (diagnosis.notes != null && diagnosis.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(diagnosis.notes!),
              ],
              // if (diagnosis.imageUrl != null && diagnosis.imageUrl!.isNotEmpty) ...[
              //   const SizedBox(height: 16),
              //   const Text(
              //     'Image:',
              //     style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              //   const SizedBox(height: 8),
              //   Container(
              //     height: 150,
              //     decoration: BoxDecoration(
              //       border: Border.all(color: Colors.grey.shade300),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Center(
              //       child: const Text('Image URL: [Available in database]'),
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(String userId) {
    context.push('${AppConstants.usersRoute}/$userId');
  }

  void _exportDiagnosesData(List<DiagnosisModel> diagnoses) {
    ExportUtils.exportDiagnosesToCSV(diagnoses);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnoses data exported successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}