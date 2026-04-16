import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import '../utils/image_generator.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    
    final result = await ApiService.post('cart.php', {
      'action': 'add',
      'product_id': widget.product['id'],
      'quantity': 1,
    });
    
    setState(() => _adding = false);
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to cart!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.product['final_price']?.toString() ?? 
                  widget.product['price'].toString();
    final images = widget.product['images'] as List? ?? [];
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.product['name'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: images.isNotEmpty
                ? Image.network(images[0], fit: BoxFit.contain)
                : GeneratedProductImage(
                    productName: widget.product['name'],
                    size: 200,
                  ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.product['description'] ?? 'No description available',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 24),
                  
                  // Stock status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.product['stock_quantity'] > 0 
                        ? Colors.green.shade50 
                        : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product['stock_quantity'] > 0
                        ? '✓ In Stock (${widget.product['stock_quantity']} available)'
                        : '✗ Out of Stock',
                      style: TextStyle(
                        color: widget.product['stock_quantity'] > 0
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.product['stock_quantity'] > 0 && !_adding
                            ? _addToCart
                            : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _adding
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('Add to Cart'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.product['stock_quantity'] > 0 ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text('Buy Now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
