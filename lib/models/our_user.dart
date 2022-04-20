

class OurUser {
  final String name;
  final String contactNumber;
  final String profession;
  final bool isHomeOwner;
  final String email;
  final String belogsTo;
  final String userId ;
  int countRoommatePost = 0;
  OurUser({
    required this.userId,
    required this.belogsTo,
    required this.countRoommatePost,
    required this.name,
    required this.contactNumber,
    required this.profession,
    required this.isHomeOwner,
    required this.email,
  });
}
