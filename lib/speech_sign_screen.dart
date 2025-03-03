import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'theme_provider.dart';

// Animation data classes
class AnimationStep {
  final String type; // 'add-text' or 'video'
  final String? text; // For add-text: the text to add; For video: the video filename
  final List<BoneAnimation>? animations; // Not used in video implementation
  
  AnimationStep({required this.type, this.text, this.animations});
}

class BoneAnimation {
  final String boneName;
  final String action;
  final String axis;
  final double limit;
  final String sign;
  
  BoneAnimation({
    required this.boneName, 
    required this.action, 
    required this.axis, 
    required this.limit, 
    required this.sign
  });
}

class SpeechSignScreen extends StatefulWidget {
  const SpeechSignScreen({Key? key}) : super(key: key);
  @override
  State<SpeechSignScreen> createState() => _SpeechSignScreenState();
}

class _SpeechSignScreenState extends State<SpeechSignScreen> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _speechTextController = TextEditingController();
  
  // Animation controls
  double _animationSpeed = 0.1;
  double _pauseDuration = 800;
  String _processedText = "";
  bool _isListening = false;
  
  // Speech recognition
  late stt.SpeechToText _speech;
  
  // Animation queue and state
  List<AnimationStep> _animationQueue = [];
  bool _isAnimating = false;
  bool _isPaused = false;
  
  // Video Player controller
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  
  // Video progress tracking
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    
    // Initialize with default video
    _initializeDefaultVideo();
  }

  void _initializeDefaultVideo() {
    _videoController = VideoPlayerController.asset('assets/videos/Hello.mp4');
    _videoController.initialize().then((_) {
      // Add listener for video progress updates
      _videoController.addListener(_updateVideoProgress);
      
      setState(() {
        _videoInitialized = true;
      });
      _videoController.play();
      _videoController.setLooping(true);
    }).catchError((error) {
      print('Error initializing default video: $error');
    });
  }
  
  // Update progress based on actual video position
  void _updateVideoProgress() {
    if (_videoController.value.isInitialized && _videoController.value.duration.inMilliseconds > 0) {
      setState(() {
        _progressValue = _videoController.value.position.inMilliseconds / 
                          _videoController.value.duration.inMilliseconds;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _speechTextController.dispose();
    _videoController.removeListener(_updateVideoProgress);
    _videoController.dispose();
    super.dispose();
  }
  
  // Initialize speech recognition
  void _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      // Speech recognition is ready
    }
  }
  
  // Start listening for speech
  void _startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            _speechTextController.text = result.recognizedWords;
            _isListening = true;
          });
        },
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        onSoundLevelChange: (level) {
          // Could use this for visual feedback
        },
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }
  
  // Stop listening
  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }
  
  // Clear speech text
  void _resetSpeechText() {
    setState(() {
      _speechTextController.clear();
    });
  }

  // Process text into sign language videos
  void _processTextToSign(String inputText) {
    if (inputText.trim().isEmpty) return;
    
    setState(() {
      _processedText = "";
      _animationQueue = [];
      _progressValue = 0.0;
      _isPaused = false;
    });
    
    // Convert text to uppercase and split into words
    String text = inputText.toUpperCase();
    List<String> words = text.split(' ');
    
    for (String word in words) {
      // Check if the word has special characters
      bool hasSpecialChars = _containsSpecialCharacters(word);
      
      if (hasSpecialChars) {
        // Add special character handling
        _animationQueue.add(
          AnimationStep(
            type: 'add-text', 
            text: '$word '
          )
        );
        _animationQueue.add(
          AnimationStep(
            type: 'video',
            text: 'A.json'  // Special character fallback
          )
        );
      } else if (_wordVideoExists(word)) {
        // Add word video
        _animationQueue.add(
          AnimationStep(
            type: 'add-text', 
            text: '$word '
          )
        );
        _animationQueue.add(
          AnimationStep(
            type: 'video',
            text: '$word.mp4'
          )
        );
      } else {
        // Process each character
        for (int i = 0; i < word.length; i++) {
          String char = word[i];
          
          if (i == word.length - 1) {
            _animationQueue.add(
              AnimationStep(
                type: 'add-text',
                text: '$char '
              )
            );
          } else {
            _animationQueue.add(
              AnimationStep(
                type: 'add-text',
                text: char
              )
            );
          }
          
          _animationQueue.add(
            AnimationStep(
              type: 'video',
              text: '$char.mp4'
            )
          );
        }
      }
    }
    
    // Start animation
    _startAnimation();
  }
  
  // Start animation processing
  void _startAnimation() {
    if (_animationQueue.isEmpty) return;
    
    setState(() {
      _isAnimating = true;
      _progressValue = 0.0;
    });
    
    // Process animation queue
    _processAnimationQueue();
  }
  
  // Process animation queue
  void _processAnimationQueue() async {
    if (_animationQueue.isEmpty || _isPaused) {
      setState(() {
        _isAnimating = false;
        _progressValue = 1.0;
      });
      return;
    }
    
    // Get next animation step
    AnimationStep step = _animationQueue.removeAt(0);
    
    if (step.type == 'add-text' && step.text != null) {
      // Update processed text
      setState(() {
        _processedText += step.text!;
      });
      
      // Continue with next animation step
      _processAnimationQueue();
    } else if (step.type == 'video' && step.text != null) {
      // Load and play the video
      await _playVideo(step.text!);
      
      // Wait for video to complete or use configured duration
      try {
        // Get video duration
        final videoDuration = _videoController.value.duration;
        
        // Calculate effective duration based on speed
        final effectiveDuration = Duration(
          milliseconds: (videoDuration.inMilliseconds / (_animationSpeed * 10)).round()
        );
        
        // Wait for video to finish
        await Future.delayed(effectiveDuration);
        
        // Add configured pause after video completes
        if (_pauseDuration > 0) {
          await Future.delayed(Duration(milliseconds: _pauseDuration.toInt()));
        }
      } catch (e) {
        print('Error waiting for video: $e');
      }
      
      // Process next animation if not paused
      if (!_isPaused) {
        _processAnimationQueue();
      }
    }
  }
  
  Future<void> _playVideo(String videoName) async {
    // Dispose previous controller
    await _videoController.pause();
    _videoController.removeListener(_updateVideoProgress);
    await _videoController.dispose();
    setState(() {
      _videoInitialized = false;
    });
    
    // Initialize new video
    _videoController = VideoPlayerController.asset('assets/videos/$videoName');
    
    try {
      await _videoController.initialize();
      
      // Add listener for progress updates
      _videoController.addListener(_updateVideoProgress);
      
      // Apply animation speed to video playback
      _videoController.setPlaybackSpeed(_animationSpeed * 10); // Multiply for better range
      
      setState(() {
        _videoInitialized = true;
      });
      
      _videoController.play();
    } catch (e) {
      print('Error loading video $videoName: $e');
      // Fallback to default video
      _initializeDefaultVideo();
    }
  }
  
  // Implement save functionality
  Future<void> _saveCurrentVideo() async {
    try {
      // Check if a video is playing
      if (!_videoInitialized || _videoController.dataSource.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No video to save!')),
        );
        return;
      }

      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      
      // Extract filename from the current video path
      String fileName = _videoController.dataSource.split('/').last;
      
      // For asset files, we need to load the bytes and write them
      String assetPath = _videoController.dataSource.replaceFirst('asset://', '');
      
      // Create output file
      final File outputFile = File('$path/$fileName');
      
      // Load asset bytes and write to file
      ByteData data = await rootBundle.load(assetPath);
      final buffer = data.buffer;
      await outputFile.writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video saved to: ${outputFile.path}')),
      );
    } catch (e) {
      print('Error saving video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save video: $e')),
      );
    }
  }
  
  // Helper functions
  bool _containsSpecialCharacters(String word) {
    // This regex matches any character that is not a letter or number
    return RegExp(r'[^a-zA-Z0-9]').hasMatch(word);
  }
  
  bool _wordVideoExists(String word) {
    // List of available words that have video files
    List<String> availableWords = ['AFTER', 'AGAIN', 'AGAINST', 'AGE', 'ALL', 'ALONE', 'ALSO', 'AND', 'ASK', 'AT', 
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
    'YOU', 'YOUR', 'YOURSELF'];
    
    return availableWords.contains(word.toUpperCase());
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SignSpeak',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Processed Text Display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Processed Text',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      height: 80,
                      child: SingleChildScrollView(
                        child: Text(
                          _processedText,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Speech Recognition Controls
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Speech Recognition: ${_isListening ? 'on' : 'off'}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Speech Recognition Controls section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.mic, color: Colors.white),
                            label: const Text('Mic On', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                            ),
                            onPressed: _startListening,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.mic_off, color: Colors.white),
                            label: const Text('Mic Off', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                            ),
                            onPressed: _stopListening,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            label: const Text('Clear', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                            ),
                            onPressed: _resetSpeechText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _speechTextController,
                      decoration: InputDecoration(
                        hintText: 'Speech input...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[700] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          _processTextToSign(_speechTextController.text);
                        },
                        child: const Text(
                          'Start Animation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Manual Text Input
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Input',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type your text here...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[700] : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          _processTextToSign(_textController.text);
                        },
                        child: const Text(
                          'Start Animation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Progress Bar
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _progressValue,
                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.blue[400]! : Colors.blue,
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(_progressValue * 100).toInt()}%',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Video Player Container
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _videoInitialized 
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: isDark ? Colors.blue[400] : Colors.blue,
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Speed Controls
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animation Speed: ${(_animationSpeed * 100).round() / 100}',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _animationSpeed,
                      min: 0.05,
                      max: 0.5,
                      divisions: 45,
                      activeColor: isDark ? Colors.blue[400] : Colors.blue,
                      inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      onChanged: (value) {
                        setState(() {
                          _animationSpeed = value;
                          
                          // Update current video speed if playing
                          if (_videoInitialized) {
                            _videoController.setPlaybackSpeed(_animationSpeed * 10);
                          }
                        });
                      },
                    ),
                    
                    // Pause Duration Slider
                    Text(
                      'Pause Duration: ${_pauseDuration.toInt()} ms',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: _pauseDuration,
                      min: 0,
                      max: 2000,
                      divisions: 20,
                      activeColor: isDark ? Colors.blue[400] : Colors.blue,
                      inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                      onChanged: (value) {
                        setState(() {
                          _pauseDuration = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Animation Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.replay,
                      color: isDark ? Colors.blue[300] : Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      // Restart current video
                      if (_videoInitialized) {
                        _videoController.seekTo(Duration.zero);
                        _videoController.play();
                      }
                      
                      // Restart animation if needed
                      if (_speechTextController.text.isNotEmpty) {
                        _processTextToSign(_speechTextController.text);
                      } else if (_textController.text.isNotEmpty) {
                        _processTextToSign(_textController.text);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isPaused ? Icons.play_arrow : Icons.pause,
                      color: isDark ? Colors.blue[300] : Colors.blue,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPaused = !_isPaused;
                        
                        // Directly control video playback
                        if (_videoInitialized) {
                          if (_isPaused) {
                            _videoController.pause();
                          } else {
                            _videoController.play();
                            
                            // Resume queue processing if needed
                            if (_isAnimating) {
                              _processAnimationQueue();
                            }
                          }
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.save_alt,
                      color: isDark ? Colors.blue[300] : Colors.blue,
                      size: 30,
                    ),
                    onPressed: _saveCurrentVideo,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sign_language),
            label: 'Sign-Speech',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Speech-Sign',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: isDark ? Colors.blue[300] : Colors.blue,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}