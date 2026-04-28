import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: product.thumbnail,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      ),
      title: Text(product.title),
      subtitle: Text('\$${product.price}'),
      trailing: IconButton(
        icon: Icon(
          provider.isWishlisted(product.id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: Colors.red,
        ),
        onPressed: () => provider.toggleWishlist(product.id),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
    );
  }
}