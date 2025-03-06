import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'learn_alphabets.dart';
import 'learn_numbers.dart';
import 'learn_words.dart';
import 'practice_test.dart';

class LearnSignLanguage extends StatelessWidget {
  const LearnSignLanguage({Key? key}) : super(key: key);

  final Map<String, Map<String, dynamic>> categoryStyles = const {
    'Alphabets': {
      'icon': Icons.abc,
      'gradient': [Color.fromARGB(255, 121, 192, 255), Color.fromARGB(255, 94, 169, 255)],
      'iconColor': Colors.white,
    },
    'Numbers': {
      'icon': Icons.numbers,
      'gradient': [Color.fromARGB(255, 143, 247, 148), Color.fromARGB(255, 101, 211, 106)],
      'iconColor': Colors.white,
    },
    'Words': {
      'icon': Icons.text_fields,
      'gradient': [Color.fromARGB(255, 255, 171, 54), Color.fromARGB(255, 255, 166, 41)],
      'iconColor': Colors.white,
    },
    'Practice Test': {
      'icon': Icons.school,
      'gradient': [Color.fromARGB(255, 227, 124, 255), Color.fromARGB(255, 135, 95, 160)],
      'iconColor': Colors.white,
    },
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Learn Sign Language',
          style: TextStyle(
            fontSize: 25,
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Choose a Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildCategoryCard(context, 'Alphabets', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearnAlphabets()),
                    );
                  }),
                  _buildCategoryCard(context, 'Numbers', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearnNumbers()),
                    );
                  }),
                  _buildCategoryCard(context, 'Words', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LearnWords()),
                    );
                  }),
                  _buildCategoryCard(context, 'Practice Test', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PracticeTest()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, VoidCallback onTap) {
    final style = categoryStyles[title]!;
    
    return Card(
      elevation: 8,
      shadowColor: style['gradient'][0].withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: style['gradient'],
            ),
            boxShadow: [
              BoxShadow(
                color: style['gradient'][0].withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                style['icon'],
                size: 60,
                color: style['iconColor'],
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: style['iconColor'],
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
