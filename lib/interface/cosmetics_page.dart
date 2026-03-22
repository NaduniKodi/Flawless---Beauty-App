import 'package:flutter/material.dart';

class CosmeticsPage extends StatefulWidget {
  const CosmeticsPage({super.key});

  @override
  State<CosmeticsPage> createState() => _CosmeticsPageState();
}

class _CosmeticsPageState extends State<CosmeticsPage>
    with SingleTickerProviderStateMixin {
  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedFilter = 0;
  late TabController _tabController;

  final List<String> _filters = [
    'All', 'Lips', 'Eyes', 'Face', 'Nails', 'Fragrance',
  ];

  final List<Map<String, dynamic>> _featured = [
    {
      'name': 'Velvet Matte Lip',
      'brand': 'Fenty Beauty',
      'price': '\$22',
      'rating': 4.8,
      'tag': 'Best Seller',
      'color': const Color(0xFFE96A85),
      'icon': Icons.favorite,
    },
    {
      'name': 'Glossy Lip Oil',
      'brand': 'Charlotte Tilbury',
      'price': '\$28',
      'rating': 4.6,
      'tag': 'New',
      'color': const Color(0xFFD4A1C0),
      'icon': Icons.water_drop,
    },
    {
      'name': 'Liquid Liner',
      'brand': 'NYX Professional',
      'price': '\$12',
      'rating': 4.7,
      'tag': 'Fan Fave',
      'color': const Color(0xFF1C1224),
      'icon': Icons.edit,
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Satin Lip Liner',
      'brand': 'MAC',
      'price': '\$18',
      'rating': 4.5,
      'category': 'Lips',
      'shade': const Color(0xFFC2516B),
    },
    {
      'name': 'Lash Serum Mascara',
      'brand': 'ILIA Beauty',
      'price': '\$32',
      'rating': 4.9,
      'category': 'Eyes',
      'shade': const Color(0xFF1C1224),
    },
    {
      'name': 'HD Powder Foundation',
      'brand': 'Make Up For Ever',
      'price': '\$44',
      'rating': 4.7,
      'category': 'Face',
      'shade': const Color(0xFFE8C8A0),
    },
    {
      'name': 'Gel Nail Polish',
      'brand': 'OPI',
      'price': '\$14',
      'rating': 4.6,
      'category': 'Nails',
      'shade': const Color(0xFFE8708A),
    },
    {
      'name': 'Perfume Mist',
      'brand': 'Sol de Janeiro',
      'price': '\$38',
      'rating': 4.8,
      'category': 'Fragrance',
      'shade': const Color(0xFFF5C97A),
    },
    {
      'name': 'Cream Eyeshadow',
      'brand': 'Rare Beauty',
      'price': '\$22',
      'rating': 4.7,
      'category': 'Eyes',
      'shade': const Color(0xFFB8A0C8),
    },
    {
      'name': 'Bronzer Stick',
      'brand': 'Nudestix',
      'price': '\$34',
      'rating': 4.5,
      'category': 'Face',
      'shade': const Color(0xFFC8986C),
    },
    {
      'name': 'Plumping Lip Gloss',
      'brand': 'Too Faced',
      'price': '\$26',
      'rating': 4.6,
      'category': 'Lips',
      'shade': const Color(0xFFF8AFCB),
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedFilter == 0) return _products;
    final label = _filters[_selectedFilter];
    return _products.where((p) => p['category'] == label).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildFilterChips()),
          SliverToBoxAdapter(child: _buildFeaturedSection()),
          SliverToBoxAdapter(child: _buildSectionHeader('All Products')),
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
      expandedHeight: 200,
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
          child: IconButton(
            icon: const Icon(Icons.search_rounded, size: 20, color: _textPrimary),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE8F0), Color(0xFFFDF7FA)],
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
                      color: _rose.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💄 COSMETICS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _roseDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Explore Top-Rated\nCosmetics',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final active = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
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
                _filters[i],
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
    );
  }

  // ── Featured Section ────────────────────────────────────────────────────────
  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('✨ Featured'),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featured.length,
            itemBuilder: (context, i) {
              final item = _featured[i];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
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
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item['icon'] as IconData,
                              color: item['color'] as Color, size: 22),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _orchid.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['tag'] as String,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: _orchidDark),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['brand'] as String,
                      style:
                          const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['price'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _roseDark,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Color(0xFFFFC107)),
                            const SizedBox(width: 2),
                            Text(
                              '${item['rating']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
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
    final items = _filteredProducts;
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _ProductCard(
          name: items[i]['name'] as String,
          brand: items[i]['brand'] as String,
          price: items[i]['price'] as String,
          rating: items[i]['rating'] as double,
          shadeColor: items[i]['shade'] as Color,
          category: items[i]['category'] as String,
        ),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
    );
  }
}

// ── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.shadeColor,
    required this.category,
  });

  final String name;
  final String brand;
  final String price;
  final double rating;
  final Color shadeColor;
  final String category;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _wishlisted = false;

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
          // ── Shade preview ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.shadeColor.withOpacity(0.3),
                        widget.shadeColor.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: widget.shadeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.shadeColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _wishlisted = !_wishlisted),
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
                        _wishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: _wishlisted
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1224),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.brand,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E8DA8)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFC2516B),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 12, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.rating}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E8DA8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}