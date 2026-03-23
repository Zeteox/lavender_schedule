import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/utils/scrapper.dart';

class CoursNotifier extends AsyncNotifier<List<SchoolClass>> {
  @override
  Future<List<SchoolClass>> build() async {
    return _fetch();
  }

  Future<List<SchoolClass>> _fetch() async {
    return Scrapper.getInstance().getClasses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final coursProvider = AsyncNotifierProvider<CoursNotifier, List<SchoolClass>>(
  CoursNotifier.new,
);