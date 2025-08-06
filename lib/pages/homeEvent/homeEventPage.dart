import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/loginControl.dart';
import '../composants/composants.dart';
import '../event/eventPage.dart';
import 'homeEventCtrl.dart';

class HomeEventPage extends ConsumerStatefulWidget {
  const HomeEventPage({super.key});

  @override
  ConsumerState<HomeEventPage> createState() => _HomeEventPageState();
}

class _HomeEventPageState extends ConsumerState<HomeEventPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = ref.read(homeEventControllerProvider.notifier);
      controller.loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeEventControllerProvider);
    final loginState = ref.watch(loginControlProvider);
    final user = loginState.user;
    if (user?.token != null && (state.favEvents?.isEmpty ?? true)) {
      ref.read(homeEventControllerProvider.notifier).loadFavoriteEvents(user!.token!);
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: navBar(),
      ),
      body: state.isLoading == true
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Bienvenue
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: // Remplacez votre Container "Bienvenue" par :
              SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    // Image de fond avec effet parallaxe
                    Positioned.fill(
                      child: Image.network(
                        "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80",
                        fit: BoxFit.cover,
                        color: Colors.deepPurple.withOpacity(0.7),
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),

                    // Contenu par-dessus
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Bienvenue sur EventSpot",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Découvrez les meilleurs événements autour de vous",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ),
            const SizedBox(height: 24),

            // Section Derniers événements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🕒 Derniers événements",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Voir tout"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.latestEvents?.length ?? 0,
                itemBuilder: (context, index) {
                  final event = state.latestEvents![index];
                  return CarteEvenementHorizontal(event: event);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Section Catégories
            Text(
              "📂 categories",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100, // Hauteur reduite
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.categories?.length ?? 0,
                itemBuilder: (context, index) {
                  final cat = state.categories?[index];
                  if (cat == null) return const SizedBox.shrink();


                  final color = Colors.primaries[index % Colors.primaries.length].withOpacity(0.2);
                  final icon = Icons.category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        if (user == null) {
                          context.go('/public/intro');
                        } else {
                          context.go('/event/${cat.id}');
                        }
                      },
                      child: Container(
                        width: 120, // Largeur légèrement augmentée
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              size: 32,
                              color: Colors.primaries[index % Colors.primaries.length],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                cat.title ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 24),


            if (user != null && state.favEvents != null ) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "❤️ Événements favoris",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Voir tout"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 290, // Augmentation légère de la hauteur
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Padding sur les côtés
                  itemCount: state.favEvents?.length ?? 0,
                  itemBuilder: (context, index) {
                    final event = state.favEvents![index];
                    return Container(
                      margin: const EdgeInsets.only(right: 16), // Espace entre les cartes
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CarteEvenementFavHorizontal(event: event),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 16), // Espacement entre les items
                ),
              ),
              const SizedBox(height: 24),
            ],

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/app/HomeEvent'),
        backgroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.home, color: Colors.deepPurple),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar1(selectedIndex: 1),
    );
  }
}