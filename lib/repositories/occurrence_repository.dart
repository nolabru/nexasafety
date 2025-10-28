import 'package:nexasafety/models/occurrence.dart';

class OccurrenceRepository {
  OccurrenceRepository._internal();
  static final OccurrenceRepository _instance = OccurrenceRepository._internal();
  factory OccurrenceRepository() => _instance;

  final List<Occurrence> _items = [];

  List<Occurrence> get all => List.unmodifiable(_items);

  void add(Occurrence o) {
    _items.insert(0, o);
  }

  void clear() {
    _items.clear();
  }
}
