import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/school_class.dart';
import 'package:lavender_schedule/utils/scrapper.dart';

class ClassesNotifier extends AsyncNotifier<List<SchoolClass>> {
  @override
  Future<List<SchoolClass>> build() async {
    return _fetch();
  }

  Future<List<SchoolClass>> _fetch() async {
    return Scrapper.getInstance().getClasses();
  }

  Future<void> refresh() async {
    // Force a fresh remote fetch when the calendar source is updated.
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

final classesProvider = AsyncNotifierProvider<ClassesNotifier, List<SchoolClass>>(
  ClassesNotifier.new,
);