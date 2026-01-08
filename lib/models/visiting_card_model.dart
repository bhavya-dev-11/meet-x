// lib/models/visiting_card_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'visiting_card_model.g.dart';

@JsonSerializable()
class VisitingCard {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'business_id')
  final String? businessId;
  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? email;
  final String? address;
  @JsonKey(name: 'linkedin_profile')
  final String? linkedinProfile;
  final String? website;
  final String? designation;
  @JsonKey(name: 'processing_status')
  final String processingStatus;
  @JsonKey(name: 'extraction_confidence')
  final double extractionConfidence;
  @JsonKey(name: 'image_path')
  final String imagePath;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'scanned_at')
  final String scannedAt;
  final List<String>? tags;
  final String? notes;

  VisitingCard({
    required this.id,
    required this.userId,
    this.businessId,
    this.companyName,
    this.contactPerson,
    this.phoneNumber,
    this.email,
    this.address,
    this.linkedinProfile,
    this.website,
    this.designation,
    required this.processingStatus,
    required this.extractionConfidence,
    required this.imagePath,
    required this.createdAt,
    required this.scannedAt,
    this.tags,
    this.notes,
  });

  factory VisitingCard.fromJson(Map<String, dynamic> json) =>
      _$VisitingCardFromJson(json);

  Map<String, dynamic> toJson() => _$VisitingCardToJson(this);

  VisitingCard copyWith({
    String? id,
    String? userId,
    String? businessId,
    String? companyName,
    String? contactPerson,
    String? phoneNumber,
    String? email,
    String? address,
    String? linkedinProfile,
    String? website,
    String? designation,
    String? processingStatus,
    double? extractionConfidence,
    String? imagePath,
    String? createdAt,
    String? scannedAt,
    List<String>? tags,
    String? notes,
  }) {
    return VisitingCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      linkedinProfile: linkedinProfile ?? this.linkedinProfile,
      website: website ?? this.website,
      designation: designation ?? this.designation,
      processingStatus: processingStatus ?? this.processingStatus,
      extractionConfidence: extractionConfidence ?? this.extractionConfidence,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      scannedAt: scannedAt ?? this.scannedAt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }
}


