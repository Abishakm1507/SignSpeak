import 'package:flutter/material.dart';

class SpeechSignScreen extends StatefulWidget {
  const SpeechSignScreen({Key? key}) : super(key: key);

  @override
  State<SpeechSignScreen> createState() => _SpeechSignScreenState();
}

class _SpeechSignScreenState extends State<SpeechSignScreen> {
  int _selectedIndex = 2;
  final TextEditingController _textController = TextEditingController();
  double _progressValue = 0.4;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on bottom nav selection
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Sign-Speech
        Navigator.pushReplacementNamed(context, '/sign_speech');
        break;
      case 2: // Speech-Sign - already here
        break;
      case 3: // Settings
        Navigator.pushReplacementNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SignSpeak',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Speech Input Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type or speak your text here',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () {
                      _textController.clear();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Microphone Button
            GestureDetector(
              onTap: () {
                print('Start Voice Input');
              },
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.mic, color: Colors.white, size: 35),
              ),
            ),
            const SizedBox(height: 20),

            // Animated Avatar (Dummy Image)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                // Replace with real animation or image
                child: Text(
                  'Avatar Animation Area',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Controls (Play, Speed, Repeat)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_circle_fill,
                      color: Colors.blue, size: 40),
                  onPressed: () {
                    print('Play Animation');
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon:
                      const Icon(Icons.speed, color: Colors.black54, size: 30),
                  onPressed: () {
                    print('Change Speed');
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Colors.black54, size: 30),
                  onPressed: () {
                    print('Repeat Animation');
                    setState(() {
                      _progressValue = 0.0;
                    });
                  },
                ),
              ],
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.front_hand), label: 'Sign-Speech'),
          BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq), label: 'Speech-Sign'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
