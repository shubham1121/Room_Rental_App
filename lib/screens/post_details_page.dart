import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class PostDetails extends StatefulWidget {

  final PostData? postData;
  final RoommatePostData? roommatePostData;
   PostDetails(
      {Key? key, required this.postData, required this.roommatePostData})
      : super(key: key);
  final User? currentUser =
      FirebaseAuth.instance.currentUser;

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  late String userid;
  var _razorpay = Razorpay();
  late DatabaseService _databaseService;

  @override
  void initState() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    userid = widget.currentUser!.uid;
    _databaseService = DatabaseService(userid);
    super.initState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if(widget.postData==null){
      debugPrint('Payment Done');
      Fluttertoast.showToast(
          msg: 'Payment Success',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green);
      await _databaseService.updateRoommatePostData(widget.roommatePostData!.postId).whenComplete(() => Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) =>
          const Wrapper()),));
    }
    else
      {
        debugPrint('Payment Done');
        Fluttertoast.showToast(
            msg: 'Payment Success',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green);
        await _databaseService.updateRoomPostData(widget.postData!.postId).whenComplete(() => Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) =>
            const Wrapper()),));
      }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        'Payment Error : ${response.code.toString()} ${response.message.toString()}');
    Fluttertoast.showToast(
        msg: 'Payment Cancelled ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet ${response.walletName}');
    Fluttertoast.showToast(
        msg: 'Payment Success By ${response.walletName} ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green);
  }

  Future<String> generateOrderId(String key, String secret, int amount) async {
    var authN = 'Basic ' + base64Encode(utf8.encode('$key:$secret'));

    var headers = {
      'content-type': 'application/json',
      'Authorization': authN,
    };

    var data =
        '{ "amount": $amount, "currency": "INR", "receipt": "receipt#R1", "payment_capture": 1 }'; // as per my experience the receipt doesn't play any role in helping you generate a certain pattern in your Order ID!!

    var res = await http.post(Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: headers, body: data);
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }
    debugPrint('ORDER ID response => ${res.body}');
    return json.decode(res.body)['id'].toString();
  }

  void openCheckOut(String orderId, String name, int price, String roomType) {
    var options = {
      'key': 'rzp_test_aYUsHRU8Tw0TUR',
      'amount': price.toString(), //in the smallest currency sub-unit.
      'currency': 'INR',
      'name': name,
      'order_id': orderId, // Generate order_id using Orders API
      'description': 'Payment for Booking of ' + roomType + ' for First Month',
      'timeout': 300, // in seconds
      // 'prefill': {
      //   'contact': '9123456789',
      //   'email': 'gaurav.kumar@example.com'
      // }
    };
    _razorpay.open(options);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: widget.postData == null
            ?
            //Roommate Post Details
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomisedAppBar(
                          mainHeading: widget.roommatePostData!.roomType,
                          subHeading: widget.roommatePostData!.city + ', India',
                          isProfileSection: false),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.shower,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Washroom',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.roommatePostData!.latBathCount
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      CupertinoIcons.bed_double_fill,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Beds',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.roommatePostData!.latBathCount
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Kitchen',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.roommatePostData!.latBathCount
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: darkBlueColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: displayWidth(context) * 0.07,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  child: Text(
                                    widget.roommatePostData!.roomDescription,
                                    style: TextStyle(
                                      color: darkGreyColor,
                                      fontSize: displayWidth(context) * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Room Price',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '\u20B9' +
                                                    widget.roommatePostData!
                                                        .orgPrice
                                                        .toString() +
                                                    ' / Month',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Per Person Price',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '\u20B9' +
                                                    widget.roommatePostData!
                                                        .perPersonPrice
                                                        .toString() +
                                                    ' / Month',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        String orderId = await generateOrderId(
                                            'rzp_test_aYUsHRU8Tw0TUR',
                                            'bei0tYPuwzvqpxo16LIFPL0w',
                                            (widget.roommatePostData!.orgPrice * 100));
                                        setState(() {
                                          openCheckOut(
                                              orderId,
                                              widget.roommatePostData!.ownName,
                                              ((widget.roommatePostData!.orgPrice) * 100),
                                              widget.roommatePostData!.roomType);
                                        });
                                      },
                                      child: widget.roommatePostData!.isBooked ? Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Pay Now',
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '\u20B9' +
                                                    widget.roommatePostData!
                                                        .orgPrice
                                                        .toString(),
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                      ) : Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Room',
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Already Booked',
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Images',
                                    style: TextStyle(
                                      fontSize: displayWidth(context) * 0.07,
                                      fontWeight: FontWeight.w700,
                                      color: darkBlueColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 10),
                                    child: Expanded(
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: widget.roommatePostData!
                                            .uplImgLink.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  openRoomDetails(index);
                                                });
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl: widget
                                                      .roommatePostData!
                                                      .uplImgLink[index],
                                                  placeholder: (context, url) =>
                                                      smallLoadingIndicatorForImages(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: darkBlueColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address',
                                        style: TextStyle(
                                          fontSize:
                                              displayWidth(context) * 0.07,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 10),
                                        child: Text(
                                          widget.roommatePostData!.ownAddress +
                                              ', ' +
                                              widget.roommatePostData!.city +
                                              widget.roommatePostData!.pinCode +
                                              ', ' +
                                              widget.roommatePostData!.state,
                                          style: TextStyle(
                                            color: darkGreyColor,
                                            fontSize:
                                                displayWidth(context) * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Post Owner Details',
                                        style: TextStyle(
                                          fontSize:
                                              displayWidth(context) * 0.07,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Name - ' +
                                              widget.roommatePostData!.ownName,
                                          style: TextStyle(
                                            color: darkGreyColor,
                                            fontSize:
                                                displayWidth(context) * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Belongs To - ' +
                                            widget.roommatePostData!
                                                .postOwnerBelongsTo,
                                        style: TextStyle(
                                          color: darkGreyColor,
                                          fontSize:
                                              displayWidth(context) * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Mob No. - ' +
                                            widget.roommatePostData!
                                                .tenantContact,
                                        style: TextStyle(
                                          color: darkGreyColor,
                                          fontSize:
                                              displayWidth(context) * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _makePhoneCall(widget
                                                  .roommatePostData!
                                                  .tenantContact);
                                            });
                                          },
                                          label: Text(
                                            'Contact',
                                            style: TextStyle(
                                              fontSize:
                                                  displayWidth(context) * 0.055,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          icon: const Icon(Icons.call),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            :
            //Room Post Details
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomisedAppBar(
                          mainHeading: widget.postData!.roomType,
                          subHeading: widget.postData!.city + ', India',
                          isProfileSection: false),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.shower,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Washroom',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.postData!.latBathCount.toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      CupertinoIcons.bed_double_fill,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Beds',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.postData!.latBathCount.toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.white,
                                      size: displayWidth(context) * 0.06,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: darkBlueColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(
                                  width: displayWidth(context) * 0.02,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Kitchen',
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.04,
                                        fontWeight: FontWeight.w500,
                                        color: darkGreyColor,
                                      ),
                                    ),
                                    Text(
                                      widget.postData!.latBathCount.toString(),
                                      style: TextStyle(
                                        fontSize: displayWidth(context) * 0.05,
                                        color: darkBlueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: darkBlueColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: displayWidth(context) * 0.07,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 10),
                                  child: Text(
                                    widget.postData!.roomDescription,
                                    style: TextStyle(
                                      color: darkGreyColor,
                                      fontSize: displayWidth(context) * 0.04,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Room Price',
                                              style: TextStyle(
                                                fontSize:
                                                    displayWidth(context) *
                                                        0.03,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              '\u20B9' +
                                                  widget.postData!.price
                                                      .toString() +
                                                  ' / Month',
                                              style: TextStyle(
                                                fontSize:
                                                    displayWidth(context) *
                                                        0.04,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      elevation: 10,
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: widget.postData!.isBooked ? () {} : () async {
                                        String orderId = await generateOrderId(
                                            'rzp_test_aYUsHRU8Tw0TUR',
                                            'bei0tYPuwzvqpxo16LIFPL0w',
                                            (widget.postData!.price * 100));
                                        setState(() {
                                          openCheckOut(
                                              orderId,
                                              widget.postData!.ownName,
                                              ((widget.postData!.price) * 100),
                                              widget.postData!.roomType);
                                        });
                                      },
                                      child: widget.postData!.isBooked ? Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Room',
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Already Booked',
                                                style: TextStyle(
                                                  fontSize:
                                                  displayWidth(context) *
                                                      0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ),
                                      ) : Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Pay Now',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.03,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '\u20B9' +
                                                    widget.postData!.price
                                                        .toString() +
                                                    ' / Month',
                                                style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.04,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        elevation: 10,
                                        color: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Images',
                                    style: TextStyle(
                                      fontSize: displayWidth(context) * 0.07,
                                      fontWeight: FontWeight.w700,
                                      color: darkBlueColor,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 10),
                                    child: GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          widget.postData!.uplImgLink.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      ),
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                openRoomDetails(index);
                                              });
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl: widget.postData!
                                                    .uplImgLink[index],
                                                placeholder: (context, url) =>
                                                    smallLoadingIndicatorForImages(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        child: Card(
                          color: darkBlueColor,
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Address',
                                        style: TextStyle(
                                          fontSize:
                                              displayWidth(context) * 0.07,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 10),
                                        child: Text(
                                          widget.postData!.ownAddress +
                                              ', ' +
                                              widget.postData!.city +
                                              widget.postData!.pinCode +
                                              ', ' +
                                              widget.postData!.state,
                                          style: TextStyle(
                                            color: darkGreyColor,
                                            fontSize:
                                                displayWidth(context) * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Post Owner Details',
                                        style: TextStyle(
                                          fontSize:
                                              displayWidth(context) * 0.07,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          'Name - ' + widget.postData!.ownName,
                                          style: TextStyle(
                                            color: darkGreyColor,
                                            fontSize:
                                                displayWidth(context) * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Belongs To - ' +
                                            widget.postData!.postOwnerBelongsTo,
                                        style: TextStyle(
                                          color: darkGreyColor,
                                          fontSize:
                                              displayWidth(context) * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Mob No. - ' +
                                            widget.postData!.ownContact,
                                        style: TextStyle(
                                          color: darkGreyColor,
                                          fontSize:
                                              displayWidth(context) * 0.04,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _makePhoneCall(
                                                  widget.postData!.ownContact);
                                            });
                                          },
                                          label: Text(
                                            'Contact',
                                            style: TextStyle(
                                              fontSize:
                                                  displayWidth(context) * 0.055,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          icon: const Icon(Icons.call),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    ));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrl(Uri(scheme: 'tel', path: '123'))) {
      debugPrint('Tried');
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void openRoomDetails(int index) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GalleryPage(
          urlImages: widget.postData!.uplImgLink,
          index: index,
        ),
      ));
  void openRoommateDetails(int index) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GalleryPage(
          urlImages: widget.roommatePostData!.uplImgLink,
          index: index,
        ),
      ));
}

class GalleryPage extends StatefulWidget {
  final PageController pageController;
  final List<dynamic> urlImages;
  final int index;
  GalleryPage({Key? key, required this.urlImages, this.index = 0})
      : pageController = PageController(initialPage: index),
        super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late int index = widget.index;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const CustomisedAppBar(
                mainHeading: 'Images',
                subHeading: 'Zoom In / Zoom Out for More Details',
                isProfileSection: false),
            Expanded(
              child: PhotoViewGallery.builder(
                backgroundDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
                pageController: widget.pageController,
                itemCount: widget.urlImages.length,
                builder: (context, index) {
                  final urlImage = widget.urlImages[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(urlImage),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.contained * 2,
                  );
                },
                loadingBuilder: (context, event) => Center(
                  child: smallLoadingIndicatorForImages(),
                ),
                onPageChanged: (index) => setState(() => this.index = index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
