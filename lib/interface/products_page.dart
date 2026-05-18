import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) throw Exception();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Unable to open product page'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedCategory = 0;
  String _sortBy = 'Popular';
  final List<int> _lkWishlist   = [];
  final List<int> _intlWishlist = [];

  final List<String> _categories  = ['All', 'Serums', 'Tools', 'Masks', 'Mists', 'Supplements'];
  final List<String> _sortOptions = ['Popular', 'Price: Low', 'Price: High', 'Rating'];

  // ── Sri Lankan products ───────────────────────────────────────────────────
  final List<Map<String, dynamic>> _lkProducts = [
    {
      'name': 'Coconut Oil Serum',
      'brand': 'Spa Ceylon',
      'price': 2800.0, 'displayPrice': 'Rs. 2,800',
      'rating': 4.9, 'reviews': 1240,
      'category': 'Serums', 'badge': 'Luxury',
      'badgeColor': Color(0xFFD4A820), 'accent': Color(0xFFFFF0D6),
      'image': 'assets/images/products/lk/1.png',
      'buyUrl': 'https://spaceylon.com/collections/serums',
    },
    {
      'name': 'Neem Herbal Mask',
      'brand': 'Siddhalepa',
      'price': 680.0, 'displayPrice': 'Rs. 680',
      'rating': 4.6, 'reviews': 874,
      'category': 'Masks', 'badge': 'Ayurvedic',
      'badgeColor': Color(0xFF7EC4A4), 'accent': Color(0xFFEEFAF4),
      'image': 'assets/images/products/lk/2.png',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=siddhalepa+neem+herbal+mask',
    },
    {
      'name': 'Aloe Vera Mist',
      'brand': 'Janet',
      'price': 380.0, 'displayPrice': 'Rs. 380',
      'rating': 4.5, 'reviews': 632,
      'category': 'Mists', 'badge': 'Natural',
      'badgeColor': Color(0xFFB4D4A8), 'accent': Color(0xFFEEFAF4),
      'image': 'assets/images/products/lk/3.webp',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=janet+aloe+vera+mist',
    },
    {
      'name': 'Turmeric Glow Mask',
      'brand': 'Swabha Ceylon',
      'price': 1850.0, 'displayPrice': 'Rs. 1,850',
      'rating': 4.7, 'reviews': 521,
      'category': 'Masks', 'badge': 'Best Seller',
      'badgeColor': Color(0xFFE8708A), 'accent': Color(0xFFFFF8E1),
      'image': 'assets/images/products/lk/4.webp',
      'buyUrl': 'https://www.swabhaceylon.com',
    },
    {
      'name': 'Vitamin C Brightening Serum',
      'brand': 'British Cosmetics',
      'price': 1900.0, 'displayPrice': 'Rs. 1,900',
      'rating': 4.6, 'reviews': 398,
      'category': 'Serums', 'badge': 'New',
      'badgeColor': Color(0xFF9EB8D4), 'accent': Color(0xFFEEF4FF),
      'image': 'assets/images/products/lk/5.webp',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=british+cosmetics+vitamin+c+brightening+serum',
    },
    {
      'name': 'Herbal Body Mist',
      'brand': 'Spa Ceylon',
      'price': 2200.0, 'displayPrice': 'Rs. 2,200',
      'rating': 4.8, 'reviews': 703,
      'category': 'Mists', 'badge': 'Popular',
      'badgeColor': Color(0xFFD4A820), 'accent': Color(0xFFFFF8E1),
      'image': 'assets/images/products/lk/6.webp',
      'buyUrl': 'https://spaceylon.com/collections/body-mists',
    },
    {
      'name': 'Organic Rose Hip Serum',
      'brand': 'D\'las',
      'price': 1600.0, 'displayPrice': 'Rs. 1,600',
      'rating': 4.7, 'reviews': 284,
      'category': 'Serums', 'badge': 'Organic',
      'badgeColor': Color(0xFF7EC4A4), 'accent': Color(0xFFD4E8D4),
      'image': 'assets/images/products/lk/7.jpg',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=dlas+rosehip+serum',
    },
    {
      'name': 'Collagen Beauty Supplement',
      'brand': 'Prevense',
      'price': 3200.0, 'displayPrice': 'Rs. 3,200',
      'rating': 4.5, 'reviews': 156,
      'category': 'Supplements', 'badge': 'Wellness',
      'badgeColor': Color(0xFFB8A0C8), 'accent': Color(0xFFEEE8F8),
      'image': 'assets/images/products/lk/8.png',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=prevense+collagen+beauty+supplement',
    },
    {
      'name': 'Gua Sha Stone',
      'brand': 'Spa Ceylon',
      'price': 3800.0, 'displayPrice': 'Rs. 3,800',
      'rating': 4.8, 'reviews': 412,
      'category': 'Tools', 'badge': 'Luxury',
      'badgeColor': Color(0xFFD4A820), 'accent': Color(0xFFFFF8E1),
      'image': 'assets/images/products/lk/9.avif',
      'buyUrl': 'https://www.daraz.lk/tag/guva-sha/',
    },
    {
      'name': 'Herbal Exfoliating Scrub',
      'brand': 'Janet',
      'price': 460.0, 'displayPrice': 'Rs. 460',
      'rating': 4.4, 'reviews': 341,
      'category': 'Masks', 'badge': 'Value',
      'badgeColor': Color(0xFF7EC4A4), 'accent': Color(0xFFEEFAF4),
      'image': 'assets/images/products/lk/10.webp',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=janet+herbal+exfoliating+scrub',
    },
  ];

  // ── International products ────────────────────────────────────────────────
  final List<Map<String, dynamic>> _intlProducts = [
    {
      'name': 'Retinol 0.5% Serum',
      'brand': 'Medik8',
      'price': 58.0, 'displayPrice': '\$58',
      'rating': 4.9, 'reviews': 2341,
      'category': 'Serums', 'badge': 'Best Seller',
      'badgeColor': Color(0xFFE8708A), 'accent': Color(0xFFF8AFCB),
      'image': 'assets/images/products/intl/11.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=Medik8+Retinol+0.5+Serum',
    },
    {
      'name': 'Jade Facial Roller',
      'brand': 'Herbivore',
      'price': 38.0, 'displayPrice': '\$38',
      'rating': 4.7, 'reviews': 891,
      'category': 'Tools', 'badge': 'Trending',
      'badgeColor': Color(0xFF7EC4A4), 'accent': Color(0xFFB4D4A8),
      'image': 'assets/images/products/intl/12.webp',
      'buyUrl': 'https://www.amazon.com/s?k=Herbivore+Jade+Facial+Roller',
    },
    {
      'name': 'Hyaluronic Serum',
      'brand': 'SkinCeuticals',
      'price': 98.0, 'displayPrice': '\$98',
      'rating': 4.8, 'reviews': 1203,
      'category': 'Serums', 'badge': 'Premium',
      'badgeColor': Color(0xFFB8A0C8), 'accent': Color(0xFFD4C0E8),
      'image': 'assets/images/products/intl/13.webp',
      'buyUrl': 'https://www.amazon.com/s?k=SkinCeuticals+Hyaluronic+Acid+Intensifier+Serum',
    },
    {
      'name': 'Rose Clay Mask',
      'brand': 'Fresh',
      'price': 42.0, 'displayPrice': '\$42',
      'rating': 4.6, 'reviews': 756,
      'category': 'Masks', 'badge': 'New',
      'badgeColor': Color(0xFF9EB8D4), 'accent': Color(0xFFE8C8C8),
      'image': 'assets/images/products/intl/14.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=Fresh+Umbrian+Clay+Pore+Purifying+Face+Mask',
    },
    {
      'name': 'Rosewater Mist',
      'brand': 'Mario Badescu',
      'price': 12.0, 'displayPrice': '\$12',
      'rating': 4.7, 'reviews': 4521,
      'category': 'Mists', 'badge': 'Fan Fave',
      'badgeColor': Color(0xFFE8708A), 'accent': Color(0xFFF8AFCB),
      'image': 'assets/images/products/intl/15.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=Mario+Badescu+Facial+Spray+Rosewater',
    },
    {
      'name': 'Collagen Gummies',
      'brand': 'HUM Nutrition',
      'price': 26.0, 'displayPrice': '\$26',
      'rating': 4.5, 'reviews': 678,
      'category': 'Supplements', 'badge': 'Wellness',
      'badgeColor': Color(0xFFF5C97A), 'accent': Color(0xFFFFF0D6),
      'image': 'assets/images/products/intl/16.avif',
      'buyUrl': 'https://www.amazon.com/s?k=HUM+Nutrition+Collagen+Love+Gummies',
    },
    {
      'name': 'LED Light Mask',
      'brand': 'CurrentBody',
      'price': 380.0, 'displayPrice': '\$380',
      'rating': 4.8, 'reviews': 432,
      'category': 'Tools', 'badge': 'Pro',
      'badgeColor': Color(0xFF9EB8D4), 'accent': Color(0xFFD4E4F8),
      'image': 'assets/images/products/intl/17.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=CurrentBody+Skin+LED+Light+Therapy+Mask',
    },
    {
      'name': 'Overnight Sleeping Mask',
      'brand': 'Laneige',
      'price': 34.0, 'displayPrice': '\$34',
      'rating': 4.9, 'reviews': 3102,
      'category': 'Masks', 'badge': 'Best Seller',
      'badgeColor': Color(0xFFE8708A), 'accent': Color(0xFFF8AFCB),
      'image': 'assets/images/products/intl/18.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=Laneige+Water+Sleeping+Mask',
    },
  ];

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> list) {
    var filtered = _selectedCategory == 0
        ? List<Map<String, dynamic>>.from(list)
        : list.where((p) => p['category'] == _categories[_selectedCategory]).toList();
    switch (_sortBy) {
      case 'Price: Low':
        filtered.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High':
        filtered.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Rating':
        filtered.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
    }
    return filtered;
  }

  // ── See All sheet ─────────────────────────────────────────────────────────
  void _showSeeAll({
    required List<Map<String, dynamic>> products,
    required bool isLocal,
    required String title,
    required Color accentColor,
  }) {
    final sorted = List<Map<String, dynamic>>.from(products);
    switch (_sortBy) {
      case 'Price: Low':
        sorted.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High':
        sorted.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Rating':
        sorted.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          final wishlist = isLocal ? _lkWishlist : _intlWishlist;
          return Container(
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _textPrimary,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 2),
                            Text('${sorted.length} products',
                                style: const TextStyle(
                                    fontSize: 13, color: _textMuted)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8)],
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: _textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
                Expanded(
                  child: StatefulBuilder(
                    builder: (context, setSheetState) => GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: sorted.length,
                      itemBuilder: (context, i) {
                        final p = sorted[i];
                        final fullIdx = products.indexOf(p);
                        return _ProductCard(
                          name: p['name'] as String,
                          brand: p['brand'] as String,
                          displayPrice: p['displayPrice'] as String,
                          rating: p['rating'] as double,
                          reviews: p['reviews'] as int,
                          badge: p['badge'] as String,
                          badgeColor: p['badgeColor'] as Color,
                          accent: p['accent'] as Color,
                          imagePath: p['image'] as String,
                          isLocal: isLocal,
                          buyUrl: p['buyUrl'] as String,
                          inWishlist: wishlist.contains(fullIdx),
                          onWishlistToggle: () {
                            setSheetState(() {
                              setState(() {
                                wishlist.contains(fullIdx)
                                    ? wishlist.remove(fullIdx)
                                    : wishlist.add(fullIdx);
                              });
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lkFiltered   = _applyFilter(_lkProducts);
    final intlFiltered = _applyFilter(_intlProducts);

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildTopBar(lkFiltered.length + intlFiltered.length)),
          SliverToBoxAdapter(
            child: _BrandSectionHeader(
              emoji: '🇱🇰', title: 'Sri Lankan Brands',
              subtitle: 'Shop local · Ayurvedic, organic & homegrown',
              bgColor: const Color(0xFFFFF8E1), accentColor: const Color(0xFFD4A820),
              onSeeAll: () => _showSeeAll(
                products: _lkProducts,
                isLocal: true,
                title: '🇱🇰 Sri Lankan Brands',
                accentColor: const Color(0xFFD4A820),
              ),
            ),
          ),
          if (lkFiltered.isEmpty)
            const SliverToBoxAdapter(child: _EmptyFilter())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: _buildGrid(lkFiltered, isLocal: true, offset: 0),
            ),
          SliverToBoxAdapter(
            child: _BrandSectionHeader(
              emoji: '🌍', title: 'International Brands',
              subtitle: 'Global favourites · premium & trusted',
              bgColor: const Color(0xFFEEF4FF), accentColor: const Color(0xFF5A7AB8),
              onSeeAll: () => _showSeeAll(
                products: _intlProducts,
                isLocal: false,
                title: '🌍 International Brands',
                accentColor: const Color(0xFF5A7AB8),
              ),
            ),
          ),
          if (intlFiltered.isEmpty)
            const SliverToBoxAdapter(child: _EmptyFilter())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: _buildGrid(intlFiltered, isLocal: false, offset: _lkProducts.length),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200, pinned: true, backgroundColor: _surface,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textPrimary),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_rounded, size: 20, color: _textPrimary),
                onPressed: () {},
              ),
              if (_lkWishlist.isNotEmpty || _intlWishlist.isNotEmpty)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 14, height: 14,
                    decoration: const BoxDecoration(color: _rose, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${_lkWishlist.length + _intlWishlist.length}',
                          style: const TextStyle(fontSize: 8, color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFFF8E8), Color(0xFFFDF7FA)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C97A).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🛍️ PRODUCTS',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: Color(0xFFB8902A), letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 6),
                  const Text('Curated Beauty\nEssentials',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: _textPrimary, height: 1.2, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('${_lkProducts.length} local · ${_intlProducts.length} international',
                      style: const TextStyle(fontSize: 13, color: _textMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int totalCount) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            itemCount: _categories.length,
            itemBuilder: (context, i) {
              final active = _selectedCategory == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: active ? const LinearGradient(colors: [_rose, _orchid]) : null,
                    color: active ? null : _card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: active ? _rose.withOpacity(0.25) : Colors.black.withOpacity(0.05),
                      blurRadius: 8, offset: const Offset(0, 3),
                    )],
                  ),
                  child: Text(_categories[i],
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _textMuted)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Text('$totalCount items',
                  style: const TextStyle(fontSize: 13, color: _textMuted,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: _showSortSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _card, borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                        blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.sort_rounded, size: 14, color: _textMuted),
                    const SizedBox(width: 5),
                    Text(_sortBy, style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600, color: _textPrimary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: _textMuted),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: _surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: _textPrimary)),
            const SizedBox(height: 16),
            ..._sortOptions.map((option) => GestureDetector(
              onTap: () { setState(() => _sortBy = option); Navigator.pop(context); },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _sortBy == option ? _rose.withOpacity(0.08) : _card,
                  borderRadius: BorderRadius.circular(12),
                  border: _sortBy == option
                      ? Border.all(color: _rose.withOpacity(0.3), width: 1.2) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(option, style: TextStyle(fontSize: 14,
                        fontWeight: _sortBy == option ? FontWeight.w700 : FontWeight.w500,
                        color: _sortBy == option ? _roseDark : _textPrimary)),
                    if (_sortBy == option)
                      const Icon(Icons.check_circle_rounded, size: 18, color: _rose),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items,
      {required bool isLocal, required int offset}) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final p = items[i];
          final idx = offset + i;
          final wishlist = isLocal ? _lkWishlist : _intlWishlist;
          return _ProductCard(
            name: p['name'] as String,
            brand: p['brand'] as String,
            displayPrice: p['displayPrice'] as String,
            rating: p['rating'] as double,
            reviews: p['reviews'] as int,
            badge: p['badge'] as String,
            badgeColor: p['badgeColor'] as Color,
            accent: p['accent'] as Color,
            imagePath: p['image'] as String,
            isLocal: isLocal,
            buyUrl: p['buyUrl'] as String,
            inWishlist: wishlist.contains(idx),
            onWishlistToggle: () => setState(() {
              wishlist.contains(idx) ? wishlist.remove(idx) : wishlist.add(idx);
            }),
          );
        },
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12,
        mainAxisSpacing: 12, childAspectRatio: 0.72,
      ),
    );
  }
}

