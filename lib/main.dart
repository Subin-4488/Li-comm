import 'dart:async';
import 'package:flutter/material.dart';
import 'package:li_comm/values.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minor project',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Li-COMM'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  bool _loading = true;

  Future<void> _enableTorch(BuildContext context) async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {
      _showMessage('Could not enable torch', context);
    }
  }

  Future<void> _disableTorch(BuildContext context) async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (_) {
      _showMessage('Could not disable torch', context);
    }
  }

  void _showMessage(String error, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        error,
        style: const TextStyle(
            color: Color.fromARGB(255, 252, 17, 0), fontSize: 16),
      ),
      backgroundColor: const Color.fromARGB(255, 221, 220, 220),
    ));
  }

  Future<bool> _initFlashlight(BuildContext context) async {
    try {
      return await TorchLight.isTorchAvailable();
    } on Exception catch (_) {
      _showMessage(
        'Could not check if the device has an available torch',
        context,
      );
      rethrow;
    }
  }

  void blink(String msg, int flag) {
    int clock = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (clock == msg.length) {
        // print('OFF');
        await _disableTorch(context);
        timer.cancel();
        if (flag == 3 && context.mounted) Navigator.pop(context);
      }
      if (clock < msg.length) {
        if (msg[clock] == '1' && context.mounted) {
          _enableTorch(context);
          // print("$clock ON: ${msg[clock]}");
        } else {
          _disableTorch(context);
          // print("$clock OFF: ${msg[clock]}");
        }
        clock += 1;
      }
    });
  }

  void sendMessage() async {
    String msg = _textController.text;
    int length = msg.length;
    String error = "";
    bool flag = false;

    if (msg.isEmpty) {
      error = "Message field cannot be empty";
      flag = true;
    } else if (msg.length > 15) {
      error = "Message size limit exceeded!!";
      flag = true;
    }

    if (flag) {
      _showMessage(error, context);
    } else {
      String decode = '';
      for (var element in msg.characters) {
        decode += data[element.toUpperCase()]!;
      }

      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Executing...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      })));

      int flag = 1;
      Timer.periodic(const Duration(seconds: 5), (timer) {
        switch (flag) {
          case 1:
            // print("header: ${data["header"]}");
            blink(data["header"]!, flag);
            flag += 1;
            break;
          case 2:
            // print("length: ${length.toRadixString(2).padLeft(5, '0')}");
            blink(length.toRadixString(2).padLeft(5, '0'), flag);
            flag += 1;
            break;
          case 3:
            // print("msg: ${decode}");
            blink(decode, flag);
            timer.cancel();
            break;
          default:
        }
      });
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Scaffold(
            body: Center(
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Li - Comm',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(
                    height: 55,
                  ),
                  Row(
                    children: const [
                      Spacer(),
                      Text(
                        'Mini Project submitted by\nSUBIN A M (TKM19CS067)\nSRIGANSH S (TKM19CS066)',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                  const Spacer()
                ],
              ),
            ),
          )
        : FutureBuilder<bool>(
            future: _initFlashlight(context),
            builder: (context, snapshot) => snapshot.hasData && snapshot.data!
                ? Scaffold(
                    appBar: AppBar(
                      title: Text(
                        widget.title,
                      ),
                      centerTitle: true,
                    ),
                    body: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Spacer(),
                              TextField(
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.center,
                                controller: _textController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter the message (LIMIT: 15)',
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ElevatedButton.icon(
                                  onPressed: () => sendMessage(),
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  label: const Text('SEND MESSAGE')),
                              const Spacer(),
                              const Text(
                                'SUBIN A M (TKM19CS067)\nSRIGANSH S (TKM19CS066)',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontStyle: FontStyle.italic),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : const Scaffold(
                    body: Center(
                      child: Text('no FlashLight found in your device!!'),
                    ),
                  ),
          );
  }
}
