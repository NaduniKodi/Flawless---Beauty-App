// lib/services/skin_advisor.dart
//
// Turns the user's skin type, concerns, age, and interests into real
// personalised advice: AM/PM routine steps, a rotating daily tip,
// and a list of key ingredients to look for in products.
//
// Usage (static, no instantiation needed):
//   SkinAdvisor.amRoutine       → List<RoutineStep>
//   SkinAdvisor.pmRoutine       → List<RoutineStep>
//   SkinAdvisor.dailyTip        → String
//   SkinAdvisor.productKeywords → List<String>
//   SkinAdvisor.hasSkinProfile  → bool

import 'user_data.dart';
import 'interest_data.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class RoutineStep {
  final String stepName;
  final String productType;
  final String tip;
  final String emoji;
  const RoutineStep({
    required this.stepName,
    required this.productType,
    required this.tip,
    required this.emoji,
  });
}

// ── Advisor ───────────────────────────────────────────────────────────────────

class SkinAdvisor {
  SkinAdvisor._();

  // ── Shortcuts ───────────────────────────────────────────────────────────────
  static String get _skin => UserData.instance.skinType;
  static List<String> get _concerns => UserData.instance.skinConcerns;
  static int? get _age => UserData.instance.age;
  static Set<String> get _interests => InterestData.instance.selected;

  static bool get hasSkinProfile =>
      _skin.isNotEmpty || _concerns.isNotEmpty;

