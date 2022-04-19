import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  //ProfileController _con;

  _DrawerWidgetState() : super(ProfileController()) {
    //_con = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: currentUser.value.apiToken == null
          ? CircularLoadingWidget(height: 500)
          : Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Pages', arguments: 0);
                  },
                  child: UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
//              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35)),
                    ),
                    accountName: Text(
                      currentUser.value.name,
                      style: Theme.of(context).textTheme.headline6.merge(TextStyle(color:Theme.of(context).primaryColor)),
                    ),
                    accountEmail: Text(
                      currentUser.value.email,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(currentUser.value.image.thumb),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                    child: ListView(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Pages', arguments: 1);
                          },
                          leading: Image.asset("assets/img/orders.png",
                              height: 24,
                              width: 24,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).orders,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Notifications');
                          },
                          leading: Image.asset("assets/img/notifications.png",
                              height: 24,
                              width: 24,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).notifications,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Pages', arguments: 2);
                          },
                          leading: Image.asset("assets/img/history.png",
                              height: 24,
                              width: 24,
                              color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).history,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          title: Text(
                            S.of(context).application_preferences,
                            style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color:Colors.black)),
                          ),
                          trailing: Icon(
                            Icons.remove,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Help');
                          },
                          leading: Image.asset("assets/img/help_support.png",
                              height: 24, width: 24, color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).help__support,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed('/Settings');
                          },
                          leading: Image.asset("assets/img/settings.png",
                              height: 24, width: 24, color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).settings,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        /*ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed('/Languages');
                      },
                      leading: Icon(
                        Icons.translate,
                        color: Theme.of(context).primaryColor.withOpacity(1),
                      ),
                      title: Text(
                        S.of(context).languages,
                        style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                      ),
                    ),*/
                        ListTile(
                          onTap: () {
                            if (Theme.of(context).brightness == Brightness.dark) {
                              setBrightness(Brightness.light);
                              setting.value.brightness.value = Brightness.light;
                            } else {
                              setting.value.brightness.value = Brightness.dark;
                              setBrightness(Brightness.dark);
                            }
                            setting.notifyListeners();
                          },
                          leading: Image.asset("assets/img/dark_mode.png",
                              height: 24, width: 24, color: Theme.of(context).primaryColor),
                          title: Text(
                            Theme.of(context).brightness == Brightness.dark ? S.of(context).light_mode : S.of(context).dark_mode,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            logout().then((value) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/Login', (Route<dynamic> route) => false);
                            });
                          },
                          leading: Image.asset("assets/img/logout.png",
                              height: 24, width: 24, color: Theme.of(context).primaryColor),
                          title: Text(
                            S.of(context).log_out,
                            style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                        ),
                        setting.value.enableVersion
                            ? ListTile(
                          dense: true,
                          title: Text(
                            S.of(context).version + " " + setting.value.appVersion,
                            style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color:Theme.of(context).primaryColor)),
                          ),
                          trailing: Icon(
                            Icons.remove,
                            color: Colors.black,
                          ),
                        )
                            : SizedBox(),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
