import 'package:flutter/material.dart';
import 'package:flutter_ui/app_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> quotes = [
    "Dream big. Start small. Act now.",
    "Discipline beats motivation.",
    "Small steps every day add up.",
    "Make it simple, but significant.",
    "Progress > perfection.",
  ];

  static const List<Map<String, dynamic>> gridItems = [
    {"title": "Focus", "icon": Icons.center_focus_strong},
    {"title": "Health", "icon": Icons.favorite_border},
    {"title": "Study", "icon": Icons.menu_book_outlined},
    {"title": "Work", "icon": Icons.work_outline},
    {"title": "Money", "icon": Icons.account_balance_wallet_outlined},
    {"title": "Sleep", "icon": Icons.bedtime_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===== Your existing header (kept) =====
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_rounded,
                                color: whiteColor,
                                size: 30,
                              ),
                              Icon(
                                Icons.search_outlined,
                                color: whiteColor,
                                size: 30,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            "LOREM",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                ),
                          ),
                          Text(
                            "LOREM qwer ty uio op kjhg asdf okmnhy",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                  color: blackColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: 20,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(height: 60, width: 60),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Banner =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [yellowColor, Colors.orange.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Daily inspiration\nKeep building your habits",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: blackColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                          ),
                        ),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text("Explore"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
 // ===== Banner =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [yellowColor, Colors.orange.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Daily inspiration\nKeep building your habits",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: blackColor,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                          ),
                        ),
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text("Explore"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ===== Horizontal quotes (cards) =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quotes",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      "Swipe",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal, // horizontal scrolling
                  itemCount: quotes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 260,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote, size: 22),
                              const SizedBox(height: 10),
                              Text(
                                quotes[index],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                "Tap to save",
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ===== Grid title =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  "Categories",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),

            // ===== Grid =====
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = gridItems[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item["icon"] as IconData, size: 28),
                          const SizedBox(height: 10),
                          Text(
                            item["title"] as String,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: gridItems.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
