import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'dart:math';

class PracticeTest extends StatefulWidget {
  const PracticeTest({Key? key}) : super(key: key);

  @override
  State<PracticeTest> createState() => _PracticeTestState();
}

class _PracticeTestState extends State<PracticeTest> {
  VideoPlayerController? _controller;
  List<Map<String, dynamic>> currentQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool testCompleted = false;
  bool answerSubmitted = false;
  String? selectedAnswer;
  String correctAnswer = '';
  bool isPlaying = false;

  // All available items for quiz
  final Map<String, List<String>> allItems = {
    'numbers': ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
    'alphabets': [
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    ],
    'words': [
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
    ]
  };

  List<Map<String, dynamic>> generateQuestions() {
    final questions = <Map<String, dynamic>>[];
    final random = Random();
    final allItemsList = <Map<String, dynamic>>[];

    // Convert all items to a single list with their type
    allItems.forEach((type, items) {
      for (var item in items) {
        allItemsList.add({
          'value': item,
          'type': type
        });
      }
    });

    // Shuffle the complete list
    allItemsList.shuffle(random);

    // Take first 10 items for questions
    for (var i = 0; i < 10; i++) {
      final currentItem = allItemsList[i];
      final correctAnswer = currentItem['value'];
      final itemType = currentItem['type'];
      
      // Get 3 random options from the same category
      final options = [correctAnswer];
      final categoryItems = List<String>.from(allItems[itemType]!)..remove(correctAnswer);
      categoryItems.shuffle(random);
      options.addAll(categoryItems.take(3));
      options.shuffle(random);

      questions.add({
        'video': correctAnswer,
        'options': options,
        'correct': correctAnswer,
        'type': itemType
      });
    }

    return questions;
  }

  @override
  void initState() {
    super.initState();
    generateNewTest();
  }

  void generateNewTest() {
    currentQuestions = generateQuestions();
    currentQuestionIndex = 0;
    score = 0;
    testCompleted = false;
    answerSubmitted = false;
    selectedAnswer = null;
    _initializeVideo();
  }

  void retakeTest() {
    currentQuestionIndex = 0;
    score = 0;
    testCompleted = false;
    answerSubmitted = false;
    selectedAnswer = null;
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    final currentQuestion = currentQuestions[currentQuestionIndex];
    final videoPath = 'assets/videos/${currentQuestion['video']}.mp4';
    
    _controller = VideoPlayerController.asset(videoPath);
    
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _controller!.play();
          isPlaying = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _checkAnswer(String answer) {
    if (!answerSubmitted) {
      setState(() {
        selectedAnswer = answer;
        answerSubmitted = true;
        correctAnswer = currentQuestions[currentQuestionIndex]['correct'];
        if (answer == correctAnswer) {
          score++;
        }
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < currentQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answerSubmitted = false;
        selectedAnswer = null;
        _initializeVideo();
      });
    } else {
      setState(() {
        testCompleted = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100]!;
    final textColor = isDark ? Colors.white : Colors.black;
    final primaryColor = isDark ? Colors.purple[300]! : Colors.purple;
    final secondaryColor = isDark ? Colors.purple[200]! : Colors.purple[700]!;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Practice Test',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: testCompleted ? _buildResultScreen(primaryColor) : _buildQuestionScreen(primaryColor),
    );
  }

  Widget _buildQuestionScreen(Color primaryColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Question ${currentQuestionIndex + 1} of ${currentQuestions.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (_controller != null && _controller!.value.isInitialized)
          AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller!),
                if (!isPlaying)
                  IconButton(
                    icon: const Icon(Icons.play_arrow, size: 50, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _controller!.play();
                        isPlaying = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentQuestions[currentQuestionIndex]['options'].length,
            itemBuilder: (context, index) {
              final option = currentQuestions[currentQuestionIndex]['options'][index];
              final isSelected = selectedAnswer == option;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? primaryColor : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: answerSubmitted ? null : () => _checkAnswer(option),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (answerSubmitted)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: _nextQuestion,
              child: Text(
                currentQuestionIndex < currentQuestions.length - 1 ? 'Next Question' : 'Show Results',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultScreen(Color primaryColor) {
    final percentage = (score / currentQuestions.length) * 100;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Test Complete!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Score: $score/${currentQuestions.length}',
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: retakeTest,
                child: const Text('Retake Test', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: generateNewTest,
                child: const Text('New Test', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
