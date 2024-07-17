import 'dart:convert';
import 'dart:async';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/constants/translate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const NotificationScreen({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  int currentPage = 2;
  late TabController _tabController;
  DateTime? currentBackPressTime;
  List successfulNotifications = [];
  List unsuccessfulNotifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final url = Uri.https('secure.ariyanshipu.me', '/payment/search_transactions');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'device_key': GlobalData.userData?['device_key'],
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          successfulNotifications = data
              .where((notification) => notification['status'] == 'Successful')
              .toList();
          unsuccessfulNotifications = data
              .where((notification) => notification['status'] == 'initialize')
              .toList();
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching notifications: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.onNavigateToPage(0);
            },
          ),
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text('Notifications')),
          ),
          backgroundColor: TColors.tPrimaryColor,
          actions: [
            ThemeSwitcher(
              clipper: const ThemeSwitcherCircleClipper(),
              builder: (context) {
                final theme = ThemeModelInheritedNotifier.of(context).theme;
                return IconButton(
                  icon: Icon(
                    theme.brightness == Brightness.dark
                        ? Icons.wb_sunny
                        : Icons.nights_stay,
                  ),
                  onPressed: () {
                    ThemeSwitcher.of(context).changeTheme(
                      theme: theme.brightness == Brightness.light
                          ? TAppTheme.darkTheme
                          : TAppTheme.lightTheme,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Successful'),
                        Tab(text: 'Unsuccessful'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationList(successfulNotifications),
                  _buildNotificationList(unsuccessfulNotifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    widget.onNavigateToPage(0);
    return false;
  }

  Widget _buildNotificationList(List notifications) {
    if (notifications.isEmpty) {
      return const Center(child: Text('No notifications available'));
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        DateTime createdAt = DateTime.parse(notification['created_at']);
        String formattedDate = DateFormat('yyyy MM dd hh:mm a').format(createdAt);
        String amount = notification['amount'];

        return GestureDetector(
          onTap: () => {},
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1,color: TColors.grey)
              )
            ),
            margin: const EdgeInsets.only(left: 15,right: 15),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      notification['status'] == 'Successful'
                          ? Icons.check_circle
                          : Icons.error,
                      color: notification['status'] == 'Successful'
                          ? Colors.green
                          : Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['invoice_id'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification['risk_title'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳ ${Translate.convertToBangla(amount)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Bangla',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
