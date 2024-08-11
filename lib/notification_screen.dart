import 'dart:convert';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/utils/constants/translate.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/global_data.dart';
import 'package:flutter_application/utils/constants/colors.dart';
import 'package:flutter_application/utils/theme/theme.dart';

class NotificationScreen extends StatefulWidget {
  final Function(int) onNavigateToPage;

  const NotificationScreen({
    super.key,
    required this.onNavigateToPage,
  });

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
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
          onTap: () => _showNotificationDetails(notification),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: TColors.grey)
              )
            ),
            margin: const EdgeInsets.only(left: 15, right: 15),
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

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NotificationDetailsPopup(notification: notification);
      },
    );
  }
}

class NotificationDetailsPopup extends StatelessWidget {
  final Map<String, dynamic> notification;
  final GlobalKey _globalKey = GlobalKey();

  NotificationDetailsPopup({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = DateTime.parse(notification['created_at']);
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(createdAt);
    String amount = notification['amount'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              children: [
                TableRow(children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Invoice ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(notification['invoice_id']),
                    ),
                  ),
                ]),
                TableRow(children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Risk Title',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(notification['risk_title']),
                    ),
                  ),
                ]),
                TableRow(children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('৳ ${Translate.convertToBangla(amount)}'),
                    ),
                  ),
                ]),
                TableRow(children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(formattedDate),
                    ),
                  ),
                ]),
                TableRow(children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(notification['status']),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: notification['invoice_id']),
              );
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice ID copied to clipboard!'),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}


