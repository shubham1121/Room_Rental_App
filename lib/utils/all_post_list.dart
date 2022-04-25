import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:room_rental_app/models/post_data.dart';
import 'package:room_rental_app/utils/post_card.dart';

import 'loading.dart';
import 'nothing_found.dart';

class AllPostList extends StatefulWidget {
  final bool showFilteredData;
  final String city;
   const AllPostList({Key? key, required this.showFilteredData, required this.city}) : super(key: key);

  @override
  State<AllPostList> createState() => _AllPostListState();
}

class _AllPostListState extends State<AllPostList> {
  @override
  Widget build(BuildContext context) {
    final  List<PostData?>? allPostlist = Provider.of<List<PostData?>?>(context);
    if (allPostlist == null) {
      return Loading(false);
    }
    final List<PostData> allNonNullPostList = widget.showFilteredData ? List.from(allPostlist.where((postData) => (postData != null && postData.city==widget.city)))
        : List.from(allPostlist.where((postData) => (postData != null)));

    return allNonNullPostList.isEmpty
            ? const NothingFound()
            : ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount:allNonNullPostList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: PostCard(
                      roommatePostData: null,
                        postData: allNonNullPostList[index], isAllPost: true),
                  );
                },
              );
  }
}
