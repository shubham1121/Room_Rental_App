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
  final bool isFurnished;
  final bool isVisible;
  final int beds;
  final int price;
  String postId = "";
  List<dynamic> uplImgLink = [];

  PostData(
      { required this.date,
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
