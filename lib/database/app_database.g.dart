// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  DailyWaterIntakeDao? _dailyWaterIntakeDaoInstance;

  WaterRecordDao? _waterRecordDaoInstance;

  ReminderSettingsDao? _reminderSettingsDaoInstance;

  CustomTimedReminderDao? _customTimedReminderDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `User` (`id` INTEGER NOT NULL, `age` INTEGER NOT NULL, `gender` TEXT NOT NULL, `weight` REAL NOT NULL, `exerciseVolume` TEXT NOT NULL, `targetWaterIntake` INTEGER NOT NULL, `checkInDays` INTEGER NOT NULL, `reminderStartTime` INTEGER NOT NULL, `reminderEndTime` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DailyWaterIntake` (`date` TEXT NOT NULL, `totalIntake` INTEGER NOT NULL, `lastUpdated` INTEGER NOT NULL, PRIMARY KEY (`date`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `WaterRecord` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `date` TEXT NOT NULL, `time` TEXT NOT NULL, `drinkType` TEXT NOT NULL, `drinkName` TEXT NOT NULL, `iconPath` TEXT NOT NULL, `amount` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ReminderSettings` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `allReminders` INTEGER NOT NULL, `intervalRemind` INTEGER NOT NULL, `reminderInterval` INTEGER NOT NULL, `dndTime` INTEGER NOT NULL, `reminderStartHour` INTEGER NOT NULL, `reminderStartMinute` INTEGER NOT NULL, `reminderEndHour` INTEGER NOT NULL, `reminderEndMinute` INTEGER NOT NULL, `dndLunch` INTEGER NOT NULL, `lunchStartHour` INTEGER NOT NULL, `lunchStartMinute` INTEGER NOT NULL, `lunchEndHour` INTEGER NOT NULL, `lunchEndMinute` INTEGER NOT NULL, `dndPlan` INTEGER NOT NULL, `lastUpdated` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `CustomTimedReminder` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `hour` INTEGER NOT NULL, `minute` INTEGER NOT NULL, `isAM` INTEGER NOT NULL, `isEnabled` INTEGER NOT NULL, `createdAt` INTEGER NOT NULL, `lastUpdated` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  DailyWaterIntakeDao get dailyWaterIntakeDao {
    return _dailyWaterIntakeDaoInstance ??=
        _$DailyWaterIntakeDao(database, changeListener);
  }

  @override
  WaterRecordDao get waterRecordDao {
    return _waterRecordDaoInstance ??=
        _$WaterRecordDao(database, changeListener);
  }

  @override
  ReminderSettingsDao get reminderSettingsDao {
    return _reminderSettingsDaoInstance ??=
        _$ReminderSettingsDao(database, changeListener);
  }

  @override
  CustomTimedReminderDao get customTimedReminderDao {
    return _customTimedReminderDaoInstance ??=
        _$CustomTimedReminderDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'User',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'age': item.age,
                  'gender': item.gender,
                  'weight': item.weight,
                  'exerciseVolume': item.exerciseVolume,
                  'targetWaterIntake': item.targetWaterIntake,
                  'checkInDays': item.checkInDays,
                  'reminderStartTime': item.reminderStartTime,
                  'reminderEndTime': item.reminderEndTime
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'User',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'age': item.age,
                  'gender': item.gender,
                  'weight': item.weight,
                  'exerciseVolume': item.exerciseVolume,
                  'targetWaterIntake': item.targetWaterIntake,
                  'checkInDays': item.checkInDays,
                  'reminderStartTime': item.reminderStartTime,
                  'reminderEndTime': item.reminderEndTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  @override
  Future<User?> getUser() async {
    return _queryAdapter.query('SELECT * FROM User WHERE id = 1',
        mapper: (Map<String, Object?> row) => User(
            id: row['id'] as int,
            age: row['age'] as int,
            gender: row['gender'] as String,
            weight: row['weight'] as double,
            exerciseVolume: row['exerciseVolume'] as String,
            targetWaterIntake: row['targetWaterIntake'] as int,
            checkInDays: row['checkInDays'] as int,
            reminderStartTime: row['reminderStartTime'] as int,
            reminderEndTime: row['reminderEndTime'] as int));
  }

  @override
  Future<void> updateUserWeight(double weight) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET weight = ?1 WHERE id = 1',
        arguments: [weight]);
  }

  @override
  Future<void> updateTargetWaterIntake(int targetWaterIntake) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET targetWaterIntake = ?1 WHERE id = 1',
        arguments: [targetWaterIntake]);
  }

  @override
  Future<void> updateCheckInDays(int checkInDays) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET checkInDays = ?1 WHERE id = 1',
        arguments: [checkInDays]);
  }

  @override
  Future<void> updateExerciseVolume(String exerciseVolume) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET exerciseVolume = ?1 WHERE id = 1',
        arguments: [exerciseVolume]);
  }

  @override
  Future<void> updateUserAge(int age) async {
    await _queryAdapter.queryNoReturn('UPDATE User SET age = ?1 WHERE id = 1',
        arguments: [age]);
  }

  @override
  Future<void> updateUserGender(String gender) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET gender = ?1 WHERE id = 1',
        arguments: [gender]);
  }

  @override
  Future<void> updateReminderTime(
    int startTime,
    int endTime,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE User SET reminderStartTime = ?1, reminderEndTime = ?2 WHERE id = 1',
        arguments: [startTime, endTime]);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }
}

