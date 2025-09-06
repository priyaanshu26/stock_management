import '../models/product_category.dart';
import '../services/firestore_service.dart';

class DefaultCategoriesSetup {
  static final FirestoreService _firestoreService = FirestoreService();

  static final List<Map<String, String>> _defaultCategories = [
    {
      'name': 'Electronics',
      'description': 'Electronic devices and accessories',
    },
    {
      'name': 'Clothing',
      'description': 'Apparel and fashion items',
    },
    {
      'name': 'Food & Beverages',
      'description': 'Food items and drinks',
    },
    {
      'name': 'Books',
      'description': 'Books and educational materials',
    },
    {
      'name': 'Home & Garden',
      'description': 'Home improvement and gardening items',
    },
    {
      'name': 'Sports & Outdoors',
      'description': 'Sports equipment and outdoor gear',
    },
    {
      'name': 'Health & Beauty',
      'description': 'Health and beauty products',
    },
    {
      'name': 'Toys & Games',
      'description': 'Toys and gaming products',
    },
  ];

  static Future<void> setupDefaultCategories() async {
    try {
      // Get existing categories to avoid duplicates
      final existingCategories = await _firestoreService.getCategories().first;
      final existingNames = existingCategories.map((cat) => cat.name.toLowerCase()).toSet();

      for (final categoryData in _defaultCategories) {
        final categoryName = categoryData['name']!;
        
        // Skip if category already exists
        if (existingNames.contains(categoryName.toLowerCase())) {
          continue;
        }

        final category = ProductCategory(
          id: '', // Will be set by Firestore
          name: categoryName,
          description: categoryData['description']!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.addCategory(category);
      }
    } catch (e) {
      // Handle error silently or log it
      print('Error setting up default categories: $e');
    }
  }
}