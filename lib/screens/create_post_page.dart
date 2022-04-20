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
import 'package:room_rental_app/services/database_firestore.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/services/location_services.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';
import 'package:room_rental_app/utils/provider_location.dart';

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
  final AuthService _authService = AuthService();
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

  Future<void> uploadRoomFile() async {
    setState(() {
      debugPrint('we reached here');
      uploading = true;
    });
    PostData post = PostData(
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
          'https://firebasestorage.googleapis.com/v0/b/getroomapp-1ae21.appspot.com/o/images%2Fno_image_available.jpg?alt=media&token=46b5061b-9822-4012-9ea1-9a6f726b2c8e');
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
      return uploadRoomFile();
    } else {
      uplImgLink.clear();
    }
  }

  Future<void> uploadRoommateFile() async {
    setState(() {
      debugPrint('we reached here');
      uploading = true;
    });
    RoommatePostData post = RoommatePostData(
      myName: tenantName.text,
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
          'https://firebasestorage.googleapis.com/v0/b/getroomapp-1ae21.appspot.com/o/images%2Fno_image_available.jpg?alt=media&token=46b5061b-9822-4012-9ea1-9a6f726b2c8e');
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
      return uploadRoomFile();
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Create Post'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _authService.logout();
                });
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: getOrientation(context) == Orientation.portrait
            ? uploading
                ? Loading(true)
                : currentUserProfile == null ? Loading(false) :
        currentUserProfile[0] == null ? Loading(false) : ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        child: Column(
                          children: [
                            !currentUserProfile[0]!.isHomeOwner ? const SizedBox(
                              height: 0,
                              width: 0,
                            )  : const Text(
                              'Room Post',
                              style: TextStyle(
                                color:Colors.indigo,
                              ),
                            ),
                            currentUserProfile[0]!.isHomeOwner ? const SizedBox(
                              height: 0,
                              width: 0,
                            )  : const Text(
                              'Roommate Post',
                              style: TextStyle(
                                color: Colors.indigo,
                              ),
                            ),
                            currentUserProfile[0]!.isHomeOwner ?
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postRoomType,
                                          decoration: const InputDecoration(
                                            hintText:
                                                'Single Room / Double Room',
                                            labelText: 'Room Type',
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postOwnerName,
                                          decoration: const InputDecoration(
                                            hintText: 'Owner\'s Name',
                                            labelText: 'Owner',
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          keyboardType: TextInputType.number,
                                          controller: postOwnerContact,
                                          decoration: const InputDecoration(
                                            hintText: 'Owner\'s Contact Number',
                                            labelText: 'Contact',
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postCity,
                                          decoration: const InputDecoration(
                                            hintText: 'Delhi',
                                            labelText: 'City',
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postState,
                                          decoration: const InputDecoration(
                                            hintText: 'Goa',
                                            labelText: 'State',
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
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postAddress,
                                          decoration: const InputDecoration(
                                            hintText: 'HouseNo, locality',
                                            labelText: 'Address',
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
                                                    displayWidth(context) *
                                                        0.045,
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
                                                hintText: '474001',
                                                labelText: 'Pincode',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postBeds,
                                              decoration: InputDecoration(
                                                constraints:
                                                    BoxConstraints.tightFor(
                                                        width: displayWidth(
                                                                context) *
                                                            0.4),
                                                hintText: '2',
                                                labelText: 'Beds',
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Price Can't be Empty";
                                            } else if (int.parse(value) <= 0) {
                                              return "Price should be Greater than 0";
                                            } else {
                                              return null;
                                            }
                                          },
                                          style: TextStyle(
                                            fontSize:
                                                displayWidth(context) * 0.045,
                                          ),
                                          autofocus: false,
                                          controller: postPrice,
                                          decoration: const InputDecoration(
                                            prefixText: "\u20B9",
                                            suffixText: "/Month",
                                            hintText: '4500',
                                            labelText: 'Price',
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Room Furnished',
                                              style: TextStyle(
                                                  fontSize:
                                                      displayWidth(context) *
                                                          0.045,
                                                  color: Colors.grey.shade600),
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
                                                scrollDirection: Axis.vertical,
                                                itemCount: _image.length,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                ),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                              onPressed: () {
                                                setState(() {
                                                  chooseImage();
                                                });
                                              },
                                              child: const Text('Add Images'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  autoFillLocation();
                                                });
                                              },
                                              child:
                                                  const Text('Fill Location'),
                                            ),
                                          ],
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              validatePost();
                                              if (isValid) {
                                                uploadRoomFile().whenComplete(
                                                  () =>
                                                      Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const HomePage()),
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                          child: const Text('Upload'),
                                        ),
                                      ],
                                    ),
                                  )
                                : currentUserProfile.isEmpty ? const Text('Nothing to Show') : currentUserProfile[0]!.countRoommatePost == 0
                                    ? Form(
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postRoomType,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    'Single Room / Double Room',
                                                labelText: 'Room Type',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postOwnerName,
                                              decoration: const InputDecoration(
                                                hintText: 'Owner\'s Name',
                                                labelText: 'Owner',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: tenantName,
                                              decoration: const InputDecoration(
                                                hintText: 'Your Name',
                                                labelText: 'Your Name',
                                              ),
                                            ),
                                            currentUserProfile[0]!.isHomeOwner
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
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.045,
                                                    ),
                                                    autofocus: false,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: tenantContact,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Owner\'s Contact Number',
                                                      labelText: 'Contact',
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
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.045,
                                                    ),
                                                    autofocus: false,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: tenantContact,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText:
                                                          'Your Contact Number',
                                                      labelText: 'Contact',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postCity,
                                              decoration: const InputDecoration(
                                                hintText: 'Delhi',
                                                labelText: 'City',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postState,
                                              decoration: const InputDecoration(
                                                hintText: 'Goa',
                                                labelText: 'State',
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postAddress,
                                              decoration: const InputDecoration(
                                                hintText: 'HouseNo, locality',
                                                labelText: 'Address',
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
                                                        displayWidth(context) *
                                                            0.045,
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
                                                    hintText: '474001',
                                                    labelText: 'Pincode',
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
                                                        displayWidth(context) *
                                                            0.045,
                                                  ),
                                                  autofocus: false,
                                                  controller: postBeds,
                                                  decoration: InputDecoration(
                                                    constraints:
                                                        BoxConstraints.tightFor(
                                                            width: displayWidth(
                                                                    context) *
                                                                0.4),
                                                    hintText: '2',
                                                    labelText: 'Beds',
                                                    suffixText: '/Room'
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                                    displayWidth(context) *
                                                        0.045,
                                              ),
                                              autofocus: false,
                                              controller: postPrice,
                                              decoration: const InputDecoration(
                                                prefixText: "\u20B9",
                                                suffixText: "/Month",
                                                hintText: '4500',
                                                labelText: 'Price',
                                              ),
                                            ),
                                            currentUserProfile[0]!.isHomeOwner
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
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.045,
                                                    ),
                                                    autofocus: false,
                                                    controller: perPersonPrice,
                                                    decoration:
                                                        const InputDecoration(
                                                      prefixText: "\u20B9",
                                                      suffixText: "/Person",
                                                      hintText: '4500',
                                                      labelText:
                                                          'Per Person Price',
                                                    ),
                                                  ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Room Furnished',
                                                  style: TextStyle(
                                                      fontSize: displayWidth(
                                                              context) *
                                                          0.045,
                                                      color:
                                                          Colors.grey.shade600),
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
                                                        margin: const EdgeInsets
                                                            .all(3),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          image:
                                                              DecorationImage(
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
                                                  onPressed: () {
                                                    setState(() {
                                                      chooseImage();
                                                    });
                                                  },
                                                  child:
                                                      const Text('Add Images'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      autoFillLocation();
                                                    });
                                                  },
                                                  child: const Text(
                                                      'Fill Location'),
                                                ),
                                              ],
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(()  {
                                                  validatePost();
                                                  if (isValid) {
                                                     _databaseService
                                                        .updateUserData(
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
                                                    uploadRoommateFile()
                                                        .whenComplete(
                                                      () => Navigator
                                                          .pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const HomePage()),
                                                      ),
                                                    );
                                                  }
                                                });
                                              },
                                              child: const Text('Upload'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(
                                        height: 0,
                                        width: 0,
                                      ),
                          ],
                        ),
                      ),
                    ],
                  )
            : const Text('Rotate your device in Portrait'),
      ),
    );
  }
}
