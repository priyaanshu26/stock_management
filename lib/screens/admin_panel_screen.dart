import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'category_management_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Check if user is admin
          if (!authProvider.isAdmin) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You need admin privileges to access this page.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin info card
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 40,
                          color: Colors.red[800],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Panel',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Manage users and system settings',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CategoryManagementScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 32,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Manage Categories',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add, edit, or delete product categories',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Users management section
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading users: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No users found.'),
                        ),
                      );
                    }

                    List<UserModel> users = snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return UserModel.fromMap(data);
                    }).toList();

                    return Card(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              'All Users (${users.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return _buildUserTile(context, user, authProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel user, AuthProvider authProvider) {
    bool isCurrentUser = authProvider.user?.uid == user.uid;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: user.isAdmin ? Colors.red[100] : Colors.blue[100],
        child: Icon(
          user.isAdmin ? Icons.admin_panel_settings : Icons.person,
          color: user.isAdmin ? Colors.red[800] : Colors.blue[800],
        ),
      ),
      title: Text(
        user.email,
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role: ${user.role.toUpperCase()}'),
          if (isCurrentUser)
            Text(
              'You',
              style: TextStyle(
                color: Colors.blue[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            user.isAdmin ? 'Admin' : 'User',
            style: TextStyle(
              color: user.isAdmin ? Colors.red[800] : Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: user.isAdmin,
            onChanged: isCurrentUser ? null : (value) => _toggleUserRole(context, user, authProvider),
            activeColor: Colors.red,
            inactiveThumbColor: Colors.blue,
            inactiveTrackColor: Colors.blue[100],
          ),
        ],
      ),
    );
  }

  void _toggleUserRole(BuildContext context, UserModel user, AuthProvider authProvider) {
    final bool willBeAdmin = !user.isAdmin;
    final String action = willBeAdmin ? 'promote to admin' : 'demote to user';
    final String newRole = willBeAdmin ? 'admin' : 'user';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${willBeAdmin ? 'Promote' : 'Demote'} User'),
          content: Text(
            'Are you sure you want to $action ${user.email}?\n\n'
            '${willBeAdmin 
              ? 'This will give them full access to the admin panel and all administrative features.' 
              : 'This will remove their admin privileges and restrict them to user-level access.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateUserRole(context, user.email, newRole, authProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: willBeAdmin ? Colors.red : Colors.blue,
              ),
              child: Text(willBeAdmin ? 'Make Admin' : 'Make User'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserRole(BuildContext context, String email, String newRole, AuthProvider authProvider) async {
    try {
      bool success;
      if (newRole == 'admin') {
        success = await authProvider.makeUserAdmin(email);
      } else {
        // Demote admin to user
        success = await _demoteUserFromAdmin(email, authProvider);
      }
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated $email to $newRole'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update user role to $newRole'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _demoteUserFromAdmin(String email, AuthProvider authProvider) async {
    try {
      // Find user by email and update their role to 'user'
      final usersSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (usersSnapshot.docs.isNotEmpty) {
        final userDoc = usersSnapshot.docs.first;
        await userDoc.reference.update({
          'role': 'user',
          'isAdmin': false,
        });
        
        // If it's the current user, refresh their data
        if (authProvider.user?.email == email) {
          await authProvider.refreshUserData();
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}