  // ── AM Routine ───────────────────────────────────────────────────────────────
  static List<RoutineStep> get amRoutine {
    final steps = <RoutineStep>[];

    // 1. Cleanse
    switch (_skin) {
      case 'Oily':
        steps.add(const RoutineStep(
          stepName: 'Cleanse',
          productType: 'Foaming or Gel Cleanser',
          tip: 'Removes overnight oil build-up without stripping the barrier.',
          emoji: '🫧',
        ));
      case 'Dry':
        steps.add(const RoutineStep(
          stepName: 'Cleanse',
          productType: 'Cream or Milk Cleanser',
          tip: 'Dissolves impurities while preserving precious moisture.',
          emoji: '🌊',
        ));
      case 'Sensitive':
        steps.add(const RoutineStep(
          stepName: 'Cleanse',
          productType: 'Micellar Water or Gentle Gel',
          tip: 'Fragrance-free formula won\'t trigger a reactive flare-up.',
          emoji: '🌸',
        ));
      case 'Combination':
        steps.add(const RoutineStep(
          stepName: 'Cleanse',
          productType: 'Balancing Gel Cleanser',
          tip: 'Targets shine in the T-zone without over-drying the cheeks.',
          emoji: '⚖️',
        ));
      default:
        steps.add(const RoutineStep(
          stepName: 'Cleanse',
          productType: 'Gentle Foaming Cleanser',
          tip: 'A clean canvas lets every following step work harder.',
          emoji: '✨',
        ));
    }

    // 2. Toner / Essence
    if (_concerns.contains('Pores') || _skin == 'Oily') {
      steps.add(const RoutineStep(
        stepName: 'Tone',
        productType: 'Pore-Tightening Toner (Niacinamide / Witch Hazel)',
        tip: 'Minimises pores and controls midday shine.',
        emoji: '🔬',
      ));
    } else if (_concerns.contains('Dryness') || _skin == 'Dry') {
      steps.add(const RoutineStep(
        stepName: 'Essence',
        productType: 'Hydrating Toner (Hyaluronic Acid / Centella)',
        tip: 'Primes the skin to absorb your serum up to 3× more effectively.',
        emoji: '💧',
      ));
    } else if (_skin == 'Sensitive') {
      steps.add(const RoutineStep(
        stepName: 'Tone',
        productType: 'Calming Toner (Centella / Aloe)',
        tip: 'Soothes redness and restores pH after cleansing.',
        emoji: '🌿',
      ));
    } else {
      steps.add(const RoutineStep(
        stepName: 'Tone',
        productType: 'Balancing Toner',
        tip: 'Restores skin pH and removes any last traces of cleanser.',
        emoji: '🌿',
      ));
    }

    // 3. Serum — prioritise by top concern
    if (_concerns.contains('Dark Spots') || _concerns.contains('Uneven Tone') || _concerns.contains('Dullness')) {
      steps.add(const RoutineStep(
        stepName: 'Serum',
        productType: 'Vitamin C Brightening Serum (10-20% L-Ascorbic Acid)',
        tip: 'Fades dark spots over 4-8 weeks and provides antioxidant shield.',
        emoji: '☀️',
      ));
    } else if (_concerns.contains('Acne')) {
      steps.add(const RoutineStep(
        stepName: 'Serum',
        productType: 'Niacinamide 10% + Zinc Serum',
        tip: 'Regulates sebum, shrinks pores, and calms active breakouts.',
        emoji: '🔴',
      ));
    } else if (_concerns.contains('Wrinkles') || (_age != null && _age! >= 30)) {
      steps.add(const RoutineStep(
        stepName: 'Serum',
        productType: 'Peptide + Antioxidant Serum',
        tip: 'Boosts collagen production and fights free-radical damage.',
        emoji: '⏳',
      ));
    } else if (_concerns.contains('Redness')) {
      steps.add(const RoutineStep(
        stepName: 'Serum',
        productType: 'Centella Asiatica / Azelaic Acid Serum',
        tip: 'Calms inflammation and visibly reduces redness within 2 weeks.',
        emoji: '🩺',
      ));
    } else {
      steps.add(const RoutineStep(
        stepName: 'Serum',
        productType: 'Hyaluronic Acid Hydrating Serum',
        tip: 'Plumps skin and creates a dewy, healthy base for make-up.',
        emoji: '💧',
      ));
    }

    // 4. Eye Cream (if relevant concerns or age)
    if (_concerns.contains('Dark Circles') || _concerns.contains('Wrinkles') || (_age != null && _age! >= 25)) {
      steps.add(const RoutineStep(
        stepName: 'Eye Care',
        productType: 'Caffeine + Vitamin K Eye Cream',
        tip: 'Apply with your ring finger — it has the lightest touch.',
        emoji: '👁️',
      ));
    }

    // 5. Moisturiser
    switch (_skin) {
      case 'Oily':
        steps.add(const RoutineStep(
          stepName: 'Moisturise',
          productType: 'Oil-Free Gel Moisturiser',
          tip: 'Skipping moisturiser causes your skin to overcompensate with oil.',
          emoji: '🌊',
        ));
      case 'Dry':
        steps.add(const RoutineStep(
          stepName: 'Moisturise',
          productType: 'Rich Cream (Ceramides + Shea Butter)',
          tip: 'Layer while skin is still slightly damp to lock in moisture.',
          emoji: '🧴',
        ));
      case 'Sensitive':
        steps.add(const RoutineStep(
          stepName: 'Moisturise',
          productType: 'Fragrance-Free Ceramide Lotion',
          tip: 'Ceramides rebuild your damaged skin barrier over time.',
          emoji: '🛡️',
        ));
      case 'Combination':
        steps.add(const RoutineStep(
          stepName: 'Moisturise',
          productType: 'Lightweight Gel-Cream Hybrid',
          tip: 'Apply a heavier amount to dry cheek areas only.',
          emoji: '⚖️',
        ));
      default:
        steps.add(const RoutineStep(
          stepName: 'Moisturise',
          productType: 'Lightweight Daily Moisturiser',
          tip: 'Keeps your skin balanced and prepped for SPF.',
          emoji: '✨',
        ));
    }

    // 6. SPF — always last, always non-negotiable
    steps.add(const RoutineStep(
      stepName: 'Protect (SPF)',
      productType: 'Broad-Spectrum SPF 50+',
      tip: 'The single most impactful anti-ageing step. Never skip it.',
      emoji: '☂️',
    ));

    return steps;
  }

