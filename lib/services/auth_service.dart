import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Create user with email and password
  Future<User?> createUserWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Determine user role
        String role = _determineUserRole(email);
        
        // Create user document in Firestore
        await createUserDocument(result.user!, role);
      }
      
      return result.user;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Create user document in Firestore
  Future<void> createUserDocument(User user, String role) async {
    try {
      UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (e) {
      throw Exception('Failed to create user document: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Check if this is the first user in the system
  Future<bool> _isFirstUser() async {
    try {
      QuerySnapshot users = await _firestore
          .collection('users')
          .limit(1)
          .get();
      
      return users.docs.isEmpty;
    } catch (e) {
      // If there's an error, assume it's not the first user for safety
      return false;
    }
  }

  // Determine user role based on email and system state
  String _determineUserRole(String email) {
    // Direct check for the specific admin email
    if (email.toLowerCase() == 'priyanshu.171561@gmail.com') {
      return 'admin';
    }
    
    // Default to user role
    return 'user';
  }

  // Update user role (for existing users)
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'role': role});
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }

  // Make user admin by email (for existing users)
  Future<bool> makeUserAdmin(String email) async {
    try {
      QuerySnapshot users = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      if (users.docs.isNotEmpty) {
        String uid = users.docs.first.id;
        await updateUserRole(uid, 'admin');
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to make user admin: ${e.toString()}');
    }
  }

  // Create user document for existing Firebase Auth user
  Future<void> createUserDocumentForExistingUser(User user) async {
    try {
      String role = _determineUserRole(user.email ?? '');
      
      UserModel userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
    } catch (e) {
      throw Exception('Failed to create user document for existing user: ${e.toString()}');
    }
  }
}