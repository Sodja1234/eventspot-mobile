import '../../business/models/article/category.dart';
import '../../business/models/article/event.dart';

class HomeEventState {
  final List<Event>? latestEvents;
  final List<Category>? categories;
  final List<Event>? favEvents;
  final bool isLoading;

  HomeEventState({
    this.latestEvents,
    this.categories,
    this.favEvents,
    this.isLoading = false,
  });

  HomeEventState copyWith({
    List<Event>? latestEvents,
    List <Category>? categories,
    List<Event>? favEvents,
    bool? isLoading,
  }) {
    return HomeEventState(
      latestEvents: latestEvents ?? this.latestEvents,
      categories: categories ?? this.categories,
      favEvents: favEvents ?? this.favEvents,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
