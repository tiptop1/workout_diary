// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'converter/datetime_converter.dart';
import 'entity/exercise.dart';
import 'entity/exerciseset.dart';
import 'entity/workout.dart';

import 'dao/exercise_dao.dart';
import 'dao/exerciseset_dao.dart';
import 'dao/workout_dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, NullableDateTimeConverter])
@Database(version: 1, entities: [Exercise, ExerciseSet, Workout])
abstract class AppDatabase extends FloorDatabase {
  ExerciseDao get exerciseDao;
  ExerciseSetDao get exerciseSetDao;
  WorkoutDao get workoutDao;
}