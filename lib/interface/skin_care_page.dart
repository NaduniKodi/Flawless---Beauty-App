import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ASSET FOLDER STRUCTURE — add your images here:
//
//   assets/images/skincare/
//   ├── lk/
//   │   ├── spaceylon_coconut_cleanser.jpg 1
//   │   ├── siddhalepa_neem_wash.jpg 2
//   │   ├── janet_papaya_wash.jpg 3
//   │   ├── janet_aloe_toner.jpg 4
//   │   ├── swabha_brightening_serum.jpg 5
//   │   ├── dlas_vitc_serum.jpg 6
//   │   ├── spaceylon_sandalwood_moist.jpg 7
//   │   ├── british_oil_control.jpg 8
//   │   ├── prevense_spf50.jpg 9
//   │   └── velvet_body_lotion.jpg 10
//   └── intl/
//       ├── cerave_cleanser.jpg 11
//       ├── klairs_toner.jpg 12
//       ├── ordinary_niacinamide.jpg 13
//       ├── neutrogena_ha.jpg 14
//       ├── laroche_barrier.jpg 15
//       ├── belif_moisturiser.jpg 16
//       ├── eltamd_spf.jpg 17
//       └── paulas_retinol.jpg 18
//
// pubspec.yaml:
//   - assets/images/skincare/lk/
//   - assets/images/skincare/intl/
// ─────────────────────────────────────────────────────────────────────────────

class SkinCarePage extends StatefulWidget {
  const SkinCarePage({super.key});

  @override
  State<SkinCarePage> createState() => _SkinCarePageState();
}

