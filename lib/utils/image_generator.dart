import 'package:flutter/material.dart';
import 'dart:math';

class GeneratedProductImage extends StatelessWidget {
  final String productName;
  final double size;

  const GeneratedProductImage({
    super.key,
    required this.productName,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    final firstChar = productName.isNotEmpty ? productName[0].toUpperCase() : '?';
    final random = Random(productName.hashCode);
    
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    
    final bgColor = colors[random.nextInt(colors.length)];
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForProduct(productName),
              size: size * 0.3,
              color: Colors.white70,
            ),
            SizedBox(height: 8),
            Text(
              firstChar,
              style: TextStyle(
                fontSize: size * 0.25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForProduct(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('phone') || lower.contains('mobile')) return Icons.phone_android;
    if (lower.contains('laptop') || lower.contains('computer')) return Icons.laptop;
    if (lower.contains('headphone') || lower.contains('earphone')) return Icons.headphones;
    if (lower.contains('watch')) return Icons.watch;
    if (lower.contains('shirt') || lower.contains('t-shirt') || lower.contains('cloth')) 
      return Icons.checkroom;
    if (lower.contains('shoe')) return Icons.directions_walk;
    if (lower.contains('book')) return Icons.book;
    if (lower.contains('furniture') || lower.contains('sofa') || lower.contains('chair')) 
      return Icons.chair;
    if (lower.contains('bag') || lower.contains('backpack')) return Icons.shopping_bag;
    return Icons.shopping_basket;
  }
}
