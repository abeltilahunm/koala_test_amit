import 'package:amit_test/channel_page/channel_page.dart';
import 'package:amit_test/create_channel/channel_name_screen.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

AmityUser? amityUser;
AmityUserToken? amityUserToken;
var logger = Logger(
  printer: PrettyPrinter(),
);

void main() {
  setup();
  runApp(const MyApp());
}

Future<void> setup() async {
  // await AmityCoreClient.setup(
  //     option: AmityCoreClientOption(
  //       apiKey: 'b0eaeb0b3b8ff56149358c18000e168cd65fdab0b9333a29',
  //       httpEndpoint: AmityRegionalHttpEndpoint.EU,
  //     ),
  //     sycInitialization: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Amity Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AmityChannel>? channels;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginAndGo();
  }

  void loginAndGo() async {
    await AmityCoreClient.setup(
        option: AmityCoreClientOption(
          apiKey: 'b0eaeb0b3b8ff56149358c18000e168cd65fdab0b9333a29',
          httpEndpoint: AmityRegionalHttpEndpoint.EU,
        ),
        sycInitialization: true);
    //Here even tho it is a login call Amit uses this method to create user.
    await AmityCoreClient.login('abel14ProMax') //abel14ProMax//abeliPhone8
        .displayName('Abel 14ProMax') //Abel 14ProMax//Abel iPhone8
        .submit()
        .then((AmityUser val) {
      logger.d(val.userId);
      amityUser = val;
      AmityUserTokenManager(
              apiKey: "b0eaeb0b3b8ff56149358c18000e168cd65fdab0b9333a29",
              endpoint: AmityRegionalHttpEndpoint.EU)
          .createUserToken(amityUser!.userId.toString())
          .then((AmityUserToken token) {
        logger.d("accessToken = ${token.accessToken}");
        amityUserToken = token;
        AmityChannelRepository().getChannels().getPagingData().then((value) {
          channels = value.data;
          setState(() {});
        }).catchError((e) {
          logger.d(e);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AmityCoreClient.currentSessionState.name == 'established') {}
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => ChannelNamePage(),
              ))
                  .then((value) {
                if (value != null) {
                  AmityChannelRepository().getChannels().getPagingData().then((value) {
                    channels = value.data;
                    setState(() {});
                  }).catchError((e) {
                    logger.d(e);
                  });
                }
              });
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: channels == null
          ? const Center(
              child: Text("Loading one"),
            )
          : ListView.builder(
              itemCount: channels!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatPage(
                        channelId: channels![index].channelId.toString(),
                        userId: amityUser!.userId.toString(),
                        channelName: channels![index].displayName.toString(),
                      ),
                    ));
                  },
                  title: Text(channels![index].displayName.toString()),
                );
              }),
    );
  }
}