class _SkinCarePageState extends State<SkinCarePage> {
  static const Color _rose        = Color(0xFFE8708A);
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
    {'step': '01', 'name': 'Cleanse',    'time': 'AM & PM', 'icon': Icons.water_drop_outlined, 'color': Color(0xFF7EB8D4)},
    {'step': '02', 'name': 'Tone',       'time': 'AM & PM', 'icon': Icons.spa_outlined,         'color': Color(0xFFB4D4A8)},
    {'step': '03', 'name': 'Serum',      'time': 'AM & PM', 'icon': Icons.science_outlined,     'color': Color(0xFFF8AFCB)},
    {'step': '04', 'name': 'Moisturise', 'time': 'AM & PM', 'icon': Icons.opacity_outlined,     'color': Color(0xFFE8C4A0)},
    {'step': '05', 'name': 'SPF',        'time': 'AM only',  'icon': Icons.wb_sunny_outlined,   'color': Color(0xFFF5E07A)},
  ];

  // ── Sri Lankan skincare products ──────────────────────────────────────────
  final List<Map<String, dynamic>> _lkProducts = [
    {
      'name': 'Coconut Milk Cleanser',
      'brand': 'Spa Ceylon',
      'price': 'Rs. 1,950', 'rating': 4.9,
      'skinType': ['All', 'Dry', 'Sensitive', 'Normal'],
      'tag': 'Step 1', 'tagColor': Color(0xFF7EB8D4),
      'desc': 'Gentle Ayurvedic cleanser with raw coconut milk',
      'image': 'assets/images/skincare/lk/1.png',
    },
    {
      'name': 'Neem & Turmeric Face Wash',
      'brand': 'Siddhalepa',
      'price': 'Rs. 480', 'rating': 4.6,
      'skinType': ['All', 'Oily', 'Combination'],
      'tag': 'Step 1', 'tagColor': Color(0xFF7EB8D4),
      'desc': 'Traditional Ayurvedic formula for clear skin',
      'image': 'assets/images/skincare/lk/2.png',
    },
    {
      'name': 'Papaya Face Wash',
      'brand': 'Janet',
      'price': 'Rs. 320', 'rating': 4.5,
      'skinType': ['All', 'Normal', 'Combination'],
      'tag': 'Step 1', 'tagColor': Color(0xFF7EB8D4),
      'desc': 'Brightening papaya extract for a natural glow',
      'image': 'assets/images/skincare/lk/3.webp',
    },
    {
      'name': 'Aloe Vera Toner',
      'brand': 'Janet',
      'price': 'Rs. 280', 'rating': 4.4,
      'skinType': ['All', 'Sensitive', 'Dry'],
      'tag': 'Step 2', 'tagColor': Color(0xFFB4D4A8),
      'desc': 'Soothing aloe vera for balanced, calm skin',
      'image': 'assets/images/skincare/lk/4.webp',
    },
    {
      'name': 'Herbal Brightening Serum',
      'brand': 'Swabha Ceylon',
      'price': 'Rs. 2,200', 'rating': 4.7,
      'skinType': ['All', 'Normal', 'Dry'],
      'tag': 'Step 3', 'tagColor': Color(0xFFF8AFCB),
      'desc': 'Modern Ayurveda meets science for radiant skin',
      'image': 'assets/images/skincare/lk/5.jpg',
    },
    {
      'name': 'Nature\'s secret Vitamin C Serum',
      'brand': 'Nature\'s Secret',
      'price': 'Rs. 1,800', 'rating': 4.6,
      'skinType': ['All', 'Oily', 'Combination'],
      'tag': 'Step 3', 'tagColor': Color(0xFFF8AFCB),
      'desc': '100% natural organic ingredients from Sri Lankan fields',
      'image': 'assets/images/skincare/lk/6.png',
    },
    {
      'name': 'Sandalwood Moisturiser',
      'brand': 'Spa Ceylon',
      'price': 'Rs. 2,400', 'rating': 4.8,
      'skinType': ['All', 'Dry', 'Normal', 'Sensitive'],
      'tag': 'Step 4', 'tagColor': Color(0xFFE8C4A0),
      'desc': 'Rich sandalwood & coconut oil hydration ritual',
      'image': 'assets/images/skincare/lk/7.png',
    },
    {
      'name': 'Oil-Control Moisturiser',
      'brand': 'British Cosmetics',
      'price': 'Rs. 1,100', 'rating': 4.5,
      'skinType': ['Oily', 'Combination'],
      'tag': 'Step 4', 'tagColor': Color(0xFFE8C4A0),
      'desc': 'Designed for Sri Lankan humidity & oily skin',
      'image': 'assets/images/skincare/lk/8.jpg',
    },
    {
      'name': 'Daily SPF 50 Sunscreen',
      'brand': 'Prevense',
      'price': 'Rs. 1,450', 'rating': 4.6,
      'skinType': ['All', 'Sensitive'],
      'tag': 'Step 5', 'tagColor': Color(0xFFF5E07A),
      'desc': 'Lightweight SPF suited to tropical climate',
      'image': 'assets/images/skincare/lk/9.jpg',
    },
    {
      'name': 'Velvet Body Lotion',
      'brand': 'Velvet',
      'price': 'Rs. 560', 'rating': 4.4,
      'skinType': ['All', 'Dry', 'Normal'],
      'tag': 'Body', 'tagColor': Color(0xFFD4C0E8),
      'desc': 'Designed specifically for Sri Lankan skin & climate',
      'image': 'assets/images/skincare/lk/10.jpg',
    },
  ];

  // ── International skincare products ──────────────────────────────────────
  final List<Map<String, dynamic>> _intlProducts = [
    {
      'name': 'Gentle Foaming Cleanser',
      'brand': 'CeraVe',
      'price': '\$16', 'rating': 4.9,
      'skinType': ['All', 'Oily', 'Combination'],
      'tag': 'Step 1', 'tagColor': Color(0xFF7EB8D4),
      'desc': 'Dermatologist recommended with ceramides',
      'image': 'assets/images/skincare/intl/11.avif',
    },
    {
      'name': 'Hydrating Toner',
      'brand': 'Klairs',
      'price': '\$24', 'rating': 4.7,
      'skinType': ['All', 'Dry', 'Sensitive', 'Normal'],
      'tag': 'Step 2', 'tagColor': Color(0xFFB4D4A8),
      'desc': 'K-beauty essential for glass skin',
      'image': 'assets/images/skincare/intl/12.jpg',
    },
    {
      'name': 'Niacinamide 10% + Zinc',
      'brand': 'The Ordinary',
      'price': '\$8', 'rating': 4.8,
      'skinType': ['Oily', 'Combination'],
      'tag': 'Step 3', 'tagColor': Color(0xFFF8AFCB),
      'desc': 'Pore-minimising & sebum-control serum',
      'image': 'assets/images/skincare/intl/13.jpg',
    },
    {
      'name': 'Hyaluronic Acid Serum',
      'brand': 'Neutrogena',
      'price': '\$19', 'rating': 4.6,
      'skinType': ['Dry', 'Normal', 'Sensitive'],
      'tag': 'Step 3', 'tagColor': Color(0xFFF8AFCB),
      'desc': 'Deep hydration with multi-weight HA',
      'image': 'assets/images/skincare/intl/14.webp',
    },
    {
      'name': 'Barrier Repair Cream',
      'brand': 'La Roche-Posay',
      'price': '\$30', 'rating': 4.9,
      'skinType': ['Sensitive', 'Dry'],
      'tag': 'Step 4', 'tagColor': Color(0xFFE8C4A0),
      'desc': 'Clinically tested for reactive skin',
      'image': 'assets/images/skincare/intl/15.webp',
    },
    {
      'name': 'Oil-Free Moisturiser',
      'brand': 'Belif',
      'price': '\$42', 'rating': 4.7,
      'skinType': ['Oily', 'Combination', 'Normal'],
      'tag': 'Step 4', 'tagColor': Color(0xFFE8C4A0),
      'desc': 'Lightweight formula from comfrey herb',
      'image': 'assets/images/skincare/intl/16.jpg',
    },
    {
      'name': 'Mineral SPF 50',
      'brand': 'EltaMD',
      'price': '\$36', 'rating': 4.8,
      'skinType': ['All', 'Sensitive'],
      'tag': 'Step 5', 'tagColor': Color(0xFFF5E07A),
      'desc': 'Zinc oxide broad-spectrum protection',
      'image': 'assets/images/skincare/intl/17.avif',
    },
    {
      'name': 'Retinol Night Serum',
      'brand': 'Paula\'s Choice',
      'price': '\$52', 'rating': 4.7,
      'skinType': ['Oily', 'Combination', 'Normal'],
      'tag': 'PM Boost', 'tagColor': Color(0xFFB8A0C8),
      'desc': 'Encapsulated retinol for smoother skin',
      'image': 'assets/images/skincare/intl/18.avif',
    },
  ];

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> list) {
    if (_selectedSkinType == 0) return list;
    final label = _skinTypes[_selectedSkinType];
    return list.where((p) => (p['skinType'] as List<String>).contains(label)).toList();
  }

  // ── See All sheet ─────────────────────────────────────────────────────────
  void _showSeeAll({
    required List<Map<String, dynamic>> products,
    required bool isLocal,
    required String title,
    required Color accentColor,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
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
                          Text('${products.length} products',
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
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: products.length,
                  itemBuilder: (context, i) => _SkinProductTile(
                    name: products[i]['name'] as String,
                    brand: products[i]['brand'] as String,
                    price: products[i]['price'] as String,
                    rating: products[i]['rating'] as double,
                    tag: products[i]['tag'] as String,
                    tagColor: products[i]['tagColor'] as Color,
                    desc: products[i]['desc'] as String,
                    imagePath: products[i]['image'] as String,
                    isLocal: isLocal,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          SliverToBoxAdapter(child: _buildSkinTypeSelector()),
          SliverToBoxAdapter(child: _buildRoutineSection()),
          SliverToBoxAdapter(
            child: _BrandSectionHeader(
              emoji: '🇱🇰', title: 'Sri Lankan Brands',
              subtitle: 'Proudly local · Ayurvedic & natural heritage',
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
              sliver: _buildProductSliver(lkFiltered, isLocal: true),
            ),
          SliverToBoxAdapter(
            child: _BrandSectionHeader(
              emoji: '🌍', title: 'International Brands',
              subtitle: 'Science-backed · globally trusted',
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
              sliver: _buildProductSliver(intlFiltered, isLocal: false),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 205, pinned: true, backgroundColor: _surface,
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
          child: IconButton(
            icon: const Icon(Icons.face_retouching_natural_rounded, size: 20, color: _textPrimary),
            onPressed: () {},
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFE8F4F8), Color(0xFFFDF7FA)],
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
                      color: const Color(0xFF7EB8D4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🌿 SKIN CARE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: Color(0xFF5A9AB8), letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 6),
                  const Text('Routines Tailored\nTo You',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                          color: _textPrimary, height: 1.2, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text('Local remedies · global science',
                      style: TextStyle(fontSize: 13, color: _textMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('Filter by Skin Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: _textPrimary, letterSpacing: -0.2)),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    gradient: active ? const LinearGradient(colors: [_rose, _orchid]) : null,
                    color: active ? null : _card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: active ? _rose.withOpacity(0.25) : Colors.black.withOpacity(0.05),
                      blurRadius: 8, offset: const Offset(0, 3),
                    )],
                  ),
                  child: Text(_skinTypes[i],
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: active ? Colors.white : _textMuted)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildRoutineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text('Daily Routine Steps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: _textPrimary, letterSpacing: -0.2)),
        ),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _routineSteps.length,
            itemBuilder: (context, i) {
              final step = _routineSteps[i];
              return Container(
                width: 115,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: _card, borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: (step['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(step['icon'] as IconData, size: 17,
                              color: step['color'] as Color),
                        ),
                        Text(step['step'] as String,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                                color: (step['color'] as Color).withOpacity(0.5))),
                      ],
                    ),
                    const Spacer(),
                    Text(step['name'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: _textPrimary)),
                    const SizedBox(height: 2),
                    Text(step['time'] as String,
                        style: const TextStyle(fontSize: 10, color: _textMuted)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProductSliver(List<Map<String, dynamic>> items, {required bool isLocal}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _SkinProductTile(
          name: items[i]['name'] as String,
          brand: items[i]['brand'] as String,
          price: items[i]['price'] as String,
          rating: items[i]['rating'] as double,
          tag: items[i]['tag'] as String,
          tagColor: items[i]['tagColor'] as Color,
          desc: items[i]['desc'] as String,
          imagePath: items[i]['image'] as String,
          isLocal: isLocal,
        ),
        childCount: items.length,
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
    child: Center(child: Text('No products match this skin type',
        style: TextStyle(fontSize: 13, color: Color(0xFF9E8DA8)))),
  );
}

// ── Skin Product Tile ─────────────────────────────────────────────────────────
class _SkinProductTile extends StatefulWidget {
  const _SkinProductTile({
    required this.name,      required this.brand,
    required this.price,     required this.rating,
    required this.tag,       required this.tagColor,
    required this.desc,      required this.imagePath,
    required this.isLocal,
  });

  final String name, brand, price, tag, desc, imagePath;
  final double rating;
  final Color tagColor;
  final bool isLocal;

  @override
  State<_SkinProductTile> createState() => _SkinProductTileState();
}

class _SkinProductTileState extends State<_SkinProductTile> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // ── Product image thumbnail ───────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            child: SizedBox(
              width: 80, height: 90,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.tagColor.withOpacity(0.25),
                          widget.tagColor.withOpacity(0.07)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => Center(
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: widget.tagColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Text content ──────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.tagColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(widget.tag,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                              color: widget.tagColor == const Color(0xFFF5E07A)
                                  ? const Color(0xFF9E8A2A) : widget.tagColor)),
                    ),
                    if (widget.isLocal) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                            color: const Color(0xFFD4A820),
                            borderRadius: BorderRadius.circular(6)),
                        child: const Text('🇱🇰 Local',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 5),
                  Text(widget.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1224))),
                  const SizedBox(height: 2),
                  Text(widget.brand,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E8DA8))),
                  const SizedBox(height: 3),
                  Text(widget.desc,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9E8DA8), height: 1.3),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFC107)),
                    const SizedBox(width: 3),
                    Text('${widget.rating}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: Color(0xFF9E8DA8))),
                  ]),
                ],
              ),
            ),
          ),

          // ── Price + add button ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.price,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: Color(0xFFC2516B))),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _added = !_added),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _added ? const Color(0xFFE8708A)
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
          ),
        ],
      ),
    );
  }
}