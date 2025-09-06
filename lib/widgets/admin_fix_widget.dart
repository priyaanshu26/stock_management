import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;

class AdminFixWidget extends StatelessWidget {
  const AdminFixWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        // Only show for the specific email and if not admin
        if (authProvider.userData?.email != 'priyanshu.171561@gmail.com' || 
            authProvider.isAdmin) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.red[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin Access Issue Detected',
                      style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your account (${authProvider.userData?.email}) should have admin privileges but is currently showing as "${authProvider.userData?.role}". Click below to fix this immediately.',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _forceFixAdmin(context, authProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.build),
                      label: const Text('Force Fix Admin'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _debugUserData(context, authProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[800],
                      ),
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Debug Info'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _forceFixAdmin(BuildContext context, app_auth.AuthProvider authProvider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Forcing admin fix...'),
          ],
        ),
      ),
    );

    try {
      // Direct Firestore update
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'role': 'admin'});

      // Refresh auth provider data
      await authProvider.refreshUserData();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Admin access fixed! Please restart the app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _debugUserData(BuildContext context, app_auth.AuthProvider authProvider) {
    final user = FirebaseAuth.instance.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Firebase Auth User:'),
              Text('  UID: ${user?.uid ?? "null"}'),
              Text('  Email: ${user?.email ?? "null"}'),
              const SizedBox(height: 12),
              Text('Firestore User Data:'),
              Text('  UID: ${authProvider.userData?.uid ?? "null"}'),
              Text('  Email: ${authProvider.userData?.email ?? "null"}'),
              Text('  Role: ${authProvider.userData?.role ?? "null"}'),
              Text('  IsAdmin: ${authProvider.isAdmin}'),
              const SizedBox(height: 12),
              Text('Expected:'),
              Text('  Email: priyanshu.171561@gmail.com'),
              Text('  Role: admin'),
              Text('  IsAdmin: true'),
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
}