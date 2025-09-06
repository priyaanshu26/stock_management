import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/auth_provider.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/product_form_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Consumer2<AuthProvider, InventoryProvider>(
            builder: (context, authProvider, inventoryProvider, child) {
              if (inventoryProvider.products.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'export_csv') {
                    _exportToCSV(inventoryProvider.products);
                  } else if (value == 'export_excel') {
                    _exportToExcel(inventoryProvider.products);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export_csv',
                    child: Row(
                      children: [
                        Icon(Icons.file_download),
                        SizedBox(width: 8),
                        Text('Export to CSV'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_excel',
                    child: Row(
                      children: [
                        Icon(Icons.table_chart),
                        SizedBox(width: 8),
                        Text('Export to Excel'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, InventoryProvider>(
        builder: (context, authProvider, inventoryProvider, child) {
          if (inventoryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (inventoryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inventoryProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      inventoryProvider.clearError();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredProducts = _getFilteredProducts(inventoryProvider.products);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Products list
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No products found for "$_searchQuery"'
                                  : 'No products yet',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Try a different search term'
                                  : authProvider.isAdmin
                                      ? 'Add your first product to get started'
                                      : 'Products will appear here once added',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(context, product, authProvider.isAdmin);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAdmin) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton(
            onPressed: () => _showProductDialog(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProductDialog(context, product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, product),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Stock',
                    '${product.stock} units',
                    product.stock < 5 ? Colors.orange : Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Cost',
                    '₹${product.costPrice.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Selling',
                    '₹${product.sellingPrice.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit per unit:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₹${(product.sellingPrice - product.costPrice).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: (product.sellingPrice - product.costPrice) > 0
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _showDeleteDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
              final success = await inventoryProvider.deleteProduct(product.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Product deleted successfully'
                          : 'Failed to delete product',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(List<Product> products) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Generating CSV file...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Create CSV content
      String csvContent = 'Product Name,Category,Stock,Cost Price,Selling Price,Profit per Unit\n';
      
      for (Product product in products) {
        final profit = product.sellingPrice - product.costPrice;
        csvContent += '"${product.name}","${product.category}",${product.stock},${product.costPrice.toStringAsFixed(2)},${product.sellingPrice.toStringAsFixed(2)},${profit.toStringAsFixed(2)}\n';
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/products_export_$timestamp.csv');
      
      // Write CSV content to file
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Products Export - ${products.length} products',
        subject: 'Stock Management - Products Export',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exported successfully! (${products.length} products)'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share Again',
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export CSV: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToExcel(List<Product> products) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 16),
                Text('Generating Excel file...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // For now, we'll create a tab-separated values file that Excel can open
      // This is a simple approach that doesn't require additional dependencies
      String tsvContent = 'Product Name\tCategory\tStock\tCost Price\tSelling Price\tProfit per Unit\n';
      
      for (Product product in products) {
        final profit = product.sellingPrice - product.costPrice;
        tsvContent += '${product.name}\t${product.category}\t${product.stock}\t${product.costPrice.toStringAsFixed(2)}\t${product.sellingPrice.toStringAsFixed(2)}\t${profit.toStringAsFixed(2)}\n';
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/products_export_$timestamp.xlsx');
      
      // Write TSV content to file (Excel can open TSV files)
      await file.writeAsString(tsvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Products Export - ${products.length} products (Excel format)',
        subject: 'Stock Management - Products Export (Excel)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel file exported successfully! (${products.length} products)'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share Again',
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export Excel: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
