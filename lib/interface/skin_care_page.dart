import 'package:flutter/material.dart';

class SkinCarePage extends StatefulWidget {
  const SkinCarePage({super.key});

  @override
  State<SkinCarePage> createState() => _SkinCarePageState();
}

class _SkinCarePageState extends State<SkinCarePage> {
  // ── Colour tokens ─────────────────────────────────────────────────────────
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _orchidDark  = Color.fromARGB(255, 255, 152, 191);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedSkinType = 0;

  final List<String> _skinTypes = [
    'All', 'Oily', 'Dry', 'Combination', 'Sensitive', 'Normal',
  ];

  final List<Map<String, dynamic>> _routineSteps = [
    {
      'step': '01',
      'name': 'Cleanse',
      'desc': 'Remove impurities & excess oil',
      'time': 'AM & PM',
      'icon': Icons.water_drop_outlined,
      'color': const Color(0xFF7EB8D4),
    },
    {
      'step': '02',
      'name': 'Tone',
      'desc': 'Balance & prep the skin',
      'time': 'AM & PM',
      'icon': Icons.spa_outlined,
      'color': const Color(0xFFB4D4A8),
    },
    {
      'step': '03',
      'name': 'Serum',
      'desc': 'Targeted treatment',
      'time': 'AM & PM',
      'icon': Icons.science_outlined,
      'color': const Color(0xFFF8AFCB),
    },
    {
      'step': '04',
      'name': 'Moisturise',
      'desc': 'Lock in hydration',
      'time': 'AM & PM',
      'icon': Icons.opacity_outlined,
      'color': const Color(0xFFE8C4A0),
    },
    {
      'step': '05',
      'name': 'SPF',
      'desc': 'Protect from UV damage',
      'time': 'AM only',
      'icon': Icons.wb_sunny_outlined,
      'color': const Color(0xFFF5E07A),
    },
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Gentle Foaming Cleanser',
      'brand': 'CeraVe',
      'price': '\$16',
      'rating': 4.9,
      'skinType': ['All', 'Oily', 'Combination'],
      'tag': 'Step 1',
      'tagColor': Color(0xFF7EB8D4),
    },
    {
      'name': 'Hydrating Toner',
      'brand': 'Klairs',
      'price': '\$24',
      'rating': 4.7,
      'skinType': ['All', 'Dry', 'Sensitive', 'Normal'],
      'tag': 'Step 2',
      'tagColor': Color(0xFFB4D4A8),
    },
    {
      'name': 'Niacinamide 10% + Zinc',
      'brand': 'The Ordinary',
      'price': '\$8',
      'rating': 4.8,
      'skinType': ['Oily', 'Combination'],
      'tag': 'Step 3',
      'tagColor': Color(0xFFF8AFCB),
    },
    {
      'name': 'Hyaluronic Acid Serum',
      'brand': 'Neutrogena',
      'price': '\$19',
      'rating': 4.6,
      'skinType': ['Dry', 'Normal', 'Sensitive'],
      'tag': 'Step 3',
      'tagColor': Color(0xFFF8AFCB),
    },
    {
      'name': 'Barrier Repair Cream',
      'brand': 'La Roche-Posay',
      'price': '\$30',
      'rating': 4.9,
      'skinType': ['Sensitive', 'Dry'],
      'tag': 'Step 4',
      'tagColor': Color(0xFFE8C4A0),
    },
    {
      'name': 'Oil-Free Moisturiser',
      'brand': 'Belif',
      'price': '\$42',
      'rating': 4.7,
      'skinType': ['Oily', 'Combination', 'Normal'],
      'tag': 'Step 4',
      'tagColor': Color(0xFFE8C4A0),
    },
    {
      'name': 'Mineral SPF 50',
      'brand': 'EltaMD',
      'price': '\$36',
      'rating': 4.8,
      'skinType': ['All', 'Sensitive'],
      'tag': 'Step 5',
      'tagColor': Color(0xFFF5E07A),
    },
    {
      'name': 'Retinol Night Serum',
      'brand': 'Paula\'s Choice',
      'price': '\$52',
      'rating': 4.7,
      'skinType': ['Oily', 'Combination', 'Normal'],
      'tag': 'PM Boost',
      'tagColor': Color(0xFFB8A0C8),
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedSkinType == 0) return _products;
    final label = _skinTypes[_selectedSkinType];
    return _products
        .where((p) => (p['skinType'] as List<String>).contains(label))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSkinTypeSelector()),
          SliverToBoxAdapter(child: _buildRoutineSection()),
          SliverToBoxAdapter(child: _buildSectionHeader('Recommended Products')),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _buildProductsSliver(),
          ),
        ],
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
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
            icon: const Icon(Icons.face_retouching_natural_rounded,
                size: 20, color: _textPrimary),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F4F8), Color(0xFFFDF7FA)],
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
                      color: const Color(0xFF7EB8D4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🌿 SKIN CARE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5A9AB8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Routines Tailored\nTo You',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Science-backed products for every skin type',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
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

  // ── Skin Type Selector ──────────────────────────────────────────────────────
  Widget _buildSkinTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your Skin Type'),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: _skinTypes.length,
            itemBuilder: (context, i) {
              final active = _selectedSkinType == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedSkinType = i),
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
                    _skinTypes[i],
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
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Routine Section ─────────────────────────────────────────────────────────
  Widget _buildRoutineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daily Routine'),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _routineSteps.length,
            itemBuilder: (context, i) {
              final step = _routineSteps[i];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: (step['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 18,
                            color: step['color'] as Color,
                          ),
                        ),
                        Text(
                          step['step'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: (step['color'] as Color).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      step['name'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step['time'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: _textMuted),
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

  // ── Products Sliver ─────────────────────────────────────────────────────────
  Widget _buildProductsSliver() {
    final items = _filteredProducts;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _SkinProductTile(
          name: items[i]['name'] as String,
          brand: items[i]['brand'] as String,
          price: items[i]['price'] as String,
          rating: items[i]['rating'] as double,
          tag: items[i]['tag'] as String,
          tagColor: items[i]['tagColor'] as Color,
        ),
        childCount: items.length,
      ),
    );
  }
}

// ── Skin Product Tile ─────────────────────────────────────────────────────────
class _SkinProductTile extends StatefulWidget {
  const _SkinProductTile({
    required this.name,
    required this.brand,
    required this.price,
    required this.rating,
    required this.tag,
    required this.tagColor,
  });

  final String name;
  final String brand;
  final String price;
  final double rating;
  final String tag;
  final Color tagColor;

  @override
  State<_SkinProductTile> createState() => _SkinProductTileState();
}

class _SkinProductTileState extends State<_SkinProductTile> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colour dot
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: widget.tagColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.tagColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.tagColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.tag,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: widget.tagColor == const Color(0xFFF5E07A)
                              ? const Color(0xFF9E8A2A)
                              : widget.tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1224),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.brand,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF9E8DA8)),
                ),
                const SizedBox(height: 6),
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFC2516B),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _added = !_added),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _added
                        ? const Color(0xFFE8708A)
                        : const Color(0xFFF8AFCB).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _added ? Icons.check_rounded : Icons.add_rounded,
                    size: 16,
                    color: _added ? Colors.white : const Color(0xFFE8708A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}