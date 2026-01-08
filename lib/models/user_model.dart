import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  @JsonKey(name: 'full_name')
  final String? fullName;
  @HiveField(3)
  final String? designation;
  @HiveField(4)
  final String? phone;
  @HiveField(5)
  @JsonKey(name: 'is_active')
  final bool isActive;
  @HiveField(6)
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @HiveField(7)
  @JsonKey(name: 'profile_completed')
  final bool profileCompleted;
  @HiveField(8)
  @JsonKey(name: 'business_setup_completed')
  final bool businessSetupCompleted;
  @HiveField(9)
  @JsonKey(name: 'biometric_enabled')
  final bool biometricEnabled;
  @HiveField(10)
  @JsonKey(name: 'created_at')
  final String createdAt;
  @HiveField(11)
  @JsonKey(name: 'last_login')
  final String? lastLogin;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.designation,
    this.phone,
    required this.isActive,
    required this.isVerified,
    required this.profileCompleted,
    required this.businessSetupCompleted,
    required this.biometricEnabled,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}


