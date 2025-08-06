import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_mobile_template/pages/otp/otpController.dart';

import '../../MonApplication.dart';
import '../../business/models/article/event.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/loginControl.dart';
import '../singleEvent/singleEventCtrl.dart';


class navBar extends ConsumerWidget {
  const navBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControlProvider);
    final user = loginState.user;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      centerTitle: true,
      title: const Text(
        'EventSpot',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 1.2,
        ),
      ),
      leading: user != null
          ? IconButton(
        icon: const Icon(Icons.logout, color: Colors.black54),
        onPressed: () async {
          await ref.read(loginControlProvider.notifier).logout();
          if (context.mounted) {
            context.go('/public/intro');
          }
        },
      )
          : null,
      actions: [
        IconButton(
          icon: Icon(
            user == null ? Icons.login : Icons.search,
            color: Colors.black54,
          ),
          onPressed: () {
            if (user == null) {
              context.go('/public/intro');
            } else {
              context.go('/app/home');
            }
          },
        ),
      ],
    );
  }
}


class BottomBar1 extends ConsumerWidget {
  final int selectedIndex;

  const BottomBar1({super.key, required this.selectedIndex});

  void _onItemTapped(BuildContext context, int index, WidgetRef ref) {
    final loginState = ref.watch(loginControlProvider);
    final user = loginState.user;

    switch (index) {
      case 0:
        if (user == null) {
          context.go('/public/intro');
        } else {
          context.go('/app/home');
        }
        break;
      case 1:
        context.go('/app/HomeEvent');
        break;
      case 2:
        if (user == null) {
          context.go('/public/intro');
        } else {
          context.go('/app/home');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(
            context,
            ref,
            icon: Icons.event,
            label: 'Événements',
            index: 0,
          ),
          const SizedBox(width: 40),
          _buildNavIcon(
            context,
            ref,
            icon: Icons.person,
            label: 'Profil',
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(
      BuildContext context,
      WidgetRef ref, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final isSelected = selectedIndex == index;

    return SizedBox(
      height: 56, // hauteur fixe adaptée à un BottomAppBar
      child: GestureDetector(
        onTap: () => _onItemTapped(context, index, ref),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 2), // petit espacement pour éviter l'overflow
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

}


class CarteEvent extends ConsumerStatefulWidget {
  final Event event;

  const CarteEvent(this.event, {super.key});

  @override
  ConsumerState<CarteEvent> createState() => _CarteEventState();
}

class _CarteEventState extends ConsumerState<CarteEvent> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.event.isFavorite ?? false;
  }

  @override
  void didUpdateWidget(covariant CarteEvent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si l’event a changé, on met à jour isFavorite avec la nouvelle valeur
    if (oldWidget.event.id != widget.event.id ||
        oldWidget.event.isFavorite != widget.event.isFavorite) {
      setState(() {
        isFavorite = widget.event.isFavorite ?? false;
      });
    }
  }

  Future<void> handleLike() async {
    final user = ref.read(loginControlProvider).user;
    final token = user?.token ?? "";

    if (user == null) {
      context.go('/public/intro');
      return;
    }

    // Optimistic update
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      await ref
          .read(singleEventControllerProvider.notifier)
          .favorite(widget.event.id, token);
    } catch (e) {
      // Rollback en cas d'erreur
      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.event.media?.url;
    final baseUrl = dotenv.env['baseUrl'] ?? '';
    final imageUrl = mediaUrl != null
        ? (kIsWeb ? 'http://localhost:8000/$mediaUrl' : '$baseUrl/$mediaUrl')
        : null;

    return GestureDetector(
      onTap: () {
        context.go('/events/${widget.event.id}');
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageUrl != null
                  ? Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      color: Colors.black26, size: 60),
                ),
              )
                  : Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.black26, size: 60),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title ?? 'Titre inconnu',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.event.description ??
                              'Pas de description disponible.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.loop,
                                size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Cycle : ${widget.event.cycle ?? 'Inconnu'}",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (widget.event.categories != null &&
                            widget.event.categories!.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: widget.event.categories!
                                .map((cat) => Chip(
                              label: Text(cat.title ?? '',
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ))
                                .toList(),
                          ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                            widget.event.isFavorite == 1 ? Colors.red : Colors.deepPurple,
                          ),
                          onPressed: handleLike,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}








class CarteEvenementHorizontal extends StatelessWidget {
  final Event event;

  const CarteEvenementHorizontal({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final mediaUrl = event.media?.url;
    final baseUrl = dotenv.env['baseUrl'] ?? '';
    final imageUrl = mediaUrl != null
        ? (kIsWeb
        ? 'http://localhost:8000/$mediaUrl'
        : '$baseUrl/$mediaUrl')
        : null;

    return GestureDetector(
          onTap: () {
            context.go('/events/${event.id}');
          },
      child: SizedBox(
        width: 240,
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image,
                          color: Colors.black26, size: 40),
                    ),
                  )
                      : Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Icon(FontAwesomeIcons.image,
                          color: Colors.black26, size: 32),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? "Sans titre",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      icon: FontAwesomeIcons.calendarAlt,
                      text: event.cycle ?? "Date inconnue",
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      icon: FontAwesomeIcons.mapMarkerAlt,
                      text: event.title ?? "Lieu inconnu",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}



class CarteEvenementFavHorizontal extends StatelessWidget {
  final Event event;

  const CarteEvenementFavHorizontal({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final baseUrl = dotenv.env['baseUrl'] ?? '';
    final mediaUrl = event.media?.url;
    final imageUrl = mediaUrl != null
        ? (kIsWeb ? 'http://localhost:8000/$mediaUrl' : '$baseUrl/$mediaUrl')
        : null;

    return GestureDetector(
          onTap: () {
            context.go('/events/${event.id}');
          },
      child: Flexible(
        child: SizedBox(
          width: 360,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(imageUrl),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: _buildCardContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: imageUrl != null
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image,
                color: Colors.black26, size: 48),
          ),
        )
            : Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(FontAwesomeIcons.image,
                color: Colors.black26, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.title ?? "Sans titre",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }

}


