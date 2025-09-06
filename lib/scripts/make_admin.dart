import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

/// Comprehensive debug script to check admin functionality
Future<void> debugAdminSetup() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    const String adminEmail = 'priyanshu.171561@gmail.com';
    final firestore = FirebaseFirestore.instance;
    
    print('🔍 DEBUGGING ADMIN SETUP FOR: $adminEmail');
    print('=' * 50);
    
    // Step 1: Check if user exists
    print('1️⃣ Checking if user exists in database...');
    QuerySnapshot users = await firestore
        .collection('users')
        .where('email', isEqualTo: adminEmail)
        .get();
    
    if (users.docs.isEmpty) {
      print('❌ User not found in database');
      print('💡 User needs to sign up first');
      return;
    }
    
    // Step 2: Show current user data
    DocumentSnapshot userDoc = users.docs.first;
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    
    print('✅ User found!');
    print('📋 Current user data:');
    print('   UID: ${userDoc.id}');
    print('   Email: ${userData['email']}');
    print('   Role: ${userData['role']}');
    print('   Created: ${userData['createdAt']}');
    print('');
    
    // Step 3: Test admin email logic
    print('2️⃣ Testing admin email logic...');
    const List<String> adminEmails = ['priyanshu.171561@gmail.com'];
    bool shouldBeAdmin = adminEmails.contains(adminEmail.toLowerCase());
    print('   Admin email check: $shouldBeAdmin');
    print('   Current role: ${userData['role']}');
    print('   Should be admin: $shouldBeAdmin');
    
    if (shouldBeAdmin && userData['role'] != 'admin') {
      print('⚠️  MISMATCH DETECTED! User should be admin but isn\'t');
      print('');
      
      // Step 4: Fix the role
      print('3️⃣ Fixing admin role...');
      await firestore
          .collection('users')
          .doc(userDoc.id)
          .update({'role': 'admin'});
      
      print('✅ Successfully updated role to admin');
      
      // Verify the fix
      DocumentSnapshot updatedDoc = await firestore
          .collection('users')
          .doc(userDoc.id)
          .get();
      Map<String, dynamic> updatedData = updatedDoc.data() as Map<String, dynamic>;
      print('✅ Verified - New role: ${updatedData['role']}');
      
    } else if (userData['role'] == 'admin') {
      print('✅ User already has admin role - everything looks good!');
    } else {
      print('ℹ️  User is not in admin list - this is expected');
    }
    
    print('');
    print('4️⃣ Testing FirestoreService method...');
    final firestoreService = FirestoreService();
    bool serviceResult = await firestoreService.makeUserAdmin(adminEmail);
    print('   FirestoreService.makeUserAdmin result: $serviceResult');
    
  } catch (e) {
    print('❌ Error during debug: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}

/// Simple function to make user admin
Future<void> makeUserAdmin(String email) async {
  try {
    await Firebase.initializeApp();
    final firestoreService = FirestoreService();
    bool success = await firestoreService.makeUserAdmin(email);
    
    if (success) {
      print('✅ Successfully made $email an admin');
    } else {
      print('❌ User with email $email not found');
    }
  } catch (e) {
    print('❌ Error making user admin: $e');
  }
}

/// Test the _determineUserRole logic
void testAdminEmailLogic() {
  print('🧪 TESTING ADMIN EMAIL LOGIC');
  print('=' * 30);
  
  const List<String> adminEmails = ['priyanshu.171561@gmail.com'];
  const String testEmail = 'priyanshu.171561@gmail.com';
  
  print('Admin emails list: $adminEmails');
  print('Test email: $testEmail');
  print('Test email lowercase: ${testEmail.toLowerCase()}');
  print('Contains check: ${adminEmails.contains(testEmail.toLowerCase())}');
  
  String role = adminEmails.contains(testEmail.toLowerCase()) ? 'admin' : 'user';
  print('Determined role: $role');
}

/// Main function to run the script
void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 ADMIN DEBUG SCRIPT STARTING...');
  print('');
  
  // Test the logic first
  testAdminEmailLogic();
  print('');
  
  // Then debug the actual setup
  await debugAdminSetup();
  
  print('');
  print('✨ DEBUG COMPLETE!');
}