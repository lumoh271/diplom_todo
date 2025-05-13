// models/user.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String password;

  @HiveField(3)
  String? name;

  User({
    required this.id,
    required this.username,
    required this.password,
    this.name,
  });

  factory User.create({
    required String username,
    required String password,
    String? name,
  }) => User(
    id: const Uuid().v1(),
    username: username,
    password: password,
    name: name,
  );
}