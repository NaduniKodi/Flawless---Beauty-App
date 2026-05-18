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

class CosmeticsPage extends StatefulWidget {
  const CosmeticsPage({super.key});
  @override
  State<CosmeticsPage> createState() => _CosmeticsPageState();
}

class _CosmeticsPageState extends State<CosmeticsPage> {
  static const Color _rose        = Color(0xFFE8708A);
  static const Color _roseDark    = Color(0xFFC2516B);
  static const Color _orchid      = Color(0xFFF8AFCB);
  static const Color _surface     = Color(0xFFFDF7FA);
  static const Color _card        = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF1C1224);
  static const Color _textMuted   = Color(0xFF9E8DA8);

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Lips', 'Eyes', 'Face', 'Nails'];

  final List<Map<String, dynamic>> _lkProducts = [
    {
      'name': 'Matte Lip Colour', 'brand': 'Viana', 'price': 'Rs. 580', 'rating': 4.7,
      'category': 'Lips', 'shade': Color(0xFFCC3D5A), 'tag': 'Best Seller',
      'image': 'assets/images/cosmetics/lk/viana_matte_lip.jpg',
      'buyUrl': 'https://viana.lk/product/viana-matte-touch-lipstick/',
    },
    {
      'name': 'Glossy Lip Tint', 'brand': 'Viana', 'price': 'Rs. 490', 'rating': 4.5,
      'category': 'Lips', 'shade': Color(0xFFE8708A), 'tag': 'Trending',
      'image': 'assets/images/cosmetics/lk/viana_glossy_tint.jpg',
      'buyUrl': 'https://viana.lk/product/viana-liquid-gloss/',
    },
    {
      'name': 'Long-Wear Eyeliner', 'brand': 'Viana', 'price': 'Rs. 420', 'rating': 4.6,
      'category': 'Eyes', 'shade': Color(0xFF1C1224), 'tag': 'Fan Fave',
      'image': 'assets/images/cosmetics/lk/viana_eyeliner.jpg',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=viana+long+wear+eyeliner',
    },
    {
      'name': 'BB Cream SPF 30', 'brand': 'Viana', 'price': 'Rs. 890', 'rating': 4.7,
      'category': 'Face', 'shade': Color(0xFFE8C8A0), 'tag': 'New',
      'image': 'assets/images/cosmetics/lk/viana_bb_cream.jpg',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=viana+bb+cream+spf',
    },
    {
      'name': 'Toxin-Free Nail Paint', 'brand': 'Viana', 'price': 'Rs. 650', 'rating': 4.8,
      'category': 'Nails', 'shade': Color(0xFFF8AFCB), 'tag': 'Clean Beauty',
      'image': 'assets/images/cosmetics/lk/viana_nail_paint.jpg',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=viana+nail+paint+toxin+free',
    },
    {
      'name': 'Papaya Glow Foundation', 'brand': 'Janet', 'price': 'Rs. 680', 'rating': 4.4,
      'category': 'Face', 'shade': Color(0xFFDEC8A8), 'tag': 'Herbal',
      'image': 'assets/images/cosmetics/lk/janet_foundation.webp',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=janet+foundation',
    },
    {
      'name': 'Herbal Kajal', 'brand': 'Viana', 'price': 'Rs. 820', 'rating': 4.5,
      'category': 'Eyes', 'shade': Color(0xFF2C2040), 'tag': 'Natural',
      'image': 'assets/images/cosmetics/lk/viana_kajal.jpg',
      'buyUrl': 'https://www.daraz.lk/catalog/?q=viana+kajal',
    },
    {
      'name': 'Ayurvedic Lip Balm', 'brand': 'Spa Ceylon', 'price': 'Rs. 1,600', 'rating': 4.9,
      'category': 'Lips', 'shade': Color(0xFFD4A1C0), 'tag': 'Luxury',
      'image': 'assets/images/cosmetics/lk/spaceylon_lip_balm.png',
      'buyUrl': 'https://lk.spaceylon.com/collections/lip-balms?srsltid=AfmBOorAFSwrnCnOAe8YEqqMoPLZHboobwrwk6wnf8AoD0lrtUnme9aH',
    },
    {
      'name': 'Compact Powder', 'brand': 'Janet', 'price': 'Rs. 1,200', 'rating': 4.3,
      'category': 'Face', 'shade': Color(0xFFE8D0B0), 'tag': 'Value',
      'image': 'assets/images/cosmetics/lk/janet_compact.webp',
      'buyUrl': 'https://janet.lk/collections/face-powders?srsltid=AfmBOooasEmB2SJlDNiPB-tPPifopDtlI2ueHLtaQxL1NVdoQcVjItm7',
    },
    {
      'name': 'Eye Shadow Palette', 'brand': 'Viana', 'price': 'Rs. 1,430', 'rating': 4.2,
      'category': 'Eyes', 'shade': Color(0xFFC2516B), 'tag': 'Affordable',
      'image': 'assets/images/cosmetics/lk/viana_eyeshadow.jpg',
      'buyUrl': 'https://viana.lk/product/makeup-eyes-viana-3-color-eye-shadow/',
    },
  ];

  final List<Map<String, dynamic>> _intlProducts = [
    {
      'name': 'Velvet Matte Lip', 'brand': 'Fenty Beauty', 'price': '\$22', 'rating': 4.8,
      'category': 'Lips', 'shade': Color(0xFFE96A85), 'tag': 'Best Seller',
      'image': 'assets/images/cosmetics/intl/fenty_matte_lip.webp',
      'buyUrl': 'https://www.amazon.com/s?k=Fenty+Beauty+Stunna+Lip+Paint+Matte',
    },
    {
      'name': 'Glossy Lip Oil', 'brand': 'Charlotte Tilbury', 'price': '\$28', 'rating': 4.6,
      'category': 'Lips', 'shade': Color(0xFFD4A1C0), 'tag': 'New',
      'image': 'assets/images/cosmetics/intl/charlotte_lip_oil.webp',
      'buyUrl': 'https://www.amazon.com/s?k=Charlotte+Tilbury+Collagen+Lip+Bath',
    },
    {
      'name': 'Precision Liquid Liner', 'brand': 'NYX Professional', 'price': '\$12', 'rating': 4.7,
      'category': 'Eyes', 'shade': Color(0xFF1C1224), 'tag': 'Fan Fave',
      'image': 'assets/images/cosmetics/intl/nyx_liner.jpg',
      'buyUrl': 'https://www.amazon.com/s?k=NYX+Professional+Makeup+Epic+Ink+Liner',
    },
    {
      'name': 'Lash Serum Mascara', 'brand': 'ILIA Beauty', 'price': '\$32', 'rating': 4.9,
      'category': 'Eyes', 'shade': Color(0xFF1C1224), 'tag': 'Premium',
      'image': 'assets/images/cosmetics/intl/ilia_mascara.webp',
      'buyUrl': 'https://www.amazon.com/s?k=ILIA+Limitless+Lash+Mascara',
    },
    {
      'name': 'HD Powder Foundation', 'brand': 'Make Up For Ever', 'price': '\$44', 'rating': 4.7,
      'category': 'Face', 'shade': Color(0xFFE8C8A0), 'tag': 'Pro',
      'image': 'assets/images/cosmetics/intl/mufe_foundation.png',
      'buyUrl': 'https://www.amazon.com/s?k=Make+Up+For+Ever+HD+Skin+Powder+Foundation',
    },
    {
      'name': 'Gel Nail Polish', 'brand': 'OPI', 'price': '\$14', 'rating': 4.6,
      'category': 'Nails', 'shade': Color(0xFFE8708A), 'tag': 'Classic',
      'image': 'assets/images/cosmetics/intl/opi_nail_polish.webp',
      'buyUrl': 'https://www.amazon.com/s?k=OPI+Nail+Lacquer',
    },
    {
      'name': 'Cream Eyeshadow', 'brand': 'Rare Beauty', 'price': '\$22', 'rating': 4.7,
      'category': 'Eyes', 'shade': Color(0xFFB8A0C8), 'tag': 'Trending',
      'image': 'assets/images/cosmetics/intl/rare_beauty_eyeshadow.webp',
      'buyUrl': 'https://www.amazon.com/s?k=Rare+Beauty+Liquid+Touch+Eyeshadow',
    },
    {
      'name': 'Bronzer Stick', 'brand': 'Nudestix', 'price': '\$34', 'rating': 4.5,
      'category': 'Face', 'shade': Color(0xFFC8986C), 'tag': 'Popular',
      'image': 'assets/images/cosmetics/intl/nudestix_bronzer.webp',
      'buyUrl': 'https://www.amazon.com/s?k=Nudestix+Nudies+Matte+Bronzer',
    },
  ];

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> list) {
    if (_selectedFilter == 0) return list;
    final label = _filters[_selectedFilter];
    return list.where((p) => p['category'] == label).toList();
  }

  void _showSeeAll({
    required List<Map<String, dynamic>> products,
    required bool isLocal,
    required String title,
  }) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92, maxChildSize: 0.96, minChildSize: 0.5, expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: _textPrimary, letterSpacing: -0.3)),
                Text('${products.length} products', style: const TextStyle(fontSize: 13, color: _textMuted)),
              ])),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
                  child: const Icon(Icons.close_rounded, size: 18, color: _textPrimary))),
            ])),
            Divider(height: 1, color: Colors.grey.withOpacity(0.12)),
            Expanded(child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: products.length,
              itemBuilder: (context, i) => _CosmeticCard(
                name: products[i]['name'] as String, brand: products[i]['brand'] as String,
                price: products[i]['price'] as String, rating: products[i]['rating'] as double,
                shadeColor: products[i]['shade'] as Color, tag: products[i]['tag'] as String,
                imagePath: products[i]['image'] as String, isLocal: isLocal,
                buyUrl: products[i]['buyUrl'] as String,
              ),
            )),
          ]),
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
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverToBoxAdapter(child: _BrandSectionHeader(
          emoji: '🇱🇰', title: 'Sri Lankan Brands',
          subtitle: 'Proudly local · support homegrown beauty',
          bgColor: const Color(0xFFFFF8E1), accentColor: const Color(0xFFD4A820),
          onSeeAll: () => _showSeeAll(products: _lkProducts, isLocal: true, title: '🇱🇰 Sri Lankan Brands'),
        )),
        if (lkFiltered.isEmpty) const SliverToBoxAdapter(child: _EmptyFilter())
        else SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: _buildGrid(lkFiltered, isLocal: true)),
        SliverToBoxAdapter(child: _BrandSectionHeader(
          emoji: '🌍', title: 'International Brands',
          subtitle: 'Global bestsellers · premium picks',
          bgColor: const Color(0xFFEEF4FF), accentColor: const Color(0xFF5A7AB8),
          onSeeAll: () => _showSeeAll(products: _intlProducts, isLocal: false, title: '🌍 International Brands'),
        )),
        if (intlFiltered.isEmpty) const SliverToBoxAdapter(child: _EmptyFilter())
        else SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _buildGrid(intlFiltered, isLocal: false)),
      ]),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 185, pinned: true, backgroundColor: _surface,
      leading: GestureDetector(onTap: () => Navigator.pop(context),
        child: Container(margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textPrimary))),
      actions: [Container(margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
        child: IconButton(icon: const Icon(Icons.search_rounded, size: 20, color: _textPrimary), onPressed: () {}))],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(
              colors: [Color(0xFFFFE8F0), Color(0xFFFDF7FA)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _rose.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Text('💄 COSMETICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _roseDark, letterSpacing: 1.2))),
              const SizedBox(height: 4),
              const Text('Explore Top-Rated\nCosmetics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _textPrimary, height: 1.2, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              Text('Local pride · global glamour', style: TextStyle(fontSize: 13, color: _textMuted)),
            ]))),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(height: 52, child: ListView.builder(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filters.length,
      itemBuilder: (context, i) {
        final active = _selectedFilter == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedFilter = i),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(colors: [_rose, _orchid]) : null,
              color: active ? null : _card, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: active ? _rose.withOpacity(0.25) : Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Text(_filters[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : _textMuted))),
        );
      },
    ));
  }

  Widget _buildGrid(List<Map<String, dynamic>> items, {required bool isLocal}) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) => _CosmeticCard(
          name: items[i]['name'] as String, brand: items[i]['brand'] as String,
          price: items[i]['price'] as String, rating: items[i]['rating'] as double,
          shadeColor: items[i]['shade'] as Color, tag: items[i]['tag'] as String,
          imagePath: items[i]['image'] as String, isLocal: isLocal,
          buyUrl: items[i]['buyUrl'] as String,
        ),
        childCount: items.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 0.63), // slightly taller to fit Buy button
    );
  }
}