  // ── PM Routine ───────────────────────────────────────────────────────────────
  static List<RoutineStep> get pmRoutine {
    final steps = <RoutineStep>[];

    // 1. Remove make-up / SPF
    if (_skin == 'Dry' || _skin == 'Sensitive') {
      steps.add(const RoutineStep(
        stepName: 'Makeup Removal',
        productType: 'Micellar Water or Cleansing Balm',
        tip: 'Never go to bed with SPF on — it continues to oxidise and damage skin.',
        emoji: '🌙',
      ));
    } else {
      steps.add(const RoutineStep(
        stepName: 'First Cleanse',
        productType: 'Cleansing Oil or Balm',
        tip: 'Oil-based first cleanse dissolves SPF and make-up completely.',
        emoji: '🕯️',
      ));
    }

    // 2. Second cleanse
    steps.add(RoutineStep(
      stepName: 'Second Cleanse',
      productType: _skin == 'Dry' || _skin == 'Sensitive'
          ? 'Gentle Cream Cleanser'
          : 'Gel Cleanser',
      tip: 'Water-based second cleanse removes sweat and residue the oil missed.',
      emoji: '🫧',
    ));

    // 3. Exfoliate (not every night)
    if (_concerns.contains('Dark Spots') || _concerns.contains('Dullness') || _concerns.contains('Uneven Tone')) {
      steps.add(const RoutineStep(
        stepName: 'Exfoliate (2–3×/week)',
        productType: 'AHA Glycolic or Lactic Acid Toner',
        tip: 'Use on alternating nights. Fades pigmentation and reveals fresh cells.',
        emoji: '🌟',
      ));
    } else if (_concerns.contains('Acne') || _concerns.contains('Pores') || _skin == 'Oily') {
      steps.add(const RoutineStep(
        stepName: 'Exfoliate (2–3×/week)',
        productType: 'BHA (Salicylic Acid 2%) Toner',
        tip: 'Penetrates pores from within — the only acid that\'s oil-soluble.',
        emoji: '🫧',
      ));
    }

    // 4. Treatment / Active Serum
    if (_concerns.contains('Wrinkles') || (_age != null && _age! >= 28)) {
      steps.add(const RoutineStep(
        stepName: 'Treatment',
        productType: 'Retinol Serum (start 0.025%, build up slowly)',
        tip: 'Clinically proven to rebuild collagen. Use only at night; always wear SPF next day.',
        emoji: '⏳',
      ));
    } else if (_concerns.contains('Acne')) {
      steps.add(const RoutineStep(
        stepName: 'Treatment',
        productType: 'Benzoyl Peroxide 2.5% Spot Treatment',
        tip: 'Apply only to active breakouts — kills acne bacteria overnight.',
        emoji: '🎯',
      ));
    } else if (_concerns.contains('Dryness') || _skin == 'Dry') {
      steps.add(const RoutineStep(
        stepName: 'Treatment',
        productType: 'Hyaluronic Acid + Peptide Sleeping Serum',
        tip: 'Apply to damp skin and layer your night cream on top immediately.',
        emoji: '💧',
      ));
    } else {
      steps.add(const RoutineStep(
        stepName: 'Treatment',
        productType: 'Barrier-Repair Serum (Ceramides + Niacinamide)',
        tip: 'Skin regenerates between 10 PM – 2 AM — give it the best ingredients.',
        emoji: '🛡️',
      ));
    }

    // 5. Eye Cream
    if (_concerns.contains('Dark Circles') || _concerns.contains('Wrinkles') || (_age != null && _age! >= 23)) {
      steps.add(const RoutineStep(
        stepName: 'Eye Care',
        productType: 'Retinol-free Peptide Eye Cream',
        tip: 'The eye area is 5× thinner than the rest of your face — it ages first.',
        emoji: '👁️',
      ));
    }

    // 6. Night Moisturiser / Sleeping Mask
    switch (_skin) {
      case 'Dry':
        steps.add(const RoutineStep(
          stepName: 'Night Cream',
          productType: 'Heavy Occlusive Night Cream (Shea + Squalane)',
          tip: 'Wake up with visibly plumper, dewier skin.',
          emoji: '🌙',
        ));
      case 'Oily':
        steps.add(const RoutineStep(
          stepName: 'Night Cream',
          productType: 'Lightweight Gel Night Moisturiser',
          tip: 'Don\'t skip — dehydrated oily skin overproduces oil to compensate.',
          emoji: '🌊',
        ));
      case 'Sensitive':
        steps.add(const RoutineStep(
          stepName: 'Night Cream',
          productType: 'Calming Overnight Mask (Centella + Oat)',
          tip: 'No active ingredients tonight — let your barrier recover quietly.',
          emoji: '🌸',
        ));
      default:
        steps.add(const RoutineStep(
          stepName: 'Night Cream',
          productType: 'Nourishing Night Moisturiser',
          tip: 'Seals in all the actives and prevents transepidermal water loss.',
          emoji: '✨',
        ));
    }

    // 7. Lip mask (always a win — especially if 'Lip Looks' interest)
    steps.add(const RoutineStep(
      stepName: 'Lip Care',
      productType: 'Overnight Lip Mask or Balm',
      tip: 'Wake up to soft, conditioned lips — takes 3 seconds to apply.',
      emoji: '💋',
    ));

    return steps;
  }

