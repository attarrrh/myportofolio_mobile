import 'package:json_annotation/json_annotation.dart';
part 'education.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  const Education({
    this.id,
    required this.institution,
    required this.degree,
    required this.major,
    required this.graduationYear,
  });
  @JsonKey(includeToJson: false)
  final String? id;
  final String institution;
  final String degree;
  final String major;
  final int graduationYear;
  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}
