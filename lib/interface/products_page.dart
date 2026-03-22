import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedCategory = 0;
  String _sortBy = 'Popular';
  final List<int> _wishlist = [];

  final List<String> _categories = [
    'All', 'Serums', 'Tools', 'Masks', 'Mists', 'Supplements',
  ];

  final List<String> _sortOptions = [
    'Popular', 'Price: Low', 'Price: High', 'Rating',
  ];

  final List<Map<String, dynamic>> _deals = [
    {
      'name': 'Gua Sha Stone Set',
      'originalPrice': '\$48',
      'salePrice': '\$28',
      'discount': '42% OFF',
      'icon': Icons.diamond_outlined,
      'color': const Color(0xFFD4A1C0),
    },
    {
      'name': 'Vitamin C Serum Bundle',
      'originalPrice': '\$90',
      'salePrice': '\$54',
      'discount': '40% OFF',
      'icon': Icons.science_outlined,
      'color': const Color(0xFFF5C97A),
    },
    {
      'name': 'Face Roller Kit',
      'originalPrice': '\$35',
      'salePrice': '\$22',
      'discount': '37% OFF',
      'icon': Icons.circle_outlined,
      'color': const Color(0xFFB4D4A8),
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Retinol 0.5% Serum',
      'brand': 'Medik8',
      'price': 58.0,
      'rating': 4.9,
      'reviews': 2341,
      'category': 'Serums',
      'badge': 'Best Seller',
      'badgeColor': Color(0xFFE8708A),
      'accent': Color(0xFFF8AFCB),
      'icon': Icons.science_rounded,
    },
    {
      'name': 'Jade Facial Roller',
      'brand': 'Herbivore',
      'price': 38.0,
      'rating': 4.7,
      'reviews': 891,
      'category': 'Tools',
      'badge': 'Trending',
      'badgeColor': Color(0xFF7EC4A4),
      'accent': Color(0xFFB4D4A8),
      'icon': Icons.spa_rounded,
    },
    {
      'name': 'Hyaluronic Serum',
      'brand': 'SkinCeuticals',
      'price': 98.0,
      'rating': 4.8,
      'reviews': 1203,
      'category': 'Serums',
      'badge': 'Premium',
      'badgeColor': Color(0xFFB8A0C8),
      'accent': Color(0xFFD4C0E8),
      'icon': Icons.water_drop_rounded,
    },
    {
      'name': 'Rose Clay Mask',
      'brand': 'Fresh',
      'price': 42.0,
      'rating': 4.6,
      'reviews': 756,
      'category': 'Masks',
      'badge': 'New',
      'badgeColor': Color(0xFF9EB8D4),
      'accent': Color(0xFFE8C8C8),
      'icon': Icons.blur_circular_rounded,
    },
    {
      'name': 'Rosewater Mist',
      'brand': 'Mario Badescu',
      'price': 12.0,
      'rating': 4.7,
      'reviews': 4521,
      'category': 'Mists',
      'badge': 'Fan Fave',
      'badgeColor': Color(0xFFE8708A),
      'accent': Color(0xFFF8AFCB),
      'icon': Icons.water_rounded,
    },
    {
      'name': 'Collagen Gummies',
      'brand': 'HUM Nutrition',
      'price': 26.0,
      'rating': 4.5,
      'reviews': 678,
      'category': 'Supplements',
      'badge': 'Wellness',
      'badgeColor': Color(0xFFF5C97A),
      'accent': Color(0xFFFFF0D6),
      'icon': Icons.favorite_rounded,
    },
    {
      'name': 'LED Light Therapy Mask',
      'brand': 'CurrentBody',
      'price': 380.0,
      'rating': 4.8,
      'reviews': 432,
      'category': 'Tools',
      'badge': 'Pro',
      'badgeColor': Color(0xFF9EB8D4),
      'accent': Color(0xFFD4E4F8),
      'icon': Icons.light_mode_rounded,
    },
    {
      'name': 'Overnight Sleeping Mask',
      'brand': 'Laneige',
      'price': 34.0,
      'rating': 4.9,
      'reviews': 3102,
      'category': 'Masks',
      'badge': 'Best Seller',
      'badgeColor': Color(0xFFE8708A),
      'accent': Color(0xFFF8AFCB),
      'icon': Icons.nightlight_round,
    },
    {
      'name': 'Bakuchiol Serum',
      'brand': 'Biossance',
      'price': 68.0,
      'rating': 4.7,
      'reviews': 987,
      'category': 'Serums',
      'badge': 'Natural',
      'badgeColor': Color(0xFF7EC4A4),
      'accent': Color(0xFFD4E8D4),
      'icon': Icons.eco_rounded,
    },
    {
      'name': 'Microcurrent Device',
      'brand': 'NuFace',
      'price': 209.0,
      'rating': 4.6,
      'reviews': 1542,
      'category': 'Tools',
      'badge': 'Pro',
      'badgeColor': Color(0xFFB8A0C8),
      'accent': Color(0xFFE8D8F0),
      'icon': Icons.bolt_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredAndSorted {
    var list = _selectedCategory == 0
        ? List<Map<String, dynamic>>.from(_products)
        : _products
            .where((p) => p['category'] == _categories[_selectedCategory])
            .toList();

    switch (_sortBy) {
      case 'Price: Low':
        list.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High':
        list.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Rating':
        list.sort((a, b) =>
            (b['rating'] as double).compareTo(a['rating'] as double));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildDealsSection()),
          SliverToBoxAdapter(child: _buildFilterRow()),
          SliverToBoxAdapter(child: _buildSortBar()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 210,
      pinned: true,
      backgroundColor: _surface,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: _textPrimary),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_rounded,
                    size: 20, color: _textPrimary),
                onPressed: () {},
              ),
              if (_wishlist.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: _rose,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_wishlist.length}',
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
            gradient: LinearGradient(
              colors: [Color(0xFFFFF8E8), Color(0xFFFDF7FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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
                    child: const Text(
                      '🛍️ PRODUCTS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB8902A),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Curated Beauty\nEssentials',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_products.length} hand-picked products',
                    style: const TextStyle(fontSize: 13, color: _textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Deals Section ───────────────────────────────────────────────────────────
  Widget _buildDealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔥 Flash Deals'),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _deals.length,
            itemBuilder: (context, i) {
              final deal = _deals[i];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                (deal['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            deal['icon'] as IconData,
                            size: 18,
                            color: deal['color'] as Color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _rose.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deal['discount'] as String,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _roseDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      deal['name'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          deal['salePrice'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _roseDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deal['originalPrice'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Filter Row ──────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('All Products'),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    gradient: active
                        ? const LinearGradient(colors: [_rose, _orchid])
                        : null,
                    color: active ? null : _card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: active
                            ? _rose.withOpacity(0.25)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _categories[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : _textMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Sort Bar ────────────────────────────────────────────────────────────────
  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            '${_filteredAndSorted.length} items',
            style: const TextStyle(
              fontSize: 13,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Text(
            'Sort: ',
            style: TextStyle(fontSize: 13, color: _textMuted),
          ),
          GestureDetector(
            onTap: () => _showSortSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortBy,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: _textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map(
              (option) => GestureDetector(
                onTap: () {
                  setState(() => _sortBy = option);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _sortBy == option
                        ? _rose.withOpacity(0.08)
                        : _card,
                    borderRadius: BorderRadius.circular(12),
                    border: _sortBy == option
                        ? Border.all(
                            color: _rose.withOpacity(0.3),
                            width: 1.2,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _sortBy == option
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _sortBy == option ? _roseDark : _textPrimary,
                        ),
                      ),
                      if (_sortBy == option)
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: _rose),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              color: _orchidDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Products Grid ───────────────────────────────────────────────────────────
  Widget _buildProductsGrid() {
    final items = _filteredAndSorted;
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final product = items[i];
          final inWishlist = _wishlist.contains(i);
          return _FullProductCard(
            name: product['name'] as String,
            brand: product['brand'] as String,
            price: product['price'] as double,
            rating: product['rating'] as double,
            reviews: product['reviews'] as int,
            badge: product['badge'] as String,
            badgeColor: product['badgeColor'] as Color,
            accent: product['accent'] as Color,
            icon: product['icon'] as IconData,
            inWishlist: inWishlist,
            onWishlistToggle: () {
              setState(() {
                inWishlist ? _wishlist.remove(i) : _wishlist.add(i);
              });
            },
          );
        },
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
    );
  }
}

// ── Full Product Card ─────────────────────────────────────────────────────────
class _FullProductCard extends StatefulWidget {
  const _FullProductCard({
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.badge,
    required this.badgeColor,
    required this.accent,
    required this.icon,
    required this.inWishlist,
    required this.onWishlistToggle,
  });

  final String name;
  final String brand;
  final double price;
  final double rating;
  final int reviews;
  final String badge;
  final Color badgeColor;
  final Color accent;
  final IconData icon;
  final bool inWishlist;
  final VoidCallback onWishlistToggle;

  @override
  State<_FullProductCard> createState() => _FullProductCardState();
}

class _FullProductCardState extends State<_FullProductCard> {
  bool _inCart = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Visual header ──────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accent.withOpacity(0.5),
                        widget.accent.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: widget.badgeColor.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, size: 28, color: widget.badgeColor),
                    ),
                  ),
                ),
                // Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.badgeColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      widget.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Wishlist
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onWishlistToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.inWishlist
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: widget.inWishlist
                            ? const Color(0xFFE8708A)
                            : const Color(0xFF9E8DA8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1224),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.brand,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF9E8DA8)),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 11, color: Color(0xFFFFC107)),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.rating}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E8DA8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.reviews})',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9E8DA8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${widget.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC2516B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _inCart = !_inCart),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: _inCart
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFE8708A),
                                      Color(0xFFF8AFCB),
                                    ],
                                  )
                                : null,
                            color: _inCart
                                ? null
                                : const Color(0xFFF8AFCB).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            _inCart ? '✓ Added' : '+ Cart',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: _inCart
                                  ? Colors.white
                                  : const Color(0xFFE8708A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}