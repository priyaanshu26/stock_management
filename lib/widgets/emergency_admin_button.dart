import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Emergency admin button - add this anywhere in your app temporarily
class EmergencyAdminButton extends StatelessWidget {
  const EmergencyAdminButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        onPressed: () => _emergencyAdminFix(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.emergency),
        label: const Text('EMERGENCY ADMIN FIX'),
      ),
    );
  }

  Future<void> _emergencyAdminFix(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ No user logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Admin Fix'),
        content: Text(
          'This will make the current user (${user.email}) an admin.\n\n'
          'Are you sure you want to continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('YES, MAKE ADMIN'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Applying emergency fix...'),
          ],
        ),
      ),
    );

    try {
      // Direct Firestore update
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email ?? '',
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ EMERGENCY ADMIN FIX APPLIED! Restart the app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Emergency fix failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}