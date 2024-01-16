// private 값들은 불러올 수 없다.
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import '../model/category_color.dart';
import '../model/schedule.dart';
import 'package:path/path.dart' as p;

// private 값까지 불러올 수 있다.
part 'drift_database.g.dart';

// decorator - @Ovveride 앞에 @
@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  Future<int> createSchedule(SchedulesCompanion data) => into(schedules).insert(data);

  Future<int> createCategoryColor(CategoryColorsCompanion data) => into(categoryColors).insert(data);

  Future<List<CategoryColor>> getCategoryColors() => select(categoryColors).get();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
