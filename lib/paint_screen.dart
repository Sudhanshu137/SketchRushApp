import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart'; // <-- Add this
import 'package:scribble/final_leaderboard.dart';
import 'package:scribble/home_screen.dart';
import 'package:scribble/models/TouchPoints.dart';
import 'package:scribble/models/my_custom_painter.dart';
import 'package:scribble/sidebar/player_scoreboard_drawer.dart';
import 'package:scribble/waiting_lobby_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;

  PaintScreen({required this.data, required this.screenFrom});

  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  Map dataOfRoom = {};
  List<TouchPoints?> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;
  List<Widget> textBlankWidget = [];
  ScrollController _scrollController = ScrollController();
  List<Map> messages = [];
  TextEditingController controller = TextEditingController();
  int guessedUserCtr = 0;
  int _start = 60;
  late Timer _timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool isTextInputReadOnly = false;
  int maxPoints = 0;
  String winner = "";
  bool isShowFinalLeaderBoard = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer time) {
      if (_start == 0) {
        _socket.emit('change-turn', dataOfRoom['name']);
        _timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i <= text.length; i++) {
      textBlankWidget.add(Text('_', style: TextStyle(fontSize: 25)));
    }
  }

  void connect() {
    _socket = IO.io('http://192.168.215.5:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      _socket.emit('join-game', widget.data);
    }

    _socket.onConnect((data) {
      _socket.on('updateRoom', (roomData) {
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          startTimer();
        }
        scoreboard.clear();
        for (var player in roomData['players']) {
          scoreboard.add({
            'username': player['nickname'],
            'points': player['points'].toString(),
          });
        }
      });

      _socket.on(
          'notCorrectGame',
              (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false));
      _socket.on('points', (point) {
        if (point['details'] != null) {
          setState(() {
            points.add(TouchPoints(
              points: Offset(
                (point['details']['dx']).toDouble(),
                (point['details']['dy']).toDouble(),
              ),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth,
            ));
          });
        } else {
          points.add(null);
        }
      });

      _socket.on('updateScore', (roomData) {
        scoreboard.clear();
        for (var player in roomData['players']) {
          scoreboard.add({
            'username': player['nickname'],
            'points': player['points'].toString(),
          });
        }
      });

      _socket.on('show-leaderboard', (roomPlayers) {
        scoreboard.clear();
        for (int i = 0; i < roomPlayers.length; i++) {
          setState(() {
            scoreboard.add({
              'username': roomPlayers[i]['nickname'],
              'points': roomPlayers[i]['points'].toString(),
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
        setState(() {
          _timer.cancel();
          isShowFinalLeaderBoard = true;
        });
      });

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        setState(() {
          selectedColor = Color(value);
        });
      });

      _socket.on('stroke-width', (value) {
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      _socket.on('clear-screen', (_) {
        setState(() {
          points.clear();
        });
      });

      _socket.on('closeInput', (_) {
        _socket.emit('updateScore', widget.data['name']);
        setState(() {
          isTextInputReadOnly = true;
        });
      });

      _socket.on('msg', (msgData) {
        setState(() {
          messages.add(msgData);
          guessedUserCtr = msgData['guessedUserCtr'];
        });
        if (guessedUserCtr == dataOfRoom['players'].length - 1) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 40,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      });

      _socket.on('user-disconnected', (data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'points': data['players'][i]['points'].toString(),
            });
          });
          if (maxPoints < int.parse(scoreboard[i]['points'])) {
            winner = scoreboard[i]['username'];
            maxPoints = int.parse(scoreboard[i]['points']);
          }
        }
      });

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                dataOfRoom = data;
                renderTextBlank(data['word']);
                isTextInputReadOnly = false;
                guessedUserCtr = 0;
                _start = 60;
                points.clear();
              });
              Navigator.of(context).pop();
              _timer.cancel();
              startTimer();
            });
            return AlertDialog(
              title: Center(child: Text('Word was $oldWord')),
            );
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Choose Color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) {
                  String valueString =
                  color.toString().split('(0x')[1].split(')')[0];
                  Map map = {
                    'color': valueString,
                    'roomName': dataOfRoom['name']
                  };
                  _socket.emit('color-change', map);
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'))
            ],
          ));
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('SketchRush', style: TextStyle(color: Colors.black)),
      ),
      drawer: PlayerScore(userData: scoreboard),
      backgroundColor: Colors.white,
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
          ? !isShowFinalLeaderBoard
          ? Stack(
        children: [
          Column(
            children: [
              // Drawing Area
              Flexible(
                flex: 6,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanStart: (details) {
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanEnd: (_) {
                    _socket.emit('paint', {
                      'details': null,
                      'roomName': widget.data['name'],
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: MyCustomPainter(
                            pointsList: points),
                      ),
                    ),
                  ),
                ),
              ),

              // Controls
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens,
                        color: selectedColor),
                    onPressed: selectColor,
                  ),
                  Expanded(
                    child: Slider(
                      min: 1.0,
                      max: 10,
                      label: "Strokewidth $strokeWidth",
                      activeColor: selectedColor,
                      value: strokeWidth,
                      onChanged: (double value) {
                        _socket.emit('stroke-width', {
                          'value': value,
                          'roomName': dataOfRoom['name']
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.layers_clear,
                        color: selectedColor),
                    onPressed: () => _socket.emit(
                        'clean-screen', dataOfRoom['name']),
                  ),
                ],
              ),

              // Word Display
              dataOfRoom['turn']['nickname'] !=
                  widget.data['nickname']
                  ? Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: textBlankWidget,
              )
                  : Center(
                child: Text(
                  dataOfRoom['word'],
                  style: TextStyle(fontSize: 30),
                ),
              ),

              // Messages
              Flexible(
                flex: 3,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index].values;
                    return ListTile(
                      title: Text(
                        msg.elementAt(0),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        msg.elementAt(1),
                        style: TextStyle(
                            color: Colors.grey, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),

              // Message Input
              dataOfRoom['turn']['nickname'] !=
                  widget.data['nickname']
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: isTextInputReadOnly,
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: 'Your Guess',
                          filled: true,
                          fillColor: Color(0xffF5F5FA),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (controller.text
                            .trim()
                            .isNotEmpty) {
                          _socket.emit('msg', {
                            'username':
                            widget.data['nickname'],
                            'msg':
                            controller.text.trim(),
                            'word': dataOfRoom['word'],
                            'roomName':
                            widget.data['name'],
                            'guessedUserCtr':
                            guessedUserCtr,
                            'totalTime': 60,
                            'timeTaken': 60 - _start,
                          });
                          controller.clear();
                        }
                      },
                      icon: Icon(Icons.send),
                      color: Colors.blue,
                    ),
                  ],
                ),
              )
                  : Container(),
            ],
          ),

          // Timer UI (Top-Right Corner)
          Positioned(
            top: 10,
            right: 10,
            child: CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 5.0,
              percent: _start / 60,
              center: Text(
                '$_start',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.redAccent,
              backgroundColor: Colors.grey[300]!,
            ),
          )
        ],
      )
          : FinalLeaderBoard(
        scoreboard: scoreboard,
        winner: winner,
      )
          : WaitingLobbyScreen(
        lobbyName: dataOfRoom['name'],
        noOfPlayers: dataOfRoom['players'].length,
        occupancy: dataOfRoom['occupancy'],
        players: dataOfRoom['players'],
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
