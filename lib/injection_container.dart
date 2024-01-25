import 'package:get_it/get_it.dart';
import 'package:workout_diary/src/data/db/local_repository.dart';
import 'package:workout_diary/src/data/db/workout_diary_database.dart';

import 'src/domain/use_case/exercise_use_cases.dart';
import 'src/domain/use_case/workout_use_cases.dart';

Future<void> init() async {
  final db = await $FloorWorkoutDiaryDatabase.databaseBuilder('app_database.db').build();
  final repo = LocalRepository(db);
  GetIt.I.registerLazySingleton(() => ExerciseUseCases(repo));
  GetIt.I.registerLazySingleton(() => WorkoutUseCases(repo));
}


