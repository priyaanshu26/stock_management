import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to check and fix admin status for priyanshu.171561@gmail.com
Future<void> checkAndFixAdmin() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    final firestore = FirebaseFirestore.instance;
    const String adminEmail = 'priyanshu.171561@gmail.com';
    
    print('🔍 Checking user: $adminEmail');
    
    // Query for the user
    QuerySnapshot users = await firestore
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();
    
    if (users.docs.isEmpty) {
      print('❌ User not found in database');
      print('💡 User needs to sign up first');
      return;
    }
    
    // Get user document
    DocumentSnapshot userDoc = users.docs.first;
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    
    print('📋 Current user data:');
    print('   Email: ${userData['email']}');
    print('   Role: ${userData['role']}');
    print('   UID: ${userDoc.id}');
    
    // Check if already admin
    if (userData['role'] == 'admin') {
      print('✅ User is already an admin!');
      return;
    }
    
    // Update to admin
    print('🔧 Updating user to admin...');
    await firestore
        .collection('users')
        .doc(userDoc.id)
        .update({'role': 'admin'});
    
    print('✅ Successfully updated $adminEmail to admin!');
    print('🔄 User should restart the app to see changes');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

void main() async {
  print('🚀 Starting admin check and fix...');
  await checkAndFixAdmin();
  print('✨ Done!');
}