// product.dart - COPY THIS WHOLE FILE
class Product {
  final int id;
  final String title;
  final String price;
  final String description;
  final String image;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle images array - make sure URLs are valid
    var imageList = json['images'] as List<dynamic>? ?? [];
    List<String> images = imageList
        .map((i) => i.toString())
        .where((url) => url.isNotEmpty && url.startsWith('http'))
        .toList();

    // Handle main image
    String? mainImage = json['image'] as String?;

    // Clean the main image URL
    if (mainImage != null && mainImage.isNotEmpty) {
      // Remove any brackets or quotes from the URL
      mainImage = mainImage.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
    }

    // If main image is empty/invalid but we have images array, use first image
    if ((mainImage == null || mainImage.isEmpty || !mainImage.startsWith('http')) &&
        images.isNotEmpty) {
      mainImage = images.first;
    }

    // Fallback to placeholder
    if (mainImage == null || mainImage.isEmpty || !mainImage.startsWith('http')) {
      mainImage = 'https://via.placeholder.com/150';
    }

    // If images array is empty but we have a main image, add it to images
    if (images.isEmpty && mainImage.startsWith('http')) {
      images = [mainImage];
    }

    // Handle price formatting
    double? priceValue;
    try {
      priceValue = (json['price'] as num?)?.toDouble();
    } catch (e) {
      priceValue = 0.0;
    }

    String priceString = '\$${priceValue?.toStringAsFixed(2) ?? '0.00'}';

    return Product(
      id: json['id'] as int,
      title: (json['title'] as String? ?? 'Untitled').trim(),
      price: priceString,
      description: (json['description'] as String? ?? 'No description available').trim(),
      image: mainImage,
      images: images,
    );
  }
}