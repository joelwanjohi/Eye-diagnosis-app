import 'package:flutter/material.dart';

class AppConstants {
  // App information
  static const String appName = 'EyeCheckAI Admin';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Admin Dashboard for EyeCheckAI';
  
  // Route names
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String usersRoute = '/users';
  static const String userDetailsRoute = '/users/:id';
  static const String diagnosesRoute = '/diagnoses';
  static const String diagnosisDetailsRoute = '/diagnoses/:id';
  static const String statisticsRoute = '/statistics';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  
  // Duration constants
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Layout constants
  static const double sidebarWidth = 250.0;
  static const double compactSidebarWidth = 70.0;
  static const double borderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double appBarHeight = 60.0;
  
  // Firebase collections
  static const String usersCollection = 'users';
  static const String diagnosesCollection = 'diagnoses';
  
  // Dashboard sections
  static const List<({String title, String route, IconData icon, bool isActive})> dashboardSections = [
    (title: 'Dashboard', route: dashboardRoute, icon: Icons.dashboard_rounded, isActive: true),
    (title: 'Users', route: usersRoute, icon: Icons.people_alt_rounded, isActive: true),
    (title: 'Diagnoses', route: diagnosesRoute, icon: Icons.healing_rounded, isActive: true),
    (title: 'Statistics', route: statisticsRoute, icon: Icons.bar_chart_rounded, isActive: true),
    (title: 'Reports', route: reportsRoute, icon: Icons.summarize_rounded, isActive: true),
    (title: 'Settings', route: settingsRoute, icon: Icons.settings_rounded, isActive: false),
  ];
  
  // Data table columns
  static const List<DataColumn> userColumns = [
    DataColumn(label: Text('Email')),
    DataColumn(label: Text('Name')),
    DataColumn(label: Text('Registered')),
    DataColumn(label: Text('Diagnoses')),
    DataColumn(label: Text('Actions')),
  ];
  
  static const List<DataColumn> diagnosisColumns = [
    DataColumn(label: Text('Date')),
    DataColumn(label: Text('Patient')),
    DataColumn(label: Text('Email')),
    DataColumn(label: Text('Diagnoses')),
    DataColumn(label: Text('Actions')),
  ];
  
// Common diagnosis types for filters
static const List<String> commonDiagnosisTypes = [
  'Conjunctivitis',
  'Blepharitis',
  'Dry Eye Disease',
  'Infectious Conjunctivitis',
  'Allergic conjunctivitis',
  'Acute Angle-Closure Glaucoma',
  'Corneal abrasion',
  'Post-surgical inflammation',
  'Dacryoadenitis',
  'Cataract',
  'Glaucoma',
  'Diabetic Retinopathy',
  'Age-related Macular Degeneration',
  'Retinal Detachment',
  'Normal',
];
  
  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF4A6FFF),
    Color(0xFF6C63FF),
    Color(0xFF5AC8FA),
    Color(0xFFFF9500),
    Color(0xFF34C759),
    Color(0xFFFF3B30),
    Color(0xFF9C27B0),
    Color(0xFF3F51B5),
    Color(0xFF009688),
    Color(0xFF795548),
  ];
}