  // ── Daily Tip ────────────────────────────────────────────────────────────────
  // Rotates through 7 tips so it feels fresh each day of the week.
  static String get dailyTip {
    final tips = _tipsForProfile();
    final index = DateTime.now().weekday - 1; // 0 = Monday
    return tips[index % tips.length];
  }

  static List<String> _tipsForProfile() {
    if (_concerns.contains('Acne') || _skin == 'Oily') {
      return [
        'Change your pillowcase every 2–3 days — it accumulates acne-causing bacteria fast 🛏️',
        'Never pop pimples — it pushes bacteria deeper and causes dark scarring 🚫',
        'Always use non-comedogenic (non-pore-clogging) products 🫧',
        'Drink 8+ glasses of water daily to help flush out toxins linked to breakouts 💧',
        'Clean your phone screen daily — it touches your face more than your hands do 📱',
        'A low-glycaemic diet (less sugar, more greens) can halve breakout frequency 🥗',
        'Niacinamide is the Oily Skin MVP: controls oil, shrinks pores, and fades marks ✨',
      ];
    }
    if (_skin == 'Dry') {
      return [
        'Apply moisturiser within 60 seconds of washing — this locks in hydration before it evaporates 💧',
        'Drink at least 8 glasses of water; plump skin starts from within 🌊',
        'A bedside humidifier prevents moisture loss while you sleep 🌙',
        'Avoid long hot showers — they strip your skin\'s natural lipid barrier 🚿',
        'Layer skincare: toner → serum → moisturiser → oil (thinnest to thickest) 🧴',
        'Hyaluronic acid can hold 1,000× its weight in water — make it your hero 💫',
        'Gentle exfoliation 1–2× weekly removes the dead layer blocking moisture absorption ✨',
      ];
    }
    if (_skin == 'Sensitive') {
      return [
        'Patch-test every new product on your inner wrist for 48 hrs before using it on your face 🌸',
        'Fragrance is the #1 cause of allergic contact dermatitis — go fragrance-free 🚫',
        'Avoid touching your face unnecessarily — hands transfer irritants and bacteria 🤲',
        'Use lukewarm water only — hot water inflames and weakens sensitive skin 🌡️',
        'Ceramides literally rebuild your skin barrier over 4–6 weeks of consistent use 🛡️',
        'Introduce only ONE new product at a time and wait 2 weeks before adding another ⏳',
        'A 3-step routine (cleanse, moisturise, SPF) is often gentler and just as effective ✨',
      ];
    }
    if (_concerns.contains('Dark Spots') || _concerns.contains('Uneven Tone')) {
      return [
        'Vitamin C in the morning + SPF 50 = the most powerful dark-spot duo on the market ☀️',
        'AHA exfoliants 2× a week accelerate cell turnover and fade pigmentation 3× faster 🌟',
        'Sun is the #1 cause of dark spots — SPF 50 is non-negotiable, even on cloudy days ☂️',
        'Niacinamide inhibits melanin transfer — use 10% daily for visible results in 4 weeks ✨',
        'Post-inflammatory hyperpigmentation (red/dark marks from spots) fades in 3–6 months with actives 📅',
        'Retinol speeds up skin cell renewal — start at 0.025% and build up slowly ⏳',
        'Never skip SPF after chemical exfoliation — freshly exposed skin burns and re-pigments easily 🔴',
      ];
    }
    if (_concerns.contains('Wrinkles') || (_age != null && _age! >= 28)) {
      return [
        'Retinol is the most clinically proven anti-ageing ingredient — start in your late 20s ⏳',
        'SPF 50 prevents up to 90% of visible ageing — it\'s the most powerful anti-ageing product 🛡️',
        'Collagen production drops ~1% per year after 25 — peptides help signal your skin to rebuild ✨',
        'Sleep on a silk pillowcase to reduce sleep creases that deepen into wrinkles over time 🌙',
        'Stress raises cortisol, which breaks down collagen — even 10 mins of mindfulness helps 🧘',
        'Antioxidants (Vitamin C, E, ferulic acid) neutralise free radicals that accelerate ageing ☀️',
        'Repeated facial expressions form lines — a gentle Gua Sha routine can release facial tension 💆',
      ];
    }
    // Default / Normal skin
    return [
      'SPF every single day — UV damage is cumulative and irreversible ☂️',
      'Consistency > expensive products. A simple routine done daily beats an erratic fancy one ✨',
      'Beauty sleep is real: skin cell regeneration peaks between 10 PM and 2 AM 🌙',
      'Vitamin C in the AM + Retinol in the PM is the gold-standard glow-up combo ☀️🌙',
      'Eat your skincare: berries, avocado, salmon, and walnuts visibly improve skin over weeks 🥑',
      'Stress spikes cortisol, which triggers breakouts and collagen breakdown — protect your peace 🧘',
      'Clean makeup brushes weekly — dirty brushes are a leading cause of recurring breakouts 🖌️',
    ];
  }

