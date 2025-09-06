import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_category.dart';
import '../providers/category_provider.dart';

class CategoryDropdownField extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final String hintText;
  final bool enabled;

  const CategoryDropdownField({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
    this.validator,
    this.hintText = 'Select a category',
    this.enabled = true,
  });

  @override
  State<CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<CategoryDropdownField> {
  final TextEditingController _newCategoryController = TextEditingController();
  final TextEditingController _newCategoryDescController = TextEditingController();

  @override
  void dispose() {
    _newCategoryController.dispose();
    _newCategoryDescController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    _newCategoryController.clear();
    _newCategoryDescController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newCategoryDescController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addNewCategory(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewCategory() async {
    final categoryName = _newCategoryController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    // Check if category already exists
    if (categoryProvider.categoryExists(categoryName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newCategory = ProductCategory(
      id: '', // Will be set by Firestore
      name: categoryName,
      description: _newCategoryDescController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await categoryProvider.addCategory(newCategory);
    
    if (mounted) {
      Navigator.of(context).pop();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Auto-select the new category
        // We'll need to wait a moment for the stream to update
        Future.delayed(const Duration(milliseconds: 500), () {
          final categories = categoryProvider.categories;
          final addedCategory = categories.firstWhere(
            (cat) => cat.name == categoryName,
            orElse: () => categories.first,
          );
          widget.onChanged(addedCategory.id);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${categoryProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: widget.selectedCategoryId,
              isExpanded: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.category),
                suffixIcon: widget.enabled
                    ? IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddCategoryDialog,
                        tooltip: 'Add new category',
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: widget.validator,
              items: [
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }),
              ],
              onChanged: widget.enabled ? widget.onChanged : null,
            ),
            if (categories.isEmpty && !categoryProvider.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'No categories available. Click + to add one.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}