class _$DailyWaterIntakeDao extends DailyWaterIntakeDao {
  _$DailyWaterIntakeDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _dailyWaterIntakeInsertionAdapter = InsertionAdapter(
            database,
            'DailyWaterIntake',
            (DailyWaterIntake item) => <String, Object?>{
                  'date': item.date,
                  'totalIntake': item.totalIntake,
                  'lastUpdated': item.lastUpdated
                }),
        _dailyWaterIntakeUpdateAdapter = UpdateAdapter(
            database,
            'DailyWaterIntake',
            ['date'],
            (DailyWaterIntake item) => <String, Object?>{
                  'date': item.date,
                  'totalIntake': item.totalIntake,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DailyWaterIntake> _dailyWaterIntakeInsertionAdapter;

  final UpdateAdapter<DailyWaterIntake> _dailyWaterIntakeUpdateAdapter;

  @override
  Future<DailyWaterIntake?> getDailyIntake(String date) async {
    return _queryAdapter.query('SELECT * FROM DailyWaterIntake WHERE date = ?1',
        mapper: (Map<String, Object?> row) => DailyWaterIntake(
            date: row['date'] as String,
            totalIntake: row['totalIntake'] as int,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [date]);
  }

  @override
  Future<List<DailyWaterIntake>> getRecentIntakes(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM DailyWaterIntake ORDER BY date DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => DailyWaterIntake(
            date: row['date'] as String,
            totalIntake: row['totalIntake'] as int,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [limit]);
  }

  @override
  Future<void> addWaterIntake(
    String date,
    int amount,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE DailyWaterIntake SET totalIntake = totalIntake + ?2, lastUpdated = ?3 WHERE date = ?1',
        arguments: [date, amount, lastUpdated]);
  }

  @override
  Future<List<DailyWaterIntake>> getAllIntakes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM DailyWaterIntake ORDER BY date ASC',
        mapper: (Map<String, Object?> row) => DailyWaterIntake(
            date: row['date'] as String,
            totalIntake: row['totalIntake'] as int,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<void> deleteDailyIntake(String date) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM DailyWaterIntake WHERE date = ?1',
        arguments: [date]);
  }

  @override
  Future<List<DailyWaterIntake>> getIntakesBetweenDates(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM DailyWaterIntake WHERE date BETWEEN ?1 AND ?2 ORDER BY date ASC',
        mapper: (Map<String, Object?> row) => DailyWaterIntake(date: row['date'] as String, totalIntake: row['totalIntake'] as int, lastUpdated: row['lastUpdated'] as int),
        arguments: [startDate, endDate]);
  }

