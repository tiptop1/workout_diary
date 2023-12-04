// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'converter/datetime_converter.dart';

import 'dao/exercise_dao.dart';
import 'dao/exercise_set_dao.dart';
import 'dao/workout_dao.dart';
import 'model/exercise_model.dart';
import 'model/exercise_set_model.dart';
import 'model/workout_model.dart';

part 'workout_diary_database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, NullableDateTimeConverter])
@Database(version: 1, entities: [ExerciseModel, ExerciseSetModel, WorkoutModel])
abstract class WorkoutDiaryDatabase extends FloorDatabase {
  ExerciseDao get exerciseDao;

  ExerciseSetDao get exerciseSetDao;

  WorkoutDao get workoutDao;
}
