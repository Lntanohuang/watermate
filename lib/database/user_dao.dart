import 'package:floor/floor.dart';
import 'package:watermate/models/user.dart';

@dao
abstract class UserDao {
  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);

  @Query('SELECT * FROM User WHERE id = 1')
  Future<User?> getUser();

  @Query('UPDATE User SET weight = :weight WHERE id = 1')
  Future<void> updateUserWeight(double weight);

  @Query('UPDATE User SET targetWaterIntake = :targetWaterIntake WHERE id = 1')
  Future<void> updateTargetWaterIntake(int targetWaterIntake);

  @Query('UPDATE User SET checkInDays = :checkInDays WHERE id = 1')
  Future<void> updateCheckInDays(int checkInDays);

  @Query('UPDATE User SET exerciseVolume = :exerciseVolume WHERE id = 1')
  Future<void> updateExerciseVolume(String exerciseVolume);

  @Query('UPDATE User SET age = :age WHERE id = 1')
  Future<void> updateUserAge(int age);

  @Query('UPDATE User SET gender = :gender WHERE id = 1')
  Future<void> updateUserGender(String gender);

  @Query(
    'UPDATE User SET reminderStartTime = :startTime, reminderEndTime = :endTime WHERE id = 1',
  )
  Future<void> updateReminderTime(int startTime, int endTime);
}
