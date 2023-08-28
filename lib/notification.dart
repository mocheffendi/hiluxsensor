import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final List<String> logMessages;

  const NotificationPage({Key? key, required this.logMessages})
      : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notification'),
        ),
        body: _buildLogMessagesList());
  }

  Widget _buildLogMessagesList() {
    return ListView.builder(
        itemCount: widget.logMessages.length,
        itemBuilder: (context, index) {
          return _buildLogMessageItem(index);
        });
  }

  Widget _buildLogMessageItem(int index) {
    return Card(
      color: Colors.blueGrey[100],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          widget.logMessages[index],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        // subtitle: Text(
        //   'Timestamp: ${DateTime.now()}',
        //   style: TextStyle(fontSize: 14),
        // ),
        leading: Icon(Icons.info),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              widget.logMessages.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}
