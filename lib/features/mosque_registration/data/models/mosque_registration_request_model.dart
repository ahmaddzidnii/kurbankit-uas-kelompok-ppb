class MosqueRegistrationRequest {
  final String name;
  final String? operationalNumber;
  final String address;
  final String province;
  final String city;
  final String? photoPath; // Local file path for image upload

  MosqueRegistrationRequest({
    required this.name,
    this.operationalNumber,
    required this.address,
    required this.province,
    required this.city,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'operationalNumber': operationalNumber,
      'address': address,
      'province': province,
      'city': city,
    };
  }
}

class VerificationApprovalRequest {
  final String registrationId;
  final String approverNotes; // Optional notes from admin

  VerificationApprovalRequest({
    required this.registrationId,
    this.approverNotes = '',
  });

  Map<String, dynamic> toJson() {
    return {'registrationId': registrationId, 'approverNotes': approverNotes};
  }
}

class VerificationRejectionRequest {
  final String registrationId;
  final String rejectionReason;

  VerificationRejectionRequest({
    required this.registrationId,
    required this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId,
      'rejectionReason': rejectionReason,
    };
  }
}

class MosqueTakedownRequest {
  final String mosqueId;
  final String reason; // Optional reason for takedown

  MosqueTakedownRequest({required this.mosqueId, this.reason = ''});

  Map<String, dynamic> toJson() {
    return {'mosqueId': mosqueId, 'reason': reason};
  }
}
