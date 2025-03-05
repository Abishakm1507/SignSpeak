import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class LearnAlphabets extends StatefulWidget {
  const LearnAlphabets({Key? key}) : super(key: key);

  @override
  State<LearnAlphabets> createState() => _LearnAlphabetsState();
}

class _LearnAlphabetsState extends State<LearnAlphabets> {
  late VideoPlayerController _controller;
  String currentLetter = 'A';
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(
      'assets/videos/$currentLetter.mp4',
    )..initialize().then((_) {
        setState(() {});
      });
  }

  void _changeVideo(String letter) {
    _controller.dispose();
    setState(() {
      currentLetter = letter;
      _controller = VideoPlayerController.asset(
        'assets/videos/$letter.mp4',
      )..initialize().then((_) {
          setState(() {});
          _controller.play();
          isPlaying = true;
        });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> alphabets = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn Alphabets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Video Player Section
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _controller.value.isInitialized
                    ? VideoPlayer(_controller)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Video Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 40,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    if (isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    isPlaying = !isPlaying;
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.replay,
                  size: 40,
                  color: Colors.blue,
                ),
                onPressed: () {
                  _controller.seekTo(Duration.zero);
                  _controller.play();
                  setState(() {
                    isPlaying = true;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Current Letter Display
          Text(
            'Current Letter: $currentLetter',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Alphabet Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: alphabets.length,
              itemBuilder: (context, index) {
                final letter = alphabets[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentLetter == letter
                        ? Colors.blue
                        : isDark ? Colors.grey[700] : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _changeVideo(letter),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentLetter == letter
                          ? Colors.white
                          : isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
