import 'package:amit_test/create_channel/channel_privacy_page.dart';
import 'package:amit_test/model/channel_model.dart';
import 'package:flutter/material.dart';


class TagsPage extends StatefulWidget {
  final ChannelInfo channelInfo;

  TagsPage({required this.channelInfo});

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Tags")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            ElevatedButton(
              child: Text("Next"),
              onPressed: () {
                widget.channelInfo.tags = _controller.text.split(',').map((s) => s.trim()).toList();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PrivacyPage(channelInfo: widget.channelInfo),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
