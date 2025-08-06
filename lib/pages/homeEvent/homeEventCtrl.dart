import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/framework/user/userNetworkServiceImpl.dart';
import '../../business/models/article/event.dart';
import '../../business/services/user/userLocalService.dart';
import '../../business/services/user/userNetworkService.dart';
import '../../main.dart';
import '../../business/services/gestion/gestionNetworkService.dart';
import 'homeEventState.dart';

class HomeEventController extends StateNotifier<HomeEventState> {
  final gestionNetwork = getIt.get<GestionNetworkService>();
  final userNetwork = getIt.get<UserNetworkService>();

  HomeEventController() : super(HomeEventState()) {
    loadHomeData();
  }

  Future<void> loadFavoriteEvents(String token) async {
    try {
      final favs = await userNetwork.recupererFavEvents(token);
      state = state.copyWith(favEvents: favs);
    } catch (e) {
      print("Erreur lors du chargement des favoris : $e");
    }
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);
    try {
      final latest = await gestionNetwork.recupererDerniersEvents(3);
      final categories = await gestionNetwork.getCategories();


      final user = await getIt.get<UserLocalService>().recupererUser();
      List<Event> favEvents = [];
      if (user?.token != null) {
        favEvents = await userNetwork.recupererFavEvents(user!.token!);
        print('Favoris chargés: ${favEvents.length}');
      }
      print( 'Favoris chargés: ${favEvents.length}');

      state = state.copyWith(
        latestEvents: latest,
        categories: categories,
        favEvents: favEvents,
        isLoading: false,
      );
    } catch (e) {
      print('Erreur lors du chargement: $e');
      state = state.copyWith(isLoading: false);
    }
  }



}

final homeEventControllerProvider =
StateNotifierProvider<HomeEventController, HomeEventState>((ref) {
  return HomeEventController();
});
