import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_card.dart';
import 'wishlist_screen.dart';
import '../part3_dart/part3_dart.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();

    provider.loadWishlist();
    provider.loadCategories();
    provider.loadProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        provider.loadProducts();
      }
    });
  }

  // 🔍 Debounced Search
  void _onSearch(String query) {
    _debouncer.run(() {
      if (!mounted) return;
      context.read<ProductProvider>().searchProducts(query);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WishlistScreen()),
                ),
              ),
              if (provider.wishlist.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${provider.wishlist.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Container(
            color: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🏷 CATEGORY FILTER
          if (provider.categories.isNotEmpty)
            Container(
              color: Colors.white,
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: provider.categories.length,
                itemBuilder: (context, index) {
                  final cat = provider.categories[index];
                  final isSelected = provider.selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    child: GestureDetector(
                      onTap: () => provider.setCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 💰 PRICE FILTER
          Container(
            color: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('Price:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: RangeSlider(
                    values: provider.priceRange,
                    min: 0,
                    max: 5000,
                    activeColor: Colors.deepPurple,
                    onChanged: (values) =>
                        provider.setPriceRange(values),
                  ),
                ),
              ],
            ),
          ),

          // 📊 PRODUCT COUNT
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${products.length} products found',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // 🛒 PRODUCT GRID
          Expanded(
            child: products.isEmpty && provider.isLoading
                ? GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65, // 🔥 FIX
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const ShimmerCard(),
            )
                : products.isEmpty
                ? const Center(
              child: Text("No products found"),
            )
                : RefreshIndicator(
              onRefresh: () =>
                  provider.loadProducts(reset: true),
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65, // 🔥 FIX
                ),
                itemCount: products.length +
                    (provider.hasMore ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index >= products.length) {
                    return const ShimmerCard();
                  }
                  return ProductCard(
                      product: products[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}