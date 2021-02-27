import 'package:CHEMCHAMP/pages/recentconversationpage.dart';
import 'package:CHEMCHAMP/pages/searchpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:CHEMCHAMP/pages/profilepage.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  double _height;
  double _width;

  TabController _tabController;

  HomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 16),
        ),
        title: Text("ChemChamp"),
        bottom: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.people_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 25,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      body: tabBarPages(),
    );
  }

  Widget tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(_height, _width),
        RecentConversationPage(_height, _width),
        ProfilePage(_height, _width),
      ],
    );
  }
}
