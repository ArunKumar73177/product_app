import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(imageUrl: product.thumbnail),
            const SizedBox(height: 16),
            Text(product.title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text('\$${product.price}',
                style:
                const TextStyle(fontSize: 18, color: Colors.green)),
            Row(children: [
              const Icon(Icons.star, color: Colors.amber),
              Text('${product.rating}'),
            ]),
            const SizedBox(height: 8),
            Text(product.description),
          ],
        ),
      ),
    );
  }
}