import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class LearnWords extends StatefulWidget {
  const LearnWords({Key? key}) : super(key: key);

  @override
  State<LearnWords> createState() => _LearnWordsState();
}

class _LearnWordsState extends State<LearnWords> {
  late VideoPlayerController _controller;
  String currentWord = 'Hello';
  bool isPlaying = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> filteredWords = [];

  final List<String> words = [
    'AFTER', 'AGAIN', 'AGAINST', 'AGE', 'ALL', 'ALONE', 'ALSO', 'AND', 'ASK', 'AT', 
      'BE', 'BEAUTIFUL', 'BEFORE', 'BEST', 'BETTER', 'BUSY', 'BUT', 'BYE',
      'CAN', 'CANNOT', 'CHANGE', 'COLLEGE', 'COME', 'COMPUTER',
      'DAY', 'DISTANCE', 'DO NOT', 'DO', 'DOES NOT',
      'EAT', 'ENGINEER',
      'FIGHT', 'FINISH', 'FROM',
      'GLITTER', 'GO', 'GOD', 'GOLD', 'GOOD', 'GREAT',
      'HAND', 'HANDS', 'HAPPY', 'HELLO', 'HELP', 'HER', 'HERE', 'HIS', 'HOME', 'HOMEPAGE', 'HOW',
      'INVENT', 'IT',
      'KEEP',
      'LANGUAGE', 'LAUGH', 'LEARN',
      'ME', 'MY', 'MORE',
      'NAME', 'NEXT', 'NOT', 'NOW',
      'OF', 'ON', 'OUR', 'OUT',
      'PRETTY',
      'RIGHT',
      'SAD', 'SAFE', 'SEE', 'SELF', 'SIGN', 'SING', 'SO', 'SOUND', 'STAY', 'STUDY',
      'TALK', 'TELEVISION', 'THANK', 'THANKYOU', 'THAT', 'THEY', 'THIS', 'THOSE', 'TIME', 'TO', 'TYPE',
      'US',
      'WALK', 'WASH', 'WAY', 'WE', 'WELCOME', 'WHAT', 'WHEN', 'WHERE', 'WHICH', 'WHO', 'WHOLE', 'WHOSE', 'WHY', 'WILL', 'WITH', 'WITHOUT', 'WORDS', 'WORLD', 'WORK', 'WRONG',
      'YOU', 'YOUR', 'YOURSELF'
  ];

  @override
  void initState() {
    super.initState();
    filteredWords = List.from(words);
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.asset(
      'assets/videos/${currentWord.toLowerCase().replaceAll(' ', '_')}.mp4',
    )..initialize().then((_) {
        setState(() {});
      });
  }

  void _changeVideo(String word) {
    _controller.dispose();
    setState(() {
      currentWord = word;
      _controller = VideoPlayerController.asset(
        'assets/videos/${word.toLowerCase().replaceAll(' ', '_')}.mp4',
      )..initialize().then((_) {
          setState(() {});
          _controller.play();
          isPlaying = true;
        });
    });
  }

  void _filterWords(String query) {
    setState(() {
      filteredWords = words
          .where((word) => word.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn Words',
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWords,
              decoration: InputDecoration(
                hintText: 'Search words...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
            ),
          ),
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
          // Current Word Display
          Text(
            'Current Word: $currentWord',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Words List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final word = filteredWords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: currentWord == word
                      ? Colors.blue
                      : isDark ? Colors.grey[700] : Colors.grey[200],
                  child: ListTile(
                    title: Text(
                      word,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: currentWord == word
                            ? Colors.white
                            : isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      Icons.play_arrow,
                      color: currentWord == word
                          ? Colors.white
                          : isDark ? Colors.white70 : Colors.black87,
                    ),
                    onTap: () => _changeVideo(word),
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
