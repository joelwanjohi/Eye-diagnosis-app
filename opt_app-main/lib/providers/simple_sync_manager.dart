import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opt_app/providers/firebase_provider.dart';
import 'package:opt_app/services/SyncServiceProvider.dart';

final syncManagerProvider = Provider((ref) => SimpleSyncManager(ref));

/// A simplified sync manager that doesn't depend on connectivity package
class SimpleSyncManager {
  SimpleSyncManager(this.ref) {
    _initialize();
  }

  final ProviderRef ref;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;

  // Initialize the sync manager
  void _initialize() {
    // Attempt initial sync when app starts if user is logged in
    if (_isUserLoggedIn) {
      _attemptSync();
    }

    // Listen for auth state changes
    ref.read(firebaseProvider).authStateChanges().listen((User? user) {
      if (user != null) {
        // User logged in - attempt sync and start periodic sync
        _attemptSync();
        _startPeriodicSync();
      } else {
        // User logged out - stop periodic sync
        _stopPeriodicSync();
      }
    });

    // Start periodic sync if user is already logged in
    if (_isUserLoggedIn) {
      _startPeriodicSync();
    }
  }

  // Start periodic sync timer
  void _startPeriodicSync() {
    _stopPeriodicSync(); // Stop any existing timer
    
    // Try to sync every 15 minutes when the app is running
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (_isUserLoggedIn) {
        _attemptSync();
      }
    });
  }

  // Stop periodic sync timer
  void _stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
  }

  // Check if user is logged in
  bool get _isUserLoggedIn => ref.read(firebaseProvider).currentUser != null;

  // Attempt to sync data
  Future<void> _attemptSync() async {
    if (_isSyncing || !_isUserLoggedIn) return;

    try {
      _isSyncing = true;
      print('Attempting to sync diagnoses...');
      
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.syncAllDiagnosesToFirebase();
      
      print('Sync completed');
    } catch (e) {
      print('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Public method to manually trigger sync
  Future<bool> syncNow() async {
    if (_isSyncing) {
      print('Sync already in progress');
      return false;
    }

    if (!_isUserLoggedIn) {
      print('Cannot sync: User not logged in');
      return false;
    }

    try {
      _isSyncing = true;
      
      final syncService = ref.read(diagnosisSyncServiceProvider);
      await syncService.syncAllDiagnosesToFirebase();
      
      print('Manual sync completed');
      return true;
    } catch (e) {
      print('Manual sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Call this method when the app resumes from background
  void onAppResume() {
    if (_isUserLoggedIn) {
      _attemptSync();
    }
  }
}