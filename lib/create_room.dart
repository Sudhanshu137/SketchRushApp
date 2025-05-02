import 'package:flutter/material.dart';
import 'package:scribble/paint_screen.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomNameController = TextEditingController();

  String? _maxRoundsValue;
  String? _roomSizeValue;

  void createRoom() {
    if (_nameController.text.isNotEmpty &&
        _roomNameController.text.isNotEmpty &&
        _maxRoundsValue != null &&
        _roomSizeValue != null) {
      Map<String, String> data = {
        "nickname": _nameController.text,
        "name": _roomNameController.text,
        "maxRounds": _maxRoundsValue!,
        "occupancy": _roomSizeValue!,
      };
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PaintScreen(data: data, screenFrom: 'createRoom')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Room"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Create Your Game Room",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter your Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple.shade500),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Room Name TextField
              TextField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  hintText: "Enter Room Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple.shade500),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Max Rounds Dropdown
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 100),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade500),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    "Max Rounds",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: _maxRoundsValue,
                  items: ["2", "5", "10", "15"]
                      .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _maxRoundsValue = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Room Size Dropdown
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 100),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade500),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    "Room Size",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: _roomSizeValue,
                  items: ["2", "3", "4", "5", "6", "7"]
                      .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _roomSizeValue = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Create Room Button with animation
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade700, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade300,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: createRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, disabledForegroundColor: Colors.transparent.withOpacity(0.38), disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Create Room",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
