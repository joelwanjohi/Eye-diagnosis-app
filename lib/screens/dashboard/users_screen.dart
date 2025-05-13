import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../utils/export_utils.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(usersProvider),
            tooltip: 'Refresh Data',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: usersAsync.when(
              data: (users) => _buildUsersList(users),
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
                      'Failed to load users',
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
                      onPressed: () => ref.refresh(usersProvider),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exportUserData(),
        child: const Icon(Icons.download),
        tooltip: 'Export Users Data',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by email or name',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          filled: true,
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

  Widget _buildUsersList(List<UserModel> allUsers) {
    // Filter users based on search query
    final filteredUsers = allUsers.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.email.toLowerCase().contains(_searchQuery) ||
          (user.name?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    // Sort users
    _sortUsers(filteredUsers);

    return Card(
      margin: const EdgeInsets.all(16),
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
                  'All Users (${filteredUsers.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Total Users: ${allUsers.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_off,
                            size: 48,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match your search',
                            style: Theme.of(context).textTheme.titleMedium,
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
                          label: const Text('Name'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn2(
                          label: const Text('Registered'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn2(
                          label: const Text('Diagnoses'),
                          numeric: true,
                          size: ColumnSize.S,
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
                      rows: filteredUsers.map((user) {
                        return DataRow2(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.email,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (user.isAdmin)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Admin',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.warningColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(user.name ?? 'N/A'),
                            ),
                            DataCell(
                              Text(DateFormatter.getRelativeTime(user.createdAt)),
                            ),
                            DataCell(
                              Text(user.diagnosisCount.toString()),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _viewUserDetails(user),
                                    tooltip: 'View Details',
                                  ),
                                  if (user.diagnosisCount > 0)
                                    IconButton(
                                      icon: const Icon(Icons.healing),
                                      onPressed: () => _viewUserDiagnoses(user),
                                      tooltip: 'View Diagnoses',
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

  void _sortUsers(List<UserModel> users) {
    switch (_sortColumnIndex) {
      case 0: // Email
        users.sort((a, b) => _sortAscending
            ? a.email.compareTo(b.email)
            : b.email.compareTo(a.email));
        break;
      case 1: // Name
        users.sort((a, b) {
          final nameA = a.name ?? '';
          final nameB = b.name ?? '';
          return _sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
        });
        break;
      case 2: // Registered
        users.sort((a, b) => _sortAscending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case 3: // Diagnoses
        users.sort((a, b) => _sortAscending
            ? a.diagnosisCount.compareTo(b.diagnosisCount)
            : b.diagnosisCount.compareTo(a.diagnosisCount));
        break;
    }
  }

  void _viewUserDetails(UserModel user) {
    context.push('${AppConstants.usersRoute}/${user.id}');
  }

  void _viewUserDiagnoses(UserModel user) {
    ref.read(selectedUserProvider.notifier).state = user.id;
    context.push(AppConstants.diagnosesRoute);
  }

  void _exportUserData() {
    final usersData = ref.read(usersProvider);
    
    if (usersData is AsyncData<List<UserModel>>) {
      ExportUtils.exportUsersToCSV(usersData.value);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Users data exported successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}