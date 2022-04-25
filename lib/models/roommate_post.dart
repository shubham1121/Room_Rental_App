class RoommatePostData {
  final String roomType;
  final String city;
  final String state;
  final String userId;
  final String date;
  final String ownName;
  final String postOwnerName;
  final String tenantContact;
  final String ownAddress;
  final String pinCode;
  final String roomDescription;
  final bool isFurnished;
  final bool isVisible;
  final int beds;
  final int orgPrice;
  final int perPersonPrice;
  final int areaOfRoom;
  final int kitchenCount;
  final int latBathCount;
  String postId = "";
  List<dynamic> uplImgLink = [];

  RoommatePostData(
      { required this.perPersonPrice,
        required this.roomDescription,
        required this.postOwnerName,
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
        required this.orgPrice,
        required this.areaOfRoom,
        required this.kitchenCount,
        required this.latBathCount,
      });
}
