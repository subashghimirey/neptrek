class TimsBooking {
  final int trekId;
  final String transactionId;
  final String image;
  final String fullName;
  final String nationality;
  final String passportNumber;
  final String gender;
  final String dateOfBirth;
  final String trekkerArea;
  final String route;
  final String entryDate;
  final String exitDate;
  final String nepalContactName;
  final String nepalOrganization;
  final String nepalDesignation;
  final String nepalMobile;
  final String nepalOfficeNumber;
  final String nepalAddress;
  final String homeContactName;
  final String homeCity;
  final String homeMobile;
  final String homeOfficeNumber;
  final String homeAddress;
  final String transitPassCost;

  TimsBooking({
    required this.trekId,
    required this.transactionId,
    required this.image,
    required this.fullName,
    required this.nationality,
    required this.passportNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.trekkerArea,
    required this.route,
    required this.entryDate,
    required this.exitDate,
    required this.nepalContactName,
    required this.nepalOrganization,
    required this.nepalDesignation,
    required this.nepalMobile,
    required this.nepalOfficeNumber,
    required this.nepalAddress,
    required this.homeContactName,
    required this.homeCity,
    required this.homeMobile,
    required this.homeOfficeNumber,
    required this.homeAddress,
    required this.transitPassCost,
  });

  Map<String, dynamic> toJson() {
    return {
      'trek_id': trekId,
      'transaction_id': transactionId,
      'image': image,
      'full_name': fullName,
      'nationality': nationality,
      'passport_number': passportNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'trekker_area': trekkerArea,
      'route': route,
      'entry_date': entryDate,
      'exit_date': exitDate,
      'nepal_contact_name': nepalContactName,
      'nepal_organization': nepalOrganization,
      'nepal_designation': nepalDesignation,
      'nepal_mobile': nepalMobile,
      'nepal_office_number': nepalOfficeNumber,
      'nepal_address': nepalAddress,
      'home_contact_name': homeContactName,
      'home_city': homeCity,
      'home_mobile': homeMobile,
      'home_office_number': homeOfficeNumber,
      'home_address': homeAddress,
      'transit_pass_cost': transitPassCost,
    };
  }

  factory TimsBooking.fromJson(Map<String, dynamic> json) {
    return TimsBooking(
      trekId: json['trek_id'],
      transactionId: json['transaction_id'],
      image: json['image'],
      fullName: json['full_name'],
      nationality: json['nationality'],
      passportNumber: json['passport_number'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      trekkerArea: json['trekker_area'],
      route: json['route'],
      entryDate: json['entry_date'],
      exitDate: json['exit_date'],
      nepalContactName: json['nepal_contact_name'],
      nepalOrganization: json['nepal_organization'],
      nepalDesignation: json['nepal_designation'],
      nepalMobile: json['nepal_mobile'],
      nepalOfficeNumber: json['nepal_office_number'],
      nepalAddress: json['nepal_address'],
      homeContactName: json['home_contact_name'],
      homeCity: json['home_city'],
      homeMobile: json['home_mobile'],
      homeOfficeNumber: json['home_office_number'],
      homeAddress: json['home_address'],
      transitPassCost: json['transit_pass_cost'],
    );
  }
}
