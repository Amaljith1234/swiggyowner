class BankDetails {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String ifscCode;

  BankDetails({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountName: json["accountName"] ?? "",
      accountNumber: json["accountNumber"] ?? "",
      bankName: json["bankName"] ?? "",
      ifscCode: json["ifscCode"] ?? "",
    );
  }
}

class BankProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final BankDetails bankDetails;

  BankProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bankDetails,
  });

  factory BankProfile.fromJson(Map<String, dynamic> json) {
    return BankProfile(
      id: json["_id"] ?? "",
      name: json["name"] ?? "No Name",
      email: json["email"] ?? "No Email",
      phone: json["phone"].toString(), // Convert phone number to string
      bankDetails: json["bankDetails"] != null
          ? BankDetails.fromJson(json["bankDetails"])
          : BankDetails(
        accountName: "",
        accountNumber: "",
        bankName: "",
        ifscCode: "",
      ),
    );
  }
}

class BankDataResponse {
  final BankProfile bankProfile;

  BankDataResponse({required this.bankProfile});

  factory BankDataResponse.fromJson(Map<String, dynamic> json) {
    return BankDataResponse(
      bankProfile: BankProfile.fromJson(json["data"]["bankDetails"]),
    );
  }
}
