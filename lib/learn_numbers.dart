import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class LearnNumbers extends StatefulWidget {
  const LearnNumbers({Key? key}) : super(key: key);

  @override
  State<LearnNumbers> createState() => _LearnNumbersState();
}

class _LearnNumbersState extends State<LearnNumbers> {
  VideoPlayerController? _controller;
  bool isPlaying = false;
  final List<String> numbers = List.generate(10, (index) => index.toString());

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _playVideo(String number) {
    _controller?.dispose();
    _controller = VideoPlayerController.asset('assets/videos/numbers/$number.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller!.play();
          isPlaying = true;
        });
      });
    _controller!.addListener(() {
      if (_controller!.value.position >= _controller!.value.duration) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[50]!;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = isDark ? Colors.green[200]! : Colors.green[400]!;
    final secondaryColor = isDark ? Colors.green[100]! : Colors.green[300]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Learn Numbers',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller!),
                      if (!isPlaying)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 64,
                            icon: const Icon(Icons.play_arrow, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _controller!.play();
                                isPlaying = true;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: numbers.map((number) => _buildNumberCard(
                number,
                primaryColor,
                secondaryColor,
                textColor,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(
    String number,
    Color startColor,
    Color endColor,
    Color textColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _playVideo(number),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                startColor.withOpacity(0.8),
                endColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
