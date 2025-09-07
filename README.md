# 📦 Stock Management System

A comprehensive Flutter-based stock management application built for efficient inventory tracking, user management, and real-time data synchronization using Firebase.

## 🚀 Features

### 📱 Core Functionality
- **Real-time Inventory Management**: Add, edit, delete, and track products with live updates
- **Category Management**: Organize products into customizable categories
- **Stock Transactions**: Record stock in/out movements with detailed history
- **User Authentication**: Secure Firebase authentication with Google Sign-in support
- **Role-based Access Control**: Admin and regular user roles with different permissions
- **Data Export**: Export inventory data to Excel format for external use

### 👨‍💼 Admin Features
- **Admin Panel**: Dedicated interface for system administration
- **User Management**: View and manage all registered users
- **Category Administration**: Full CRUD operations for product categories
- **Role Management**: Promote users to admin status
- **System Overview**: Monitor user activity and system health

### 📊 Analytics & Reporting
- **Dashboard View**: Overview of stock levels and recent transactions
- **Low Stock Alerts**: Visual indicators for products running low
- **Transaction History**: Complete audit trail of all stock movements
- **Search & Filter**: Advanced search capabilities across products and transactions

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Provider pattern
- **Database**: Cloud Firestore (NoSQL)
- **File Generation**: Excel export functionality
- **Architecture**: Clean Architecture with Provider pattern

## 📋 Prerequisites

Before running this project, make sure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.8.1)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Firebase project set up
- Android/iOS device or emulator

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/priyaanshu26/stock_management.git
   cd stock_management
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Google Sign-in)
   - Enable Cloud Firestore
   - Download `google-services.json` for Android and place it in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Allow authenticated users to read/write their own data
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage

### Getting Started
1. **Sign Up/Login**: Create an account or sign in with existing credentials
2. **Dashboard**: View your inventory overview and recent activities
3. **Add Products**: Navigate to Products screen and add your inventory items
4. **Manage Categories**: Organize products by creating custom categories
5. **Record Transactions**: Track stock movements (in/out) with detailed records

### Admin Setup
To set up admin access, refer to the [Admin Setup Guide](ADMIN_SETUP.md) for detailed instructions.

## 🏗️ Project Structure

```
lib/
├── models/           # Data models (Product, Category, Transaction, User)
├── providers/        # State management (Auth, Inventory, Category)
├── screens/          # UI screens (Dashboard, Products, Admin Panel)
├── services/         # Business logic (Auth, Firestore services)
├── widgets/          # Reusable UI components
├── firebase_options.dart  # Firebase configuration
└── main.dart         # App entry point
```

## 🔥 Firebase Collections

### Products Collection
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "category": "string",
  "price": "double",
  "quantity": "int",
  "minStockLevel": "int",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Users Collection
```json
{
  "uid": "string",
  "email": "string",
  "role": "string",
  "createdAt": "timestamp"
}
```

### Categories Collection
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

### Core Dependencies
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication services
- `cloud_firestore` - Database operations
- `provider` - State management

### Utility Dependencies
- `excel` - Excel file generation
- `share_plus` - File sharing functionality
- `path_provider` - File system access

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Priyanshu Choudhary**
- GitHub: [@priyaanshu26](https://github.com/priyaanshu26)
- Email: priyanshu.171561@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- The open-source community for various packages used

## 📞 Support

If you have any questions or need help with setup, please open an issue or reach out via email.

---

⭐ **Star this repository if you found it helpful!** ⭐
