class PostData {
final String roomType;
  final String city;
  final String state;
  final String userId;
  final String date;
  final String ownName;
  final String ownContact;
  final String ownAddress;
  final String pinCode;
  final String roomDescription;
  final bool isFurnished;
  final bool isVisible;
  final int beds;
  final int price;
  final int areaOfRoom;
  final int kitchenCount;
  final int latBathCount;
  String postId = "";
  List<dynamic> uplImgLink = [];

  PostData(
      { required this.roomDescription,
        required this.areaOfRoom,
        required this.latBathCount,
        required this.kitchenCount,
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
        required this.ownContact,
        required this.ownName,
        required this.price});
}
