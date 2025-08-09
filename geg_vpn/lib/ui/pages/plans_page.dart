import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/providers.dart';

class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});

  @override
  ConsumerState<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends ConsumerState<PlansPage> {
  @override
  void initState() {
    super.initState();
    ref.read(billingServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your plan', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<ProductDetails>>(
                stream: ref.read(billingServiceProvider).productsStream,
                builder: (context, snap) {
                  final products = snap.data ?? [];
                  if (products.isEmpty) {
                    return const Center(child: Text('Loading plans…'));
                  }
                  return ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return Card(
                        child: ListTile(
                          title: Text(p.title),
                          subtitle: Text(p.description),
                          trailing: ElevatedButton(
                            onPressed: () => ref.read(billingServiceProvider).buy(p),
                            child: Text(p.price),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}