  @override
  Future<void> insertDailyIntake(DailyWaterIntake intake) async {
    await _dailyWaterIntakeInsertionAdapter.insert(
        intake, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDailyIntake(DailyWaterIntake intake) async {
    await _dailyWaterIntakeUpdateAdapter.update(
        intake, OnConflictStrategy.abort);
  }
}

class _$WaterRecordDao extends WaterRecordDao {
  _$WaterRecordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _waterRecordInsertionAdapter = InsertionAdapter(
            database,
            'WaterRecord',
            (WaterRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': item.date,
                  'time': item.time,
                  'drinkType': item.drinkType,
                  'drinkName': item.drinkName,
                  'iconPath': item.iconPath,
                  'amount': item.amount,
                  'createdAt': item.createdAt
                }),
        _waterRecordUpdateAdapter = UpdateAdapter(
            database,
            'WaterRecord',
            ['id'],
            (WaterRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': item.date,
                  'time': item.time,
                  'drinkType': item.drinkType,
                  'drinkName': item.drinkName,
                  'iconPath': item.iconPath,
                  'amount': item.amount,
                  'createdAt': item.createdAt
                }),
        _waterRecordDeletionAdapter = DeletionAdapter(
            database,
            'WaterRecord',
            ['id'],
            (WaterRecord item) => <String, Object?>{
                  'id': item.id,
                  'date': item.date,
                  'time': item.time,
                  'drinkType': item.drinkType,
                  'drinkName': item.drinkName,
                  'iconPath': item.iconPath,
                  'amount': item.amount,
                  'createdAt': item.createdAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WaterRecord> _waterRecordInsertionAdapter;

  final UpdateAdapter<WaterRecord> _waterRecordUpdateAdapter;

  final DeletionAdapter<WaterRecord> _waterRecordDeletionAdapter;

  @override
  Future<void> deleteRecordById(int id) async {
    await _queryAdapter.queryNoReturn('DELETE FROM WaterRecord WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<List<WaterRecord>> getRecordsByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WaterRecord WHERE date = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => WaterRecord(
            id: row['id'] as int?,
            date: row['date'] as String,
            time: row['time'] as String,
            drinkType: row['drinkType'] as String,
            drinkName: row['drinkName'] as String,
            iconPath: row['iconPath'] as String,
            amount: row['amount'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [date]);
  }

  @override
  Future<List<WaterRecord>> getTodayRecords(String today) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WaterRecord WHERE date = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => WaterRecord(
            id: row['id'] as int?,
            date: row['date'] as String,
            time: row['time'] as String,
            drinkType: row['drinkType'] as String,
            drinkName: row['drinkName'] as String,
            iconPath: row['iconPath'] as String,
            amount: row['amount'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [today]);
  }

  @override
  Future<List<WaterRecord>> getRecentRecords(
    String startDate,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WaterRecord WHERE date >= ?1 ORDER BY date DESC, createdAt DESC LIMIT ?2',
        mapper: (Map<String, Object?> row) => WaterRecord(id: row['id'] as int?, date: row['date'] as String, time: row['time'] as String, drinkType: row['drinkType'] as String, drinkName: row['drinkName'] as String, iconPath: row['iconPath'] as String, amount: row['amount'] as int, createdAt: row['createdAt'] as int),
        arguments: [startDate, limit]);
  }

  @override
  Future<List<WaterRecord>> getRecordsBetweenDates(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WaterRecord WHERE date BETWEEN ?1 AND ?2 ORDER BY date DESC, createdAt DESC',
        mapper: (Map<String, Object?> row) => WaterRecord(id: row['id'] as int?, date: row['date'] as String, time: row['time'] as String, drinkType: row['drinkType'] as String, drinkName: row['drinkName'] as String, iconPath: row['iconPath'] as String, amount: row['amount'] as int, createdAt: row['createdAt'] as int),
        arguments: [startDate, endDate]);
  }

  @override
  Future<int?> getTotalAmountByDate(String date) async {
    return _queryAdapter.query(
        'SELECT SUM(amount) FROM WaterRecord WHERE date = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [date]);
  }

  @override
  Future<List<WaterRecord>> getAllRecords() async {
    return _queryAdapter.queryList(
        'SELECT * FROM WaterRecord ORDER BY date DESC, createdAt DESC',
        mapper: (Map<String, Object?> row) => WaterRecord(
            id: row['id'] as int?,
            date: row['date'] as String,
            time: row['time'] as String,
            drinkType: row['drinkType'] as String,
            drinkName: row['drinkName'] as String,
            iconPath: row['iconPath'] as String,
            amount: row['amount'] as int,
            createdAt: row['createdAt'] as int));
  }

  @override
  Future<WaterRecord?> getRecordById(int id) async {
    return _queryAdapter.query('SELECT * FROM WaterRecord WHERE id = ?1',
        mapper: (Map<String, Object?> row) => WaterRecord(
            id: row['id'] as int?,
            date: row['date'] as String,
            time: row['time'] as String,
            drinkType: row['drinkType'] as String,
            drinkName: row['drinkName'] as String,
            iconPath: row['iconPath'] as String,
            amount: row['amount'] as int,
            createdAt: row['createdAt'] as int),
        arguments: [id]);
  }

  @override
  Future<void> clearAllRecords() async {
    await _queryAdapter.queryNoReturn('DELETE FROM WaterRecord');
  }

  @override
  Future<int?> getRecordCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM WaterRecord',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getRecordCountByDrinkType(String drinkType) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM WaterRecord WHERE drinkType = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [drinkType]);
  }

  @override
  Future<int> insertRecord(WaterRecord record) {
    return _waterRecordInsertionAdapter.insertAndReturnId(
        record, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRecord(WaterRecord record) async {
    await _waterRecordUpdateAdapter.update(record, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRecord(WaterRecord record) async {
    await _waterRecordDeletionAdapter.delete(record);
  }
}

class _$ReminderSettingsDao extends ReminderSettingsDao {
  _$ReminderSettingsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reminderSettingsInsertionAdapter = InsertionAdapter(
            database,
            'ReminderSettings',
            (ReminderSettings item) => <String, Object?>{
                  'id': item.id,
                  'allReminders': item.allReminders ? 1 : 0,
                  'intervalRemind': item.intervalRemind ? 1 : 0,
                  'reminderInterval': item.reminderInterval,
                  'dndTime': item.dndTime ? 1 : 0,
                  'reminderStartHour': item.reminderStartHour,
                  'reminderStartMinute': item.reminderStartMinute,
                  'reminderEndHour': item.reminderEndHour,
                  'reminderEndMinute': item.reminderEndMinute,
                  'dndLunch': item.dndLunch ? 1 : 0,
                  'lunchStartHour': item.lunchStartHour,
                  'lunchStartMinute': item.lunchStartMinute,
                  'lunchEndHour': item.lunchEndHour,
                  'lunchEndMinute': item.lunchEndMinute,
                  'dndPlan': item.dndPlan ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                }),
        _reminderSettingsUpdateAdapter = UpdateAdapter(
            database,
            'ReminderSettings',
            ['id'],
            (ReminderSettings item) => <String, Object?>{
                  'id': item.id,
                  'allReminders': item.allReminders ? 1 : 0,
                  'intervalRemind': item.intervalRemind ? 1 : 0,
                  'reminderInterval': item.reminderInterval,
                  'dndTime': item.dndTime ? 1 : 0,
                  'reminderStartHour': item.reminderStartHour,
                  'reminderStartMinute': item.reminderStartMinute,
                  'reminderEndHour': item.reminderEndHour,
                  'reminderEndMinute': item.reminderEndMinute,
                  'dndLunch': item.dndLunch ? 1 : 0,
                  'lunchStartHour': item.lunchStartHour,
                  'lunchStartMinute': item.lunchStartMinute,
                  'lunchEndHour': item.lunchEndHour,
                  'lunchEndMinute': item.lunchEndMinute,
                  'dndPlan': item.dndPlan ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                }),
        _reminderSettingsDeletionAdapter = DeletionAdapter(
            database,
            'ReminderSettings',
            ['id'],
            (ReminderSettings item) => <String, Object?>{
                  'id': item.id,
                  'allReminders': item.allReminders ? 1 : 0,
                  'intervalRemind': item.intervalRemind ? 1 : 0,
                  'reminderInterval': item.reminderInterval,
                  'dndTime': item.dndTime ? 1 : 0,
                  'reminderStartHour': item.reminderStartHour,
                  'reminderStartMinute': item.reminderStartMinute,
                  'reminderEndHour': item.reminderEndHour,
                  'reminderEndMinute': item.reminderEndMinute,
                  'dndLunch': item.dndLunch ? 1 : 0,
                  'lunchStartHour': item.lunchStartHour,
                  'lunchStartMinute': item.lunchStartMinute,
                  'lunchEndHour': item.lunchEndHour,
                  'lunchEndMinute': item.lunchEndMinute,
                  'dndPlan': item.dndPlan ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ReminderSettings> _reminderSettingsInsertionAdapter;

  final UpdateAdapter<ReminderSettings> _reminderSettingsUpdateAdapter;

  final DeletionAdapter<ReminderSettings> _reminderSettingsDeletionAdapter;

  @override
  Future<ReminderSettings?> getCurrentSettings() async {
    return _queryAdapter.query(
        'SELECT * FROM ReminderSettings ORDER BY lastUpdated DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => ReminderSettings(
            id: row['id'] as int?,
            allReminders: (row['allReminders'] as int) != 0,
            intervalRemind: (row['intervalRemind'] as int) != 0,
            reminderInterval: row['reminderInterval'] as int,
            dndTime: (row['dndTime'] as int) != 0,
            reminderStartHour: row['reminderStartHour'] as int,
            reminderStartMinute: row['reminderStartMinute'] as int,
            reminderEndHour: row['reminderEndHour'] as int,
            reminderEndMinute: row['reminderEndMinute'] as int,
            dndLunch: (row['dndLunch'] as int) != 0,
            lunchStartHour: row['lunchStartHour'] as int,
            lunchStartMinute: row['lunchStartMinute'] as int,
            lunchEndHour: row['lunchEndHour'] as int,
            lunchEndMinute: row['lunchEndMinute'] as int,
            dndPlan: (row['dndPlan'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<void> updateAllReminders(
    int id,
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET allReminders = ?2, lastUpdated = ?3 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<void> updateIntervalReminder(
    int id,
    bool enabled,
    int interval,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET intervalRemind = ?2, reminderInterval = ?3, lastUpdated = ?4 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, interval, lastUpdated]);
  }

  @override
  Future<void> updateDndTime(
    int id,
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET dndTime = ?2, lastUpdated = ?3 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<void> updateReminderTimeRange(
    int id,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET reminderStartHour = ?2, reminderStartMinute = ?3, reminderEndHour = ?4, reminderEndMinute = ?5, lastUpdated = ?6 WHERE id = ?1',
        arguments: [
          id,
          startHour,
          startMinute,
          endHour,
          endMinute,
          lastUpdated
        ]);
  }

  @override
  Future<void> updateDndLunch(
    int id,
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET dndLunch = ?2, lastUpdated = ?3 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<void> updateLunchTimeRange(
    int id,
    int startHour,
    int startMinute,
    int endHour,
    int endMinute,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET lunchStartHour = ?2, lunchStartMinute = ?3, lunchEndHour = ?4, lunchEndMinute = ?5, lastUpdated = ?6 WHERE id = ?1',
        arguments: [
          id,
          startHour,
          startMinute,
          endHour,
          endMinute,
          lastUpdated
        ]);
  }

  @override
  Future<void> updateDndPlan(
    int id,
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE ReminderSettings SET dndPlan = ?2, lastUpdated = ?3 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<List<ReminderSettings>> getAllSettings() async {
    return _queryAdapter.queryList(
        'SELECT * FROM ReminderSettings ORDER BY lastUpdated DESC',
        mapper: (Map<String, Object?> row) => ReminderSettings(
            id: row['id'] as int?,
            allReminders: (row['allReminders'] as int) != 0,
            intervalRemind: (row['intervalRemind'] as int) != 0,
            reminderInterval: row['reminderInterval'] as int,
            dndTime: (row['dndTime'] as int) != 0,
            reminderStartHour: row['reminderStartHour'] as int,
            reminderStartMinute: row['reminderStartMinute'] as int,
            reminderEndHour: row['reminderEndHour'] as int,
            reminderEndMinute: row['reminderEndMinute'] as int,
            dndLunch: (row['dndLunch'] as int) != 0,
            lunchStartHour: row['lunchStartHour'] as int,
            lunchStartMinute: row['lunchStartMinute'] as int,
            lunchEndHour: row['lunchEndHour'] as int,
            lunchEndMinute: row['lunchEndMinute'] as int,
            dndPlan: (row['dndPlan'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<void> clearAllSettings() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ReminderSettings');
  }

  @override
  Future<int?> getSettingsCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM ReminderSettings',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertSettings(ReminderSettings settings) {
    return _reminderSettingsInsertionAdapter.insertAndReturnId(
        settings, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSettings(ReminderSettings settings) async {
    await _reminderSettingsUpdateAdapter.update(
        settings, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSettings(ReminderSettings settings) async {
    await _reminderSettingsDeletionAdapter.delete(settings);
  }
}

class _$CustomTimedReminderDao extends CustomTimedReminderDao {
  _$CustomTimedReminderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customTimedReminderInsertionAdapter = InsertionAdapter(
            database,
            'CustomTimedReminder',
            (CustomTimedReminder item) => <String, Object?>{
                  'id': item.id,
                  'hour': item.hour,
                  'minute': item.minute,
                  'isAM': item.isAM ? 1 : 0,
                  'isEnabled': item.isEnabled ? 1 : 0,
                  'createdAt': item.createdAt,
                  'lastUpdated': item.lastUpdated
                }),
        _customTimedReminderUpdateAdapter = UpdateAdapter(
            database,
            'CustomTimedReminder',
            ['id'],
            (CustomTimedReminder item) => <String, Object?>{
                  'id': item.id,
                  'hour': item.hour,
                  'minute': item.minute,
                  'isAM': item.isAM ? 1 : 0,
                  'isEnabled': item.isEnabled ? 1 : 0,
                  'createdAt': item.createdAt,
                  'lastUpdated': item.lastUpdated
                }),
        _customTimedReminderDeletionAdapter = DeletionAdapter(
            database,
            'CustomTimedReminder',
            ['id'],
            (CustomTimedReminder item) => <String, Object?>{
                  'id': item.id,
                  'hour': item.hour,
                  'minute': item.minute,
                  'isAM': item.isAM ? 1 : 0,
                  'isEnabled': item.isEnabled ? 1 : 0,
                  'createdAt': item.createdAt,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CustomTimedReminder>
      _customTimedReminderInsertionAdapter;

  final UpdateAdapter<CustomTimedReminder> _customTimedReminderUpdateAdapter;

  final DeletionAdapter<CustomTimedReminder>
      _customTimedReminderDeletionAdapter;

  @override
  Future<void> deleteReminderById(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM CustomTimedReminder WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<List<CustomTimedReminder>> getAllReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM CustomTimedReminder ORDER BY isAM DESC, hour ASC, minute ASC',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(
            id: row['id'] as int?,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            isAM: (row['isAM'] as int) != 0,
            isEnabled: (row['isEnabled'] as int) != 0,
            createdAt: row['createdAt'] as int,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<List<CustomTimedReminder>> getEnabledReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM CustomTimedReminder WHERE isEnabled = 1 ORDER BY isAM DESC, hour ASC, minute ASC',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(
            id: row['id'] as int?,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            isAM: (row['isAM'] as int) != 0,
            isEnabled: (row['isEnabled'] as int) != 0,
            createdAt: row['createdAt'] as int,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<List<CustomTimedReminder>> getDisabledReminders() async {
    return _queryAdapter.queryList(
        'SELECT * FROM CustomTimedReminder WHERE isEnabled = 0 ORDER BY isAM DESC, hour ASC, minute ASC',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(
            id: row['id'] as int?,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            isAM: (row['isAM'] as int) != 0,
            isEnabled: (row['isEnabled'] as int) != 0,
            createdAt: row['createdAt'] as int,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<CustomTimedReminder?> getReminderById(int id) async {
    return _queryAdapter.query(
        'SELECT * FROM CustomTimedReminder WHERE id = ?1',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(
            id: row['id'] as int?,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            isAM: (row['isAM'] as int) != 0,
            isEnabled: (row['isEnabled'] as int) != 0,
            createdAt: row['createdAt'] as int,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [id]);
  }

  @override
  Future<CustomTimedReminder?> getReminderByTime(
    int hour,
    int minute,
    bool isAM,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM CustomTimedReminder WHERE hour = ?1 AND minute = ?2 AND isAM = ?3',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(id: row['id'] as int?, hour: row['hour'] as int, minute: row['minute'] as int, isAM: (row['isAM'] as int) != 0, isEnabled: (row['isEnabled'] as int) != 0, createdAt: row['createdAt'] as int, lastUpdated: row['lastUpdated'] as int),
        arguments: [hour, minute, isAM ? 1 : 0]);
  }

  @override
  Future<void> updateReminderEnabled(
    int id,
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE CustomTimedReminder SET isEnabled = ?2, lastUpdated = ?3 WHERE id = ?1',
        arguments: [id, enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<void> updateAllRemindersEnabled(
    bool enabled,
    int lastUpdated,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE CustomTimedReminder SET isEnabled = ?1, lastUpdated = ?2',
        arguments: [enabled ? 1 : 0, lastUpdated]);
  }

  @override
  Future<int?> getEnabledReminderCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM CustomTimedReminder WHERE isEnabled = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getTotalReminderCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM CustomTimedReminder',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> checkReminderExists(
    int hour,
    int minute,
    bool isAM,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM CustomTimedReminder WHERE hour = ?1 AND minute = ?2 AND isAM = ?3',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [hour, minute, isAM ? 1 : 0]);
  }

  @override
  Future<void> clearAllReminders() async {
    await _queryAdapter.queryNoReturn('DELETE FROM CustomTimedReminder');
  }

  @override
  Future<List<CustomTimedReminder>> getRecentReminders(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CustomTimedReminder ORDER BY createdAt DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(
            id: row['id'] as int?,
            hour: row['hour'] as int,
            minute: row['minute'] as int,
            isAM: (row['isAM'] as int) != 0,
            isEnabled: (row['isEnabled'] as int) != 0,
            createdAt: row['createdAt'] as int,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [limit]);
  }

  @override
  Future<List<CustomTimedReminder>> getRemindersByDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM CustomTimedReminder WHERE createdAt >= ?1 AND createdAt <= ?2 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => CustomTimedReminder(id: row['id'] as int?, hour: row['hour'] as int, minute: row['minute'] as int, isAM: (row['isAM'] as int) != 0, isEnabled: (row['isEnabled'] as int) != 0, createdAt: row['createdAt'] as int, lastUpdated: row['lastUpdated'] as int),
        arguments: [startTimestamp, endTimestamp]);
  }

  @override
  Future<int> insertReminder(CustomTimedReminder reminder) {
    return _customTimedReminderInsertionAdapter.insertAndReturnId(
        reminder, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateReminder(CustomTimedReminder reminder) async {
    await _customTimedReminderUpdateAdapter.update(
        reminder, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReminder(CustomTimedReminder reminder) async {
    await _customTimedReminderDeletionAdapter.delete(reminder);
  }
}
