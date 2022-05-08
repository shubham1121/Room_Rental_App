import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/location.dart';
import 'package:room_rental_app/models/our_user.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/screens/all_room_post_page.dart';
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/services/location_services.dart';
import 'package:room_rental_app/utils/constants.dart';
import 'package:room_rental_app/utils/customised_app_bar.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/provider_location.dart';
import 'package:room_rental_app/utils/wrapper.dart';

import 'home_page.dart';

class CreatePostPage extends StatefulWidget {
  CreatePostPage({Key? key}) : super(key: key);
  final User? currentUser =
      FirebaseAuth.instance.currentUser; // I just marked this field as final
  // to get current firebase user
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late String userid;
  final LocationServices _locationServices = LocationServices();
  bool uploading = false;
  bool isFurnished = false;
  bool isValid = false;
  bool showRoomPostForm = true;
  late DatabaseService _databaseService;
  final _picker = ImagePicker();
  TextEditingController postRoomType = TextEditingController();
  TextEditingController postAddress = TextEditingController();
  TextEditingController postCity = TextEditingController();
  TextEditingController postState = TextEditingController();
  TextEditingController postPinCode = TextEditingController();
  TextEditingController postBeds = TextEditingController();
  TextEditingController postPrice = TextEditingController();
  TextEditingController postOwnerName = TextEditingController();
  TextEditingController tenantName = TextEditingController();
  TextEditingController postOwnerContact = TextEditingController();
  TextEditingController tenantContact = TextEditingController();
  TextEditingController perPersonPrice = TextEditingController();
  TextEditingController areaOfRoom = TextEditingController();
  TextEditingController kitchenCount = TextEditingController();
  TextEditingController latBathCount = TextEditingController();
  TextEditingController roomDescription = TextEditingController();
  final _postFormKey = GlobalKey<FormState>();
  final List<File> _image = [];
  List<String> uplImgLink = [];
  DateTime now = DateTime.now();
  late DateTime date;
  late myLocation finalLocation;

  @override
  void initState() {
    super.initState();
    userid = widget.currentUser!.uid;
    _databaseService = DatabaseService(userid);
    date = DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _locationServices.determinePosition(context).then((value) {
      finalLocation =
          Provider.of<ProviderLocation>(context, listen: false).getLocation;
    });
  }

  @override
  void dispose() {
    postOwnerContact.dispose();
    postOwnerName.dispose();
    postRoomType.dispose();
    postPrice.dispose();
    postBeds.dispose();
    postAddress.dispose();
    postCity.dispose();
    postState.dispose();
    postPinCode.dispose();
    tenantContact.dispose();
    tenantName.dispose();
    perPersonPrice.dispose();
    areaOfRoom.dispose();
    kitchenCount.dispose();
    latBathCount.dispose();
    roomDescription.dispose();
    super.dispose();
  }

  validatePost() {
    if (_postFormKey.currentState!.validate()) {
      setState(() {
        isValid = true;
      });
    }
  }

