import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavender_schedule/model/school_class.dart';

final selectedClassProvider = StateProvider<SchoolClass?>((ref) => null);