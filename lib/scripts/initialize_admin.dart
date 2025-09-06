import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to initialize the admin user
/// This creates the admin user account and sets up the database
Future<void> initializeAdmin() async {
  try {
    // Initialize Flutter and Firebase
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    
    const String adminEmail = 'priyanshu.171561@gmail.com';
    const String adminPassword = 'admin123'; // Change this to your desired password
    
    print('🚀 Initializing admin user...');
    print('Email: $adminEmail');
    
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    
    // Check if user already exists
    try {
      print('📋 Checking if user already exists...');
      await auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      print('✅ User already exists and can sign in');
      
      // Update their role to admin just in case
      final user = auth.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'role': 'admin',
          'createdAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        print('✅ Updated user role to admin');
      }
      
    } catch (e) {
      print('👤 User does not exist, creating new admin user...');
      
      // Create new user
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      
      if (result.user != null) {
        print('✅ Created Firebase Auth user');
        
        // Create user document in Firestore
        await firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': result.user!.email,
          'role': 'admin',
          'createdAt': DateTime.now().toIso8601String(),
        });
        
        print('✅ Created Firestore user document with admin role');
      }
    }
    
    // Sign out
    await auth.signOut();
    
    print('');
    print('🎉 ADMIN INITIALIZATION COMPLETE!');
    print('');
    print('📱 You can now sign in to the app with:');
    print('   Email: $adminEmail');
    print('   Password: $adminPassword');
    print('');
    print('🔧 The user will have admin privileges and can:');
    print('   - Access the admin panel');
    print('   - Manage other users');
    print('   - Add/edit/delete products');
    print('   - View all transactions');
    
  } catch (e) {
    print('❌ Error during initialization: $e');
    print('');
    print('🔧 Troubleshooting:');
    print('   1. Make sure Firebase is properly configured');
    print('   2. Check that Firestore rules allow user creation');
    print('   3. Verify internet connection');
  }
}

void main() async {
  await initializeAdmin();
}