class _BrandSectionHeader extends StatelessWidget {
  const _BrandSectionHeader({
    required this.emoji, required this.title, required this.subtitle,
    required this.bgColor, required this.accentColor, this.onSeeAll,
  });
  final String emoji, title, subtitle;
  final Color bgColor, accentColor;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.2)),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: accentColor)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: accentColor.withOpacity(0.75))),
        ])),
        GestureDetector(onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accentColor)),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
            ]),
          )),
      ]),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: Center(child: Text('No products in this category', style: TextStyle(fontSize: 13, color: Color(0xFF9E8DA8)))));
}

// ── Cosmetic Card ─────────────────────────────────────────────────────────────
class _CosmeticCard extends StatefulWidget {
  const _CosmeticCard({
    required this.name, required this.brand, required this.price,
    required this.rating, required this.shadeColor, required this.tag,
    required this.imagePath, required this.isLocal, required this.buyUrl,
  });
  final String name, brand, price, tag, imagePath, buyUrl;
  final double rating;
  final Color shadeColor;
  final bool isLocal;

  @override
  State<_CosmeticCard> createState() => _CosmeticCardState();
}

class _CosmeticCardState extends State<_CosmeticCard> {
  bool _wishlisted = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Image (Expanded) ─────────────────────────────────────────────
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(fit: StackFit.expand, children: [
              Container(decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [widget.shadeColor.withOpacity(0.25), widget.shadeColor.withOpacity(0.07)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight))),
              Image.asset(widget.imagePath, fit: BoxFit.fill, alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Center(child: Container(width: 56, height: 56,
                    decoration: BoxDecoration(color: widget.shadeColor, shape: BoxShape.circle,
                        boxShadow:[BoxShadow(color: widget.shadeColor.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 5))])))),
              if (widget.isLocal)
                Positioned(top: 8, left: 8, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFD4A820), borderRadius: BorderRadius.circular(7)),
                  child: const Text('🇱🇰 Local', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
              Positioned(top: 8, right: 8, child: GestureDetector(
                onTap: () => setState(() => _wishlisted = !_wishlisted),
                child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                  child: Icon(_wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 14, color: _wishlisted ? const Color(0xFFE8708A) : const Color(0xFF9E8DA8))))),
            ]),
          )),

          // ── Info (fixed height) ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              // Tag
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: widget.shadeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(widget.tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: widget.shadeColor == const Color(0xFF1C1224) || widget.shadeColor == const Color(0xFF2C2040)
                        ? const Color(0xFF9E8DA8) : widget.shadeColor))),
              const SizedBox(height: 4),
              // Name
              Text(widget.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1C1224)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              // Brand + rating in one row
              Row(children: [
                Expanded(child: Text(widget.brand, style: const TextStyle(fontSize: 10.5, color: Color(0xFF9E8DA8)),
                    overflow: TextOverflow.ellipsis)),
                const Icon(Icons.star_rounded, size: 11, color: Color(0xFFFFC107)),
                const SizedBox(width: 2),
                Text('${widget.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9E8DA8))),
              ]),
              const SizedBox(height: 6),
              // Price + Buy button row
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(widget.price,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFC2516B)),
                    overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _openUrl(context, widget.buyUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE8708A), Color(0xFFF8AFCB)]),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [BoxShadow(color: const Color(0xFFE8708A).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.shopping_bag_outlined, size: 11, color: Colors.white),
                      SizedBox(width: 3),
                      Text('Buy', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white)),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}