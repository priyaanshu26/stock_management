import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Script to fix user collection issues
/// This script will:
/// 1. Check if current user has a Firestore document
/// 2. Create missing user documents
/// 3. Ensure proper role assignment
Future<void> fixUserCollection() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    print('🔧 USER COLLECTION FIX STARTING...');
    print('=' * 50);
    
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    // Check if user is signed in
    User? currentUser = auth.currentUser;
    
    if (currentUser == null) {
      print('❌ No user is currently signed in');
      print('💡 Please sign in first, then run this script');
      return;
    }
    
    print('✅ Current user: ${currentUser.email}');
    print('   UID: ${currentUser.uid}');
    
    // Check if user document exists in Firestore
    print('');
    print('🔍 Checking Firestore user document...');
    
    DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (userDoc.exists) {
      print('✅ User document exists in Firestore');
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      print('   Email: ${userData['email']}');
      print('   Role: ${userData['role']}');
      print('   Created: ${userData['createdAt']}');
    } else {
      print('❌ User document NOT found in Firestore');
      print('🔨 Creating user document...');
      
      // Determine role (admin for specific email, user for others)
      String role = _determineUserRole(currentUser.email ?? '');
      
      // Create user document
      UserModel userModel = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        role: role,
        createdAt: DateTime.now(),
      );
      
      await firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(userModel.toMap());
      
      print('✅ User document created successfully');
      print('   Email: ${userModel.email}');
      print('   Role: ${userModel.role}');
      print('   Created: ${userModel.createdAt}');
    }
    
    // Check all users collection
    print('');
    print('📊 Checking all users in collection...');
    
    QuerySnapshot allUsers = await firestore.collection('users').get();
    print('   Total users in Firestore: ${allUsers.docs.length}');
    
    for (var doc in allUsers.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('   - ${data['email']} (${data['role']})');
    }
    
    print('');
    print('✅ USER COLLECTION FIX COMPLETE!');
    
  } catch (e) {
    print('❌ Error fixing user collection: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}

/// Create user document for any Firebase Auth user
Future<void> createUserDocumentForCurrentUser() async {
  try {
    await Firebase.initializeApp();
    
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    User? currentUser = auth.currentUser;
    
    if (currentUser == null) {
      print('❌ No user is currently signed in');
      return;
    }
    
    print('🔨 Creating/Updating user document for: ${currentUser.email}');
    
    // Determine role
    String role = _determineUserRole(currentUser.email ?? '');
    
    // Create or update user document
    UserModel userModel = UserModel(
      uid: currentUser.uid,
      email: currentUser.email ?? '',
      role: role,
      createdAt: DateTime.now(),
    );
    
    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .set(userModel.toMap(), SetOptions(merge: true));
    
    print('✅ User document created/updated successfully');
    print('   Role: $role');
    
  } catch (e) {
    print('❌ Error creating user document: $e');
  }
}

/// Determine user role based on email
String _determineUserRole(String email) {
  // Admin email check
  if (email.toLowerCase() == 'priyanshu.171561@gmail.com') {
    return 'admin';
  }
  
  // Default to user role
  return 'user';
}

/// List all Firebase Auth users and their Firestore status
Future<void> debugUserStatus() async {
  try {
    await Firebase.initializeApp();
    
    print('🔍 USER STATUS DEBUG');
    print('=' * 30);
    
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    // Current user info
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      print('Current Firebase Auth User:');
      print('  Email: ${currentUser.email}');
      print('  UID: ${currentUser.uid}');
      print('  Email Verified: ${currentUser.emailVerified}');
      print('');
      
      // Check Firestore document
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        print('Firestore Document: EXISTS');
        print('  Email: ${data['email']}');
        print('  Role: ${data['role']}');
        print('  Created: ${data['createdAt']}');
      } else {
        print('Firestore Document: NOT FOUND');
      }
    } else {
      print('No user currently signed in');
    }
    
    print('');
    print('All Firestore Users:');
    QuerySnapshot allUsers = await firestore.collection('users').get();
    
    if (allUsers.docs.isEmpty) {
      print('  No users found in Firestore collection');
    } else {
      for (var doc in allUsers.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('  - ${data['email']} (${data['role']}) [${doc.id}]');
      }
    }
    
  } catch (e) {
    print('❌ Error in debug: $e');
  }
}

/// Main function to run the script
void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 USER COLLECTION FIX SCRIPT');
  print('');
  
  // Debug current status
  await debugUserStatus();
  print('');
  
  // Fix user collection
  await fixUserCollection();
  
  print('');
  print('✨ SCRIPT COMPLETE!');
}