  Future chooseImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage == null) {
      return;
    }
    final file = File(pickedImage.path);
    final croppedFile = await cropSquareImage(file);
    if (croppedFile == null) {
      setState(() {});
    } else {
      setState(() {
        _image.add(croppedFile);
      });
    }
  }

  Future<File?> cropSquareImage(File imageFile) async {
    File? croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [CropAspectRatioPreset.square],
      compressQuality: 50,
      androidUiSettings: androidUiSettingsLocked(),
    );
    return croppedFile;
  }

  AndroidUiSettings androidUiSettingsLocked() {
    return const AndroidUiSettings(
      toolbarColor: Colors.indigo,
      toolbarWidgetColor: Colors.white,
    );
  }

  Future<void> uploadRoomFile(String belongsTo) async {
    setState(() {
      debugPrint('we reached here');
      uploading = true;
    });
    PostData post = PostData(
      postOwnerBelongsTo: belongsTo,
      isBooked: false,
      roomDescription: roomDescription.text,
      kitchenCount: int.parse(kitchenCount.text),
      latBathCount: int.parse(latBathCount.text),
      areaOfRoom: int.parse(areaOfRoom.text),
      state: postState.text,
      city: postCity.text,
      pinCode: postPinCode.text,
      userId: userid,
      ownName: postOwnerName.text,
      ownAddress: postAddress.text,
      ownContact: postOwnerContact.text,
      beds: int.parse(postBeds.text),
      price: int.parse(postPrice.text),
      date: date.toLocal().toString(),
      roomType: postRoomType.text,
      isFurnished: isFurnished,
      isVisible: true,
    );
    if (_image.isEmpty) {
      post.uplImgLink.add(
          'https://firebasestorage.googleapis.com/v0/b/getroomapp-1ae21.appspot.com/o/images%2Fno_image_available.jpg?alt=media&token=ec9f783f-9fd3-4944-a244-898860aebf1b');
    } else {
      for (var img in _image) {
        String? result = await _databaseService.uploadImageFirebaseStorage(img);
        if (result == null) {
          debugPrint('Null Result Error');
        }
        post.uplImgLink.add(result!);
      }
    }

    String? uplResult = await _databaseService.addRoomPost(post);
    if (uplResult == "Error") {
      return uploadRoomFile(belongsTo);
    } else {
      uplImgLink.clear();
    }
  }

  Future<void> uploadRoommateFile(String belongsTo) async {
    setState(() {
      debugPrint('we reached here');
      uploading = true;
    });
    RoommatePostData post = RoommatePostData(
      isBooked: false,
      postOwnerBelongsTo: belongsTo,
      roomDescription: roomDescription.text,
      kitchenCount: int.parse(kitchenCount.text),
      latBathCount: int.parse(latBathCount.text),
      areaOfRoom: int.parse(areaOfRoom.text),
      postOwnerName: tenantName.text,
      state: postState.text,
      city: postCity.text,
      pinCode: postPinCode.text,
      userId: userid,
      ownName: postOwnerName.text,
      ownAddress: postAddress.text,
      tenantContact: tenantContact.text,
      beds: int.parse(postBeds.text),
      orgPrice: int.parse(postPrice.text),
      perPersonPrice: int.parse(perPersonPrice.text),
      date: date.toLocal().toString(),
      roomType: postRoomType.text,
      isFurnished: isFurnished,
      isVisible: true,
    );
    if (_image.isEmpty) {
      post.uplImgLink.add(
          'https://firebasestorage.googleapis.com/v0/b/getroomapp-1ae21.appspot.com/o/images%2Fno_image_available.jpg?alt=media&token=97965bee-ff96-4593-9484-a22419dd3703');
    } else {
      for (var img in _image) {
        String? result = await _databaseService.uploadImageFirebaseStorage(img);
        if (result == null) {
          debugPrint('Null Result Error');
        }
        post.uplImgLink.add(result!);
      }
    }

    String? uplResult = await _databaseService.addRoommatePost(post);
    if (uplResult == "Error") {
      return uploadRoommateFile(belongsTo);
    } else {
      uplImgLink.clear();
    }
  }

  void autoFillLocation() {
    postCity.text = finalLocation.city!;
    postState.text = finalLocation.state!;
    postPinCode.text = finalLocation.pinCode!;
  }

  @override
  Widget build(BuildContext context) {
    final List<OurUser?>? currentUserProfile =
        Provider.of<List<OurUser?>?>(context);
    return SafeArea(
      child: Scaffold(
        body: uploading
            ? Loading(true)
            : currentUserProfile == null
                ? Loading(false)
                : currentUserProfile[0] == null
                    ? Loading(false)
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 0),
                          child: Column(
                            children: [
                              currentUserProfile[0]!.isHomeOwner
                                  ? const CustomisedAppBar(
                                      mainHeading: 'Room Posts',
                                      subHeading: 'Create Post For Rooms',
                                      isProfileSection: false,
                                    )
                                  : const CustomisedAppBar(
                                      mainHeading: 'Roommate Posts',
                                      subHeading: 'Create Post For Roommates',
                                      isProfileSection: false,
                                    ),
                              currentUserProfile[0]!.isHomeOwner
                                  ?
                                  //Create Room Posts
                                  Form(
                                      key: _postFormKey,
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Room Type Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: postRoomType,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText:
                                                  'Single Room / Double Room',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'Room Type',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Room Owner Name Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: postOwnerName,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText: 'Owner\'s Name',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'Owner',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Mobile Number Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            keyboardType: TextInputType.number,
                                            controller: postOwnerContact,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText:
                                                  'Owner\'s Contact Number ',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'Contact',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "City Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: postCity,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText: 'Delhi',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'City',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "State Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: postState,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText: 'Madhya Pradesh',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'State',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Address Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: postAddress,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText:
                                                  'House Number, Locality',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'Address',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Room Description Can't be Empty";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize:
                                                  formElementsSize(context),
                                            ),
                                            autofocus: false,
                                            controller: roomDescription,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              focusedBorder:
                                                  const UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                              hintText:
                                                  'Facilities Available with Room',
                                              hintStyle: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                              labelText: 'Room Description',
                                              labelStyle: TextStyle(
                                                color: Colors.indigo,
                                                fontSize:
                                                    formElementsSize(context),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "PinCode Can't be Empty";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: postPinCode,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintText: '474001',
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelText: 'PinCode',
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Number of Beds Can't be Empty";
                                                  } else if (int.parse(value) <=
                                                      0) {
                                                    return "Should have atleast 1 bed";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                controller: postBeds,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintText: '1',
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelText: 'Beds',
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Cant be Empty";
                                                  } else if (value == '0') {
                                                    return 'Can\'t be Zero';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: kitchenCount,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintText: '2',
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelText: 'Kitchen',
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Cant be Empty";
                                                  } else if (value == '0') {
                                                    return 'Can\'t be Zero';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: latBathCount,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintText: '2',
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelText: 'Washroom',
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Price Can't be Empty";
                                                  } else if (int.parse(value) <=
                                                      0) {
                                                    return "Price should be Greater than 0";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                controller: postPrice,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  prefixText: "\u20B9",
                                                  suffixText: "/Month",
                                                  hintText: '4500',
                                                  labelText: 'Price',
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              TextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Cant be Empty";
                                                  } else if (value == '0') {
                                                    return 'Can\'t be Zero';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                style: TextStyle(
                                                  fontSize:
                                                      formElementsSize(context),
                                                ),
                                                autofocus: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: areaOfRoom,
                                                decoration: InputDecoration(
                                                  constraints:
                                                      BoxConstraints.tightFor(
                                                          width: displayWidth(
                                                                  context) *
                                                              0.4),
                                                  enabledBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  focusedBorder:
                                                      const UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.indigo),
                                                  ),
                                                  hintText: '500',
                                                  suffixText: "Sq. ft",
                                                  hintStyle: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                  labelText: 'Room Area',
                                                  labelStyle: TextStyle(
                                                    color: Colors.indigo,
                                                    fontSize: formElementsSize(
                                                        context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Is Room Furnished?',
                                                style: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                    color: isFurnished
                                                        ? Colors.indigo
                                                        : Colors.grey.shade600),
                                              ),
                                              Switch(
                                                value: isFurnished,
                                                onChanged: (value) =>
                                                    setState(() {
                                                  isFurnished = !isFurnished;
                                                }),
                                              ),
                                            ],
                                          ),
                                          _image.isEmpty
                                              ? const SizedBox(
                                                  height: 0,
                                                  width: 0,
                                                )
                                              : GridView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: _image.length,
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                  ),
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              3),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                          image: FileImage(
                                                              _image[index]),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: darkBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    chooseImage();
                                                  });
                                                },
                                                child: Text(
                                                  'Add Images',
                                                  style: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: darkBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    autoFillLocation();
                                                  });
                                                },
                                                child: Text(
                                                  'Fill Location',
                                                  style: TextStyle(
                                                    fontSize: formElementsSize(
                                                        context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: darkBlueColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                validatePost();
                                                if (isValid) {
                                                  uploadRoomFile(
                                                          currentUserProfile[0]!
                                                              .belogsTo)
                                                      .whenComplete(
                                                    () => Navigator
                                                        .pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const Wrapper()),
                                                    ),
                                                  );
                                                }
                                              });
                                            },
                                            child: Text(
                                              'Upload',
                                              style: TextStyle(
                                                fontSize:
                                                    formElementsSize(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : currentUserProfile.isEmpty
                                      ? const Text('Nothing to Show')
                                      : currentUserProfile[0]!
                                                  .countRoommatePost ==
                                              0
                                          ?
                                          //Create Roommate Posts
                                          Form(
                                              key: _postFormKey,
                                              child: Column(
                                                children: [
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Room Type Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: postRoomType,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText:
                                                          'Single Room / Double Room',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'Room Type',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Room Owner Name Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: postOwnerName,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText: 'Owner\'s Name',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'Owner',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Your Name Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: tenantName,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText: 'Alex',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'Your Name',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  currentUserProfile[0]!
                                                          .isHomeOwner
                                                      ? TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "Mobile Number Can't be Empty";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          autofocus: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              postOwnerContact,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            hintText:
                                                                'Owner\'s Contact Number ',
                                                            hintStyle:
                                                                TextStyle(
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                            ),
                                                            labelText:
                                                                'Contact',
                                                            labelStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.indigo,
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        )
                                                      : TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "Mobile Number Can't be Empty";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          autofocus: false,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              tenantContact,
                                                          decoration:
                                                              InputDecoration(
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            hintText:
                                                                'Your Contact Number',
                                                            hintStyle:
                                                                TextStyle(
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                            ),
                                                            labelText:
                                                                'Contact',
                                                            labelStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.indigo,
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "City Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: postCity,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText: 'Delhi',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'City',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "State Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: postState,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText:
                                                          'Madhya Pradesh',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'State',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Address Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: postAddress,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText:
                                                          'House Number, Locality',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText: 'Address',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Room Description Can't be Empty";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: TextStyle(
                                                      fontSize:
                                                          formElementsSize(
                                                              context),
                                                    ),
                                                    autofocus: false,
                                                    controller: roomDescription,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      focusedBorder:
                                                          const UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.indigo),
                                                      ),
                                                      hintText:
                                                          'Facilities Available with Room',
                                                      hintStyle: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                      labelText:
                                                          'Room Description',
                                                      labelStyle: TextStyle(
                                                        color: Colors.indigo,
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "PinCode Can't be Empty";
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller: postPinCode,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintText: '474001',
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelText: 'PinCode',
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Number of Beds Can't be Empty";
                                                          } else if (int.parse(
                                                                  value) <=
                                                              0) {
                                                            return "Should have atleast 1 bed";
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        controller: postBeds,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintText: '1',
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelText: 'Beds',
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Cant be Empty";
                                                          } else if (value ==
                                                              '0') {
                                                            return 'Can\'t be Zero';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            kitchenCount,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintText: '2',
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelText: 'Kitchen',
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Cant be Empty";
                                                          } else if (value ==
                                                              '0') {
                                                            return 'Can\'t be Zero';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller:
                                                            latBathCount,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintText: '2',
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelText: 'Washroom',
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Price Can't be Empty";
                                                          } else if (int.parse(
                                                                  value) <=
                                                              0) {
                                                            return "Price should be Greater than 0";
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        controller: postPrice,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          prefixText: "\u20B9",
                                                          suffixText: "/Month",
                                                          hintText: '4500',
                                                          labelText: 'Price',
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return "Cant be Empty";
                                                          } else if (value ==
                                                              '0') {
                                                            return 'Can\'t be Zero';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        style: TextStyle(
                                                          fontSize:
                                                              formElementsSize(
                                                                  context),
                                                        ),
                                                        autofocus: false,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        controller: areaOfRoom,
                                                        decoration:
                                                            InputDecoration(
                                                          constraints: BoxConstraints
                                                              .tightFor(
                                                                  width: displayWidth(
                                                                          context) *
                                                                      0.4),
                                                          enabledBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          focusedBorder:
                                                              const UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .indigo),
                                                          ),
                                                          hintText: '500',
                                                          suffixText: "Sq. ft",
                                                          hintStyle: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          labelText:
                                                              'Room Area',
                                                          labelStyle: TextStyle(
                                                            color:
                                                                Colors.indigo,
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  currentUserProfile[0]!
                                                          .isHomeOwner
                                                      ? const SizedBox(
                                                          height: 0,
                                                          width: 0,
                                                        )
                                                      : TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return "Price Can't be Empty";
                                                            } else if (int.parse(
                                                                    value) <=
                                                                0) {
                                                              return "Price should be Greater than 0";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                          autofocus: false,
                                                          controller:
                                                              perPersonPrice,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            prefixText:
                                                                "\u20B9",
                                                            suffixText:
                                                                "/Person",
                                                            hintText: '4500',
                                                            labelText:
                                                                'Per Person Price',
                                                            enabledBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            focusedBorder:
                                                                const UnderlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                            hintStyle:
                                                                TextStyle(
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                            ),
                                                            labelStyle:
                                                                TextStyle(
                                                              color:
                                                                  Colors.indigo,
                                                              fontSize:
                                                                  formElementsSize(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Are you a Home Owner?',
                                                        style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                            color: isFurnished
                                                                ? Colors.indigo
                                                                : Colors.grey
                                                                    .shade600),
                                                      ),
                                                      Switch(
                                                        value: isFurnished,
                                                        onChanged: (value) =>
                                                            setState(() {
                                                          isFurnished =
                                                              !isFurnished;
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                  _image.isEmpty
                                                      ? const SizedBox(
                                                          height: 0,
                                                          width: 0,
                                                        )
                                                      : GridView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemCount:
                                                              _image.length,
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                          ),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                image:
                                                                    DecorationImage(
                                                                  image: FileImage(
                                                                      _image[
                                                                          index]),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary:
                                                              darkBlueColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            chooseImage();
                                                          });
                                                        },
                                                        child: Text(
                                                          'Add Images',
                                                          style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary:
                                                              darkBlueColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            autoFillLocation();
                                                          });
                                                        },
                                                        child: Text(
                                                          'Fill Location',
                                                          style: TextStyle(
                                                            fontSize:
                                                                formElementsSize(
                                                                    context),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: darkBlueColor,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        validatePost();
                                                        if (isValid) {
                                                          _databaseService.updateUserData(
                                                              currentUserProfile[
                                                                      0]!
                                                                  .name,
                                                              currentUserProfile[
                                                                      0]!
                                                                  .contactNumber,
                                                              currentUserProfile[
                                                                      0]!
                                                                  .profession,
                                                              currentUserProfile[
                                                                      0]!
                                                                  .isHomeOwner,
                                                              currentUserProfile[
                                                                      0]!
                                                                  .email,
                                                              1,
                                                              currentUserProfile[
                                                                      0]!
                                                                  .belogsTo);
                                                          uploadRoommateFile(
                                                                  currentUserProfile[
                                                                          0]!
                                                                      .belogsTo)
                                                              .whenComplete(
                                                            () => Navigator
                                                                .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          const Wrapper()),
                                                            ),
                                                          );
                                                        }
                                                      });
                                                    },
                                                    child: Text(
                                                      'Upload',
                                                      style: TextStyle(
                                                        fontSize:
                                                            formElementsSize(
                                                                context),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const Text(
                                              'You can create only one Roommate Post!'),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}
