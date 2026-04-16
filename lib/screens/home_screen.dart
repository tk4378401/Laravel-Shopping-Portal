import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import '../utils/image_generator.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await ApiService.get('products.php?featured=1&limit=10');
      final categories = await ApiService.get('categories.php');
      setState(() {
        _products = products['success'] ? products['products'] : [];
        _categories = categories['success'] ? categories['categories'] : [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(),
      CartScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Portal'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_loading) return Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () {},
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(_categories[i]['name'][0]),
                      ),
                      SizedBox(height: 4),
                      Text(_categories[i]['name'], textAlign: TextAlign.center, maxLines: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Products
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Featured Products', style: Theme.of(context).textTheme.titleLarge),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _products.length,
            itemBuilder: (_, i) => ProductCard(product: _products[i]),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final price = product['final_price']?.toString() ?? product['price'].toString();
    final images = product['images'] as List? ?? [];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: images.isNotEmpty
                  ? Image.network(
                      images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => GeneratedProductImage(
                        productName: product['name'],
                      ),
                    )
                  : GeneratedProductImage(productName: product['name']),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
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
}