  // ── Key Ingredients / Product Keywords ───────────────────────────────────────
  static List<String> get productKeywords {
    final recs = <String>{};

    // Skin type base
    switch (_skin) {
      case 'Oily':
        recs.addAll(['Niacinamide', 'Salicylic Acid', 'Clay', 'Zinc']);
      case 'Dry':
        recs.addAll(['Hyaluronic Acid', 'Ceramides', 'Squalane', 'Shea Butter']);
      case 'Sensitive':
        recs.addAll(['Centella Asiatica', 'Oat Extract', 'Ceramides', 'Allantoin']);
      case 'Combination':
        recs.addAll(['Niacinamide', 'Hyaluronic Acid', 'Green Tea', 'Zinc']);
      default:
        recs.addAll(['Hyaluronic Acid', 'Niacinamide', 'Antioxidants']);
    }

    // Concerns layer
    if (_concerns.contains('Acne')) recs.addAll(['Salicylic Acid', 'Benzoyl Peroxide', 'Tea Tree']);
    if (_concerns.contains('Dark Spots')) recs.addAll(['Vitamin C', 'Alpha Arbutin', 'Kojic Acid']);
    if (_concerns.contains('Wrinkles')) recs.addAll(['Retinol', 'Peptides', 'Coenzyme Q10']);
    if (_concerns.contains('Redness')) recs.addAll(['Azelaic Acid', 'Green Tea', 'Centella']);
    if (_concerns.contains('Dark Circles')) recs.addAll(['Caffeine', 'Vitamin K', 'Peptides']);
    if (_concerns.contains('Dryness')) recs.addAll(['Ceramides', 'Glycerin', 'Squalane']);
    if (_concerns.contains('Pores')) recs.addAll(['BHA', 'Niacinamide', 'Retinol']);
    if (_concerns.contains('Dullness')) recs.addAll(['Vitamin C', 'AHA', 'Niacinamide']);
    if (_concerns.contains('Uneven Tone')) recs.addAll(['Alpha Arbutin', 'Vitamin C', 'AHA/BHA']);
    if (_concerns.contains('Oiliness')) recs.addAll(['Niacinamide', 'Zinc', 'Clay', 'BHA']);

    // Age-based additions
    if (_age != null && _age! >= 28) recs.addAll(['Retinol', 'Peptides']);
    if (_age != null && _age! >= 35) recs.addAll(['Coenzyme Q10', 'Bakuchiol']);

    // Always include SPF
    recs.add('SPF 50+');

    return recs.take(8).toList();
  }

  // ── Interest-based homepage category order ───────────────────────────────────
  // Returns category names in the recommended order for this user.
  static List<String> get prioritisedCategories {
    final order = <String>[];

    if (_interests.any((i) => ['AM Routine', 'PM Routine', 'K-Beauty', 'SPF Obsessed'].contains(i)) ||
        _skin.isNotEmpty) {
      order.add('Skin Care');
    }
    if (_interests.any((i) => ['Natural', 'Glam', 'Bold', 'Minimal', 'Night Out', 'Editorial'].contains(i))) {
      order.add('Make up');
    }
    if (_interests.any((i) => ['Face Yoga', 'Facial Massage', 'Face Masking'].contains(i))) {
      order.add('Face Yoga');
    }
    if (_interests.any((i) => ['Luxury', 'Drugstore', 'Cruelty-Free', 'Vegan'].contains(i))) {
      order.add('Products');
    }

    // Fill remaining
    for (final cat in ['Make up', 'Cosmetics', 'Skin Care', 'Face Yoga', 'Products']) {
      if (!order.contains(cat)) order.add(cat);
    }

    return order;
  }
}