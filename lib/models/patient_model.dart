class Patient {
  final String id;
  final String name;
  final String gender;
  final int age;
  final String bloodGroup;
  final Map<String, String> vitals;
  final List<String> history;
  final List<Map<String, dynamic>> appointments;
  final String prescribedDiet;
  final String emergencyContact;

  Patient({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.bloodGroup,
    required this.vitals,
    required this.history,
    required this.appointments,
    required this.prescribedDiet,
    required this.emergencyContact,
  });
}