# Admin Setup Guide

## Admin User Configuration

The email `priyanshu.171561@gmail.com` has been configured as an admin user in the stock management system.

## How Admin Access Works

### For New Users
- When `priyanshu.171561@gmail.com` signs up for the first time, they will automatically be assigned the "admin" role
- The system checks the email against a predefined list of admin emails during registration

### For Existing Users
If the user already exists in the system but doesn't have admin privileges, you can promote them using one of these methods:

#### Method 1: Using the Admin Panel (Recommended)
1. Sign in as an existing admin user
2. Navigate to the Dashboard
3. Click the "Admin Panel" button (shield icon) in the top-right corner
4. Find the user in the user list
5. Click "Make Admin" next to their name

#### Method 2: Manual Database Update
1. Access your Firestore console directly
2. Navigate to the "users" collection
3. Find the document for `priyanshu.171561@gmail.com`
4. Update the "role" field to "admin"

## Admin Features

### Dashboard
- **Role Badge**: Admins see a red "ADMIN" badge next to their name
- **Admin Panel Access**: Shield icon in the app bar provides access to admin features
- **Sample Data**: Floating action button to add sample products (admin only)

### Admin Panel
- **User Management**: View all registered users
- **Role Management**: Promote regular users to admin status
- **System Overview**: Monitor user activity and system health

## Adding More Admin Users

To add additional admin emails, update the `adminEmails` list in `lib/services/auth_service.dart`:

```dart
const List<String> adminEmails = [
  'priyanshu.171561@gmail.com',
  'another.admin@example.com',  // Add more admin emails here
];
```

## Security Notes

- Admin privileges are assigned based on email address verification
- Only existing admins can promote other users to admin status
- The first user to register in the system is automatically made an admin (fallback)
- Admin status is stored in Firestore and checked on each app launch

## Troubleshooting

### User Not Getting Admin Access
1. Verify the email is exactly `priyanshu.171561@gmail.com` (case-sensitive)
2. Check if the user document exists in Firestore
3. Manually update the user's role in Firestore console
4. Restart the app after role changes

### Admin Panel Not Visible
1. Ensure the user is logged in with admin privileges
2. Check the role field in the user document in Firestore
3. Verify the `isAdmin` getter is working correctly

## Database Structure

Admin users have the following structure in Firestore:

```json
{
  "uid": "user_firebase_uid",
  "email": "priyanshu.171561@gmail.com",
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```