import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:markets_deliveryboy/src/controllers/profile_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/user.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final User user;
  final ProfileController con;

  ProfileAvatarWidget({
    Key key,
    this.user,
    this.con,
  }) : super(key: key);
  @override
  _ProfileAvatarWidgetState createState() => _ProfileAvatarWidgetState();
}
class _ProfileAvatarWidgetState extends StateMVC<ProfileAvatarWidget> {

  File profileFile;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).accentColor;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .accentColor,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    closeUp(context);
                  },
                  child: Stack(
                    children: [
                      profileFile != null ? Container(
                          width: 135.0,
                          height: 135.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(profileFile)))) :
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(300)),
                        child: CachedNetworkImage(
                          height: 135,
                          width: 135,
                          fit: BoxFit.cover,
                          imageUrl: widget.user.image?.url,
                          placeholder: (context, url) =>
                              Image.asset(
                                'assets/img/loading.gif',
                                fit: BoxFit.cover,
                                height: 135,
                                width: 135,
                              ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error_outline),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 8,
                        child: buildEditIcon(color),
                      ),
                      /*Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey
                                    .withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 5,
                                offset: Offset(0,
                                    3), // changes position of shadow
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt_outlined),
                        ),
                      )*/
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.user.name != null ? widget.user.name:"",
            style: Theme
                .of(context)
                .textTheme
                .headline5
                .merge(TextStyle(color: Theme
                .of(context)
                .primaryColor)),
          ),
          Text(
            widget.user.address != null && widget.user.address != "null" ? widget.user.address:"",
            style: Theme
                .of(context)
                .textTheme
                .caption
                .merge(TextStyle(color: Theme
                .of(context)
                .primaryColor)),
          ),
        ],
      ),
    );
  }
  Widget buildEditIcon(Color color) => buildCircle(
    color: Colors.white,
    all: 3,
    child: buildCircle(
      color: color,
      all: 5,
      child: Icon( Icons.add_a_photo,
        color: Colors.white,
        size: 15,
      ),
    ),
  );

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Future closeUp(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Photo Library'),
                    onTap: () async {
                      try {
                        final pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (pickedFile == null) return;
                        profileFile = File(pickedFile.path);

                        var profile = await http.MultipartFile.fromPath(
                            "avatar",
                            profileFile.path,filename: "${File(pickedFile.path).path.split('/').last}"
                        );
                        widget.con.update(widget.user,profile);
                      } on PlatformException catch (e) {
                        print('FAILED $e');
                      }
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () async {
                    try {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (image == null) return;
                      profileFile = File(image.path);

                      var profile = await http.MultipartFile.fromPath(
                          "avatar",
                          profileFile.path,filename: "${File(image.path).path.split('/').last}"
                      );
                      widget.con.update(widget.user,profile);
                    } on PlatformException catch (e) {
                      print('FAILED $e');
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
