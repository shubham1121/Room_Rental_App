import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/models/roommate_post.dart';
import 'package:room_rental_app/services/firebase_auth.dart';
import 'package:room_rental_app/utils/device_size.dart';
import 'package:room_rental_app/utils/loading.dart';

class PostDetails extends StatefulWidget {
  final PostData? postData;
  final RoommatePostData? roommatePostData;
  const PostDetails({Key? key, required this.postData, required this.roommatePostData}) : super(key: key);

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Details'),
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
      body: widget.postData == null ? Column(
        children: [
          SizedBox(
            height: 350.0,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.roommatePostData!.uplImgLink.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        openRoommateDetails(index);
                      });
                    },
                    child: SizedBox(
                      width: 350,
                      child: CachedNetworkImage(
                        imageUrl: widget.roommatePostData!.uplImgLink[index],
                        placeholder: (context, url) =>
                            smallLoadingIndicatorForImages(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.roommatePostData!.roomType.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        widget.roommatePostData!.date.substring(0, 10),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontSize: displayWidth(context) * 0.05,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.roommatePostData!.ownAddress,
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ) :
      Column(
        children: [
          SizedBox(
            height: 350.0,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: widget.postData!.uplImgLink.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        openRoomDetails(index);
                      });
                    },
                    child: SizedBox(
                      width: 350,
                      child: CachedNetworkImage(
                        imageUrl: widget.postData!.uplImgLink[index],
                        placeholder: (context, url) =>
                            smallLoadingIndicatorForImages(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.postData!.roomType.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        widget.postData!.date.substring(0, 10),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontSize: displayWidth(context) * 0.05,
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.postData!.ownAddress,
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void openRoomDetails(int index) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GalleryPage(
          urlImages: widget.postData!.uplImgLink,
          index: index,
        ),
      ));
  void openRoommateDetails(int index) => Navigator.of(context).push(MaterialPageRoute(
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
      : pageController = PageController(initialPage: index), super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late int index = widget.index;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
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
    );
  }
}
