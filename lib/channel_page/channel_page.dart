import 'package:amit_test/main.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String channelId;
  final String userId;
  final String channelName;

  ChatPage({required this.channelId, required this.userId, required this.channelName});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late MessageLiveCollection messageLiveCollection;
  List<AmityMessage> amityMessages = [];
  final scrollcontroller = ScrollController();

  @override
  void initState() {
    super.initState();
    observMessages();
  }

  void observMessages() async {
    //initialize message live collection
    messageLiveCollection = AmityChatClient.newMessageRepository()
        .getMessages(widget.channelId)
        //stack from end = true - means the first message will be last created message
        //compatible with UI that needs the latest message on the bottom of the UI
        //vice versa with stack from end = false - the first message will be first created message
        .stackFromEnd(true)
        .getLiveCollection(pageSize: 20);

    //listen to data changes from live collection
    messageLiveCollection.getStreamController().stream.listen((event) {
      // update latest results here
      // setState(() {
      amityMessages = event;

      // });
    });

    //load first page when initiating widget
    messageLiveCollection.loadNext();

    //add pagination listener when srolling to top/bottom
    scrollcontroller.addListener(paginationListener);
  }

  void paginationListener() {
    //check if
    //#1 scrolling reached top/bottom
    //#2 live collection has next page to load more
    if ((scrollcontroller.position.pixels >= (scrollcontroller.position.maxScrollExtent - 100)) &&
        messageLiveCollection.hasNextPage()) {
      //load next page data
      messageLiveCollection.loadNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channelName)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<AmityMessage>>(
              stream: messageLiveCollection.getStreamController().stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && snapshot.data != null) {
                  return const Center(child: Text("Loading"));
                }

                if (snapshot.data == null) {
                  return Container();
                }

                List<AmityMessage> messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final text = (messages[index].data as MessageTextData).text;
                    final AmityUser messageOwner = messages[index].user!;

                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: messageOwner.userId == widget.userId
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (messageOwner.userId != widget.userId) ...{
                            CircleAvatar(
                              child: Text('${messageOwner.displayName?.substring(0, 2)}'),
                            ),
                          },
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: messageOwner.userId == widget.userId
                                    ? Colors.blue
                                    : Colors.lightBlueAccent),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  text ?? "Message error",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  "user: ${messages[index].userId}",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(messages[index].createdAt == null
                                    ? ""
                                    : messages[index].createdAt!.toLocal().toIso8601String()),
                              ],
                            ),
                          ),
                          if (messageOwner.userId == widget.userId) ...{
                            const CircleAvatar(
                              child: Text("Me"),
                            ),
                          }
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      AmityChatClient.newMessageRepository()
          .createMessage(widget.channelId)
          .text(_messageController.text)
          .send()
          .then((value) {
        FocusManager.instance.primaryFocus?.unfocus();
      }).onError((error, stackTrace) {
        //handle error
        logger.d(error);
      });
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
