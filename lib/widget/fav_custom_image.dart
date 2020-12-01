import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../constant/app_images.dart';
import '../api/api_call.dart';

class CustomImage extends StatelessWidget {
  final String imgURL;
  final double height;
  final double width;
  final String placeholderImg;
  final bool connectivity;
  CustomImage(
      {@required this.imgURL,
      @required this.height,
      @required this.width,
      this.placeholderImg = AppImages.loader,
      this.connectivity = true});


//Normal Image...
  Widget _buildImage() {
    return FadeInImage.assetNetwork(
      fadeInDuration: const Duration(milliseconds: 450),
      placeholder: placeholderImg,
      image: imgURL,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget _buildImageWithCircular() {
    // print("IMGURL: $imgURL");
    // return this.connectivity
    //     ? Image.network(
    //         imgURL,
    //         width: width,
    //         height: height,
    //         fit: BoxFit.cover,
    //         loadingBuilder: (ctx, child, loadingProgress) {
    //           if (loadingProgress == null) return child;
    //           return Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         },
    //       )
    //     : new Image.file(
    //         File(imgURL),
    //       );
    return new Image.file(
            File(imgURL),
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageWithCircular(); //_buildImage();
  }

  // Future<String> getFilePath(String url) async {
  //   String path = (await getApplicationDocumentsDirectory()).path + '/img/';
  //   List<String> strs = url.split("/");
  //   return path + strs.last;
  // }
}
