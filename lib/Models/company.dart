class Company {
  int? id;
  String? companyLogo;
  String? companyName;
  String? phoneNumber;
  String? companyAddress;

  // Named Parameter Constructor
  Company({
    required this.companyLogo,
    required this.companyName,
    required this.phoneNumber,
    required this.companyAddress});

  // Named constructor that creates company object from JSON data
  // To convert from JSON to dart object
  Company.fromJson(Map<String, dynamic> json){
    id = json["id"];
    companyLogo = json["logo"];
    companyName = json["name"];
    phoneNumber = json["phone"];
    companyAddress = json["address"];
  }

  // To convert from dart to JSON object
  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = {};
    data["logo"] = companyLogo;
    data["name"] = companyName;
    data["phone"] = phoneNumber;
    data["address"] = companyAddress;
    return data;
  }
}