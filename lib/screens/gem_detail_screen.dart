import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/gem.dart';
import '../config/theme.dart';
import '../providers/gem_provider.dart';

class GemDetailScreen extends StatefulWidget {
  final Gem gem;
  const GemDetailScreen({super.key, required this.gem});

  @override
  State<GemDetailScreen> createState() => _GemDetailScreenState();
}

class _GemDetailScreenState extends State<GemDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gem = widget.gem;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Image SliverAppBar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Consumer<GemProvider>(
                  builder: (_, gemProvider, __) => GestureDetector(
                    onTap: () => gemProvider.toggleFavorite(gem.id),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        gem.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: gem.isFavorite ? AppTheme.secondaryColor : AppTheme.textHint,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  gem.images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: gem.images.length,
                          onPageChanged: (i) => setState(() => _currentImageIndex = i),
                          itemBuilder: (_, i) => CachedNetworkImage(
                            imageUrl: gem.images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => Container(color: const Color(0xFFF3F0FF)),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFF3F0FF),
                              child: const Center(
                                child: Icon(Icons.diamond_outlined, size: 60, color: AppTheme.primaryLight),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF3F0FF),
                          child: const Center(
                            child: Icon(Icons.diamond_outlined, size: 60, color: AppTheme.primaryLight),
                          ),
                        ),

                  // Page indicator dots
                  if (gem.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0, right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gem.images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentImageIndex == i ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == i
                                  ? AppTheme.primaryColor
                                  : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFEDE9FE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title & price
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                gem.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'serif',
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (gem.color != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  gem.color!,
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currencyFormat.format(gem.price),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFF0EBFF)),

                  // Description
                  if (gem.description != null) ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Description'),
                          const SizedBox(height: 8),
                          Text(
                            gem.description!,
                            style: const TextStyle(
                              fontSize: 14, color: AppTheme.textSecondary, height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0EBFF)),
                  ],

                  // Specs grid
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Specifications'),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10, runSpacing: 10,
                          children: [
                            if (gem.weight != null) _specChip(Icons.scale_outlined, '${gem.weight}ct'),
                            if (gem.model != null) _specChip(Icons.category_outlined, gem.model!),
                            if (gem.location != null) _specChip(Icons.location_on_outlined, gem.location!),
                            _specChip(
                              Icons.circle,
                              gem.status,
                              color: gem.status == 'available' ? AppTheme.successColor : AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFF0EBFF)),

                  // Contact
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Contact Seller'),
                        const SizedBox(height: 14),
                        if (gem.contactName != null)
                          _contactRow(Icons.person_outline_rounded, gem.contactName!, null),
                        if (gem.contactPhone != null)
                          _contactRow(
                            Icons.phone_outlined,
                            gem.contactPhone!,
                            () => _launch('tel:${gem.contactPhone}'),
                          ),
                        if (gem.contactEmail != null)
                          _contactRow(
                            Icons.email_outlined,
                            gem.contactEmail!,
                            () => _launch('mailto:${gem.contactEmail}'),
                          ),
                        if (gem.contactName == null && gem.contactPhone == null && gem.contactEmail == null)
                          const Text(
                            'No contact info provided.',
                            style: TextStyle(color: AppTheme.textHint, fontSize: 14),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Extra bottom space
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),

      // Bottom buttons
      bottomNavigationBar: _hasContact(gem)
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10, offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (gem.contactPhone != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launch('tel:${gem.contactPhone}'),
                          icon: const Icon(Icons.phone_outlined, size: 18),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    if (gem.contactPhone != null && gem.contactEmail != null)
                      const SizedBox(width: 12),
                    if (gem.contactEmail != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launch('mailto:${gem.contactEmail}'),
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: const Text('Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  bool _hasContact(Gem gem) =>
      gem.contactPhone != null || gem.contactEmail != null;

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
    ),
  );

  Widget _specChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDE9FE)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }
}
