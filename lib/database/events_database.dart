import 'package:expense_manager/database/app_database.dart';
import 'package:expense_manager/database/database_config.dart';
import 'package:expense_manager/models/database_models/events_db_model.dart';
import 'package:sqflite/sqflite.dart';

class EventDBService {
  final String createQuery =
      """CREATE TABLE IF NOT EXISTS $tableName (
    $idField $primaryIdType,
    $nameField $notNullTextType,
    $startDateField $textType,
    $endDateField $textType,
    $createdDateField $textType,
    $modifiedDateField $textType
  );
  """;

  // Insert a new event into the database
  Future<int> insert(EventModel eventModel) async {
    Database db = await AppDatabase.instance.database;
    int savedId = await db.insert(tableName, eventModel.toJson());
    return savedId;
  }

  // Get all events from the database
  Future<List<EventModel>> getAll() async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> allData = await db.query(tableName);
    List<EventModel> events = [];
    events = List<EventModel>.from(allData.map((x) => EventModel.fromJson(x)));

    return events;
  }

  // Get a specific event by ID
  Future<EventModel?> getById(int id) async {
    Database db = await AppDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: "$idField = ?",
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return EventModel.fromJson(result.first);
    } else {
      return null;
    }
  }

  // Delete an event by ID
  Future<int> delete(int id) async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName, where: "$idField = ?", whereArgs: [id]);
  }

  // Update an existing event in the database
  Future<int> update(EventModel eventModel) async {
    Database db = await AppDatabase.instance.database;
    return await db.update(
      tableName,
      eventModel.toJson(),
      where: "$idField = ?",
      whereArgs: [eventModel.id],
    );
  }

  // Delete all events from the database
  Future<int> deleteAll() async {
    Database db = await AppDatabase.instance.database;
    return await db.delete(tableName);
  }
}
