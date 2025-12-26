import 'package:flutter/material.dart';
import 'package:laza/extensions/context_extension.dart';
import 'package:laza/models/brand.dart';
import 'package:laza/models/product.dart';  // Updated
import 'package:laza/services/product_service.dart';

import 'cart_screen.dart';
import 'components/colors.dart';
import 'components/laza_icons.dart';
import 'components/product_card.dart';

class BrandProductsScreen extends StatefulWidget {
  const BrandProductsScreen({super.key, required this.brand});
  final Brand brand;

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final ProductService _productService = ProductService();
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => isLoading = true);
    products = await _productService.fetchProducts();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(
        brand: widget.brand,
        actions: [
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            },
            child: Ink(
              width: 45,
              height: 45,
              decoration: ShapeDecoration(
                color: context.theme.cardColor,
                shape: const CircleBorder(),
              ),
              child: const Icon(LazaIcons.bag),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${products.length} Items', style: context.bodyLargeW500),
                      const SizedBox(height: 5.0),
                      Text(
                        'Available in stock',
                        style: context.bodyMedium?.copyWith(color: ColorConstant.manatee),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        color: context.theme.cardColor,
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Icon(LazaIcons.sort, size: 10, color: context.bodyMediumW500?.color),
                          const SizedBox(width: 10.0),
                          Text('Sort', style: context.bodyMediumW500),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              isLoading
                  ? const Expanded(child: Center(child: CircularProgressIndicator()))
                  : Expanded(
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 250,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({super.key, required this.brand, this.actions});
  final Brand brand;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Container(
      height: kToolbarHeight,
      margin: EdgeInsets.only(top: context.viewPadding.top),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: canPop || actions != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            if (canPop)
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                onTap: () => Navigator.pop(context),
                child: Ink(
                  width: 45,
                  height: 45,
                  decoration: ShapeDecoration(
                    color: context.theme.cardColor,
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.arrow_back_outlined),
                ),
              ),
            if (!canPop && actions != null) const SizedBox(height: 45, width: 45),
            Container(
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Icon(
                brand.iconData,
                size: brand.name == 'Fila' ? 16 : 25,
              ),
            ),
            if (canPop && actions == null) const SizedBox(height: 45, width: 45),
            if (actions != null) Column(mainAxisSize: MainAxisSize.min, children: actions!),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}