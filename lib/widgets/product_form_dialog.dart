import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../providers/category_provider.dart';
import 'category_dropdown_field.dart';

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();

  String? _selectedCategoryId;
  bool _isLoading = false;
  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
      _stockController.text = widget.product!.stock.toString();
      
      // Find category ID by name for existing products
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        final categories = categoryProvider.categories;
        final matchingCategory = categories.firstWhere(
          (cat) => cat.name == widget.product!.category,
          orElse: () => categories.isNotEmpty ? categories.first : throw StateError('No categories'),
        );
        if (categories.isNotEmpty) {
          setState(() {
            _selectedCategoryId = matchingCategory.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Product name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                CategoryDropdownField(
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (categoryId) {
                    setState(() {
                      _selectedCategoryId = categoryId;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  hintText: 'Select or add a category',
                ),
                const SizedBox(height: 16),

                // Cost Price and Selling Price Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Cost Price *',
                          border: OutlineInputBorder(),
                          prefixText: '₹',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Cost price is required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Selling Price *',
                          border: OutlineInputBorder(),
                          prefixText: '₹',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Selling price is required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price < 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stock
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock *',
                    border: OutlineInputBorder(),
                    suffixText: 'units',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Stock is required';
                    }
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Enter a valid stock number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Profit calculation display
                ValueListenableBuilder(
                  valueListenable: _costPriceController,
                  builder: (context, costValue, child) {
                    return ValueListenableBuilder(
                      valueListenable: _sellingPriceController,
                      builder: (context, sellingValue, child) {
                        final costPrice = double.tryParse(costValue.text) ?? 0;
                        final sellingPrice = double.tryParse(sellingValue.text) ?? 0;
                        final profit = sellingPrice - costPrice;
                        final profitMargin = costPrice > 0 ? (profit / costPrice) * 100 : 0;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: profit >= 0 ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: profit >= 0 ? Colors.green[200]! : Colors.red[200]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Profit per unit:'),
                                  Text(
                                    '₹${profit.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (costPrice > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Profit margin:'),
                                    Text(
                                      '${profitMargin.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: profit >= 0 ? Colors.green[700] : Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(_isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      
      // Get category name from ID
      final selectedCategory = categoryProvider.getCategoryById(_selectedCategoryId!);
      if (selectedCategory == null) {
        throw Exception('Selected category not found');
      }
      
      final product = Product(
        id: _isEditing ? widget.product!.id : '',
        name: _nameController.text.trim(),
        costPrice: double.parse(_costPriceController.text),
        sellingPrice: double.parse(_sellingPriceController.text),
        stock: int.parse(_stockController.text),
        category: selectedCategory.name,
        createdAt: _isEditing ? widget.product!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await inventoryProvider.updateProduct(product);
      } else {
        success = await inventoryProvider.addProduct(product);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Product updated successfully'
                    : 'Product added successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Failed to update product'
                    : 'Failed to add product',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}