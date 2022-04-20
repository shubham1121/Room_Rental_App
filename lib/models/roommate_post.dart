class RoommatePostData {
  final String roomType;
  final String city;
  final String state;
  final String userId;
  final String date;
  final String ownName;
  final String myName;
  final String tenantContact;
  final String ownAddress;
  final String pinCode;
  final bool isFurnished;
  final bool isVisible;
  final int beds;
  final int orgPrice;
  final int perPersonPrice;
  String postId = "";
  List<dynamic> uplImgLink = [];

  RoommatePostData(
      { required this.perPersonPrice,
        required this.myName,
        required this.date,
        required this.roomType,
        required this.city,
        required this.state,
        required this.userId,
        required this.pinCode,
        required this.beds,
        required this.isFurnished,
        required this.isVisible,
        required this.ownAddress,
        required this.tenantContact,
        required this.ownName,
        required this.orgPrice});
}
