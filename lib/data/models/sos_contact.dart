class SOSContact {
  final String name;
  final String phone;
  final String messageTemplate;

  const SOSContact({
    required this.name,
    required this.phone,
    required this.messageTemplate,
  });

  factory SOSContact.fromJson(Map<String, dynamic> json) {
    return SOSContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      messageTemplate: json['messageTemplate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'messageTemplate': messageTemplate,
    };
  }
}
