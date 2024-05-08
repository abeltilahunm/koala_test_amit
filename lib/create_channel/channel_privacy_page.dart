import 'package:amit_test/main.dart';
import 'package:amit_test/model/channel_model.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  final ChannelInfo channelInfo;

  PrivacyPage({required this.channelInfo});

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Channel Privacy")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: Text("Public Channel"),
              value: _isPublic,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            ElevatedButton(
              child: Text("Finish"),
              onPressed: () {
                widget.channelInfo.isPublic = _isPublic;
                createChannel();
              },
            ),
          ],
        ),
      ),
    );
  }

  void createChannel() {
    logger.d("Channel Name: ${widget.channelInfo.channelName}");
    logger.d("Tags: ${widget.channelInfo.tags}");
    logger.d("Is Public: ${widget.channelInfo.isPublic ? 'Yes' : 'No'}");
    // create channel and let SDK handle channelId generation
    AmityChatClient.newChannelRepository()
        .createChannel()
        .communityType()
        .withDisplayName(widget.channelInfo.channelName)
        .metadata({'key': 'value'}) //Optional
        .tags(widget.channelInfo.tags) //Optional
        .create()
        .then((AmityChannel channel) {
          //handle result
          logger.d(channel.displayName);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
        })
        .onError((error, stackTrace) {
          //handle error
          logger.d(error);
        });
  }
}
