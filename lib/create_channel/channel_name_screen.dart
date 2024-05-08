import 'package:amit_test/create_channel/channel_tags_screen.dart';
import 'package:amit_test/model/channel_model.dart';
import 'package:flutter/material.dart';

class ChannelNamePage extends StatefulWidget {
  @override
  _ChannelNamePageState createState() => _ChannelNamePageState();
}

class _ChannelNamePageState extends State<ChannelNamePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Channel Name")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Channel Name'),
            ),
            ElevatedButton(
              child: Text("Next"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TagsPage(
                    channelInfo: ChannelInfo(channelName: _controller.text),
                  ),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}