// ── Shared Brand Section Header ───────────────────────────────────────────────
class _BrandSectionHeader extends StatelessWidget {
  const _BrandSectionHeader({
    required this.emoji, required this.title, required this.subtitle,
    required this.bgColor, required this.accentColor,
    this.onSeeAll,
  });
  final String emoji, title, subtitle;
  final Color bgColor, accentColor;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.2),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: accentColor)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11, color: accentColor.withOpacity(0.75))),
          ]),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: accentColor)),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Empty Filter ──────────────────────────────────────────────────────────────
class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Center(child: Text('No products in this category',
        style: TextStyle(fontSize: 13, color: Color(0xFF9E8DA8)))),
  );
}

// ── Product Card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,          required this.brand,
    required this.displayPrice,  required this.rating,
    required this.reviews,       required this.badge,
    required this.badgeColor,    required this.accent,
    required this.imagePath,     required this.isLocal,
    required this.buyUrl,        required this.inWishlist,
    required this.onWishlistToggle,
  });

  final String name, brand, displayPrice, badge, imagePath, buyUrl;
  final double rating;
  final int reviews;
  final Color badgeColor, accent;
  final bool isLocal, inWishlist;
  final VoidCallback onWishlistToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 12, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  fit: StackFit.expand, alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent.withOpacity(0.6), accent.withOpacity(0.18)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Image.asset(
                      imagePath,
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => Center(
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                                color: badgeColor.withOpacity(0.2),
                                blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 26, color: badgeColor.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: badgeColor,
                              borderRadius: BorderRadius.circular(7)),
                          child: Text(badge,
                              style: const TextStyle(color: Colors.white, fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                        if (isLocal) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFFD4A820),
                                borderRadius: BorderRadius.circular(7)),
                            child: const Text('🇱🇰',
                                style: TextStyle(fontSize: 9)),
                          ),
                        ],
                      ]),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: onWishlistToggle,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6)]),
                          child: Icon(
                            inWishlist ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 14,
                            color: inWishlist
                                ? const Color(0xFFE8708A) : const Color(0xFF9E8DA8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1224)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(brand,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E8DA8))),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFC107)),
                    const SizedBox(width: 2),
                    Text('$rating',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                            color: Color(0xFF9E8DA8))),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('($reviews)',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF9E8DA8)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(displayPrice,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                                color: Color(0xFFC2516B)),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _openUrl(context, buyUrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFFE8708A), Color(0xFFF8AFCB)]),
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [BoxShadow(
                                color: const Color(0xFFE8708A).withOpacity(0.3),
                                blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.shopping_bag_outlined, size: 11, color: Colors.white),
                            SizedBox(width: 3),
                            Text('Buy', style: TextStyle(fontSize: 10.5,
                                fontWeight: FontWeight.w700, color: Colors.white)),
                          ]),
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