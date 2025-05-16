import 'package:admin_dashboard/services/admin_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

class DashboardLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const DashboardLayout({
    Key? key,
    required this.child,
    required this.currentRoute,
  }) : super(key: key);

  @override
  ConsumerState<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardLayout> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1100;
    
    // Automatically collapse sidebar on small screens
    if (isSmallScreen && !_isCollapsed) {
      _isCollapsed = true;
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          AnimatedContainer(
            duration: AppConstants.animationDuration,
            width: _isCollapsed
                ? AppConstants.compactSidebarWidth
                : AppConstants.sidebarWidth,
            color: AppTheme.primaryColor,
            child: _buildSidebar(context, isSmallScreen),
          ),
          
          // Main content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
      drawer: isSmallScreen
          ? Drawer(
              child: _buildSidebar(context, isSmallScreen, isDrawer: true),
            )
          : null,
    );
  }

  Widget _buildSidebar(BuildContext context, bool isSmallScreen, {bool isDrawer = false}) {
    return Column(
      children: [
        // App logo and title
        _buildSidebarHeader(isDrawer),
        
        // Navigation items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final section in AppConstants.dashboardSections)
                if (section.isActive)
                  _buildNavItem(
                    context,
                    title: section.title,
                    icon: section.icon,
                    route: section.route,
                    isSelected: widget.currentRoute == section.route,
                  ),
            ],
          ),
        ),
        
        // User profile and logout
        _buildUserSection(context, isDrawer),
      ],
    );
  }

  Widget _buildSidebarHeader(bool isDrawer) {
    return Container(
      height: AppConstants.appBarHeight + 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.primaryColor.withOpacity(0.8),
      child: Row(
        children: [
          const Icon(
            Icons.visibility,
            color: Colors.white,
            size: 28,
          ),
          if (!_isCollapsed || isDrawer) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'EyeCheckAI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            if (!isDrawer)
              IconButton(
                icon: Icon(
                  _isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: _isCollapsed
            ? null
            : Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
        minLeadingWidth: 0,
        onTap: () {
          context.go(route);
          // Close drawer if open
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, bool isDrawer) {
    final currentAdmin = ref.watch(currentAdminUserProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        children: [
          if (!_isCollapsed || isDrawer) ...[
            currentAdmin.when(
              data: (admin) => Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    radius: 24,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    admin?.email ?? 'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administrator',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
            ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ] else
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white70,
              ),
              onPressed: () => _handleLogout(context),
              tooltip: 'Logout',
            ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
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
}