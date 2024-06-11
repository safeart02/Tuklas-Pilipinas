import 'package:flutter/cupertino.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_background/animated_background.dart';
import 'package:audioplayers/audioplayers.dart';
import 'audio_manager.dart'; // Import the AudioManager
import 'dart:async';
import 'dart:io';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuizProvider()..loadFromPreferences(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AudioManager().stop();
    AudioManager().playMainMenuSound();
    return HideNotificationBar(
      child: MaterialApp(
        title: 'Quiz App',
        home: SplashScreen(),
      ),
    );
  }
}

class HideNotificationBar extends StatelessWidget {
  final Widget child;

  HideNotificationBar({required this.child});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    return child;
  }
}

class QuizProvider with ChangeNotifier {
  String _name = '';
  Map<String, int> _scores = {};

  void setName(String name) {
    _name = name;
    notifyListeners();
    _saveToPreferences();
  }

  String get name => _name;

  void setScore(String category, int score) {
    _scores[category] = score;
    notifyListeners();
    _saveToPreferences();
  }

  Map<String, int> get allScores => _scores;

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name);
    prefs.setString('scores', _scores.entries.map((e) => '${e.key}:${e.value}').join(','));
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _scores = Map.fromEntries(
      (prefs.getString('scores') ?? '')
          .split(',')
          .where((e) => e.contains(':'))
          .map((e) {
            final parts = e.split(':');
            return MapEntry(parts[0], int.parse(parts[1]));
          }),
    );
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/TuklasPilipinas_LOGO.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter your name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = _controller.text;
                Provider.of<QuizProvider>(context, listen: false).setName(name);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StartScreen()),
                );
              },
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final name = Provider.of<QuizProvider>(context).name;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background with red color
          Container(
            color: Color(0xFFd92323),
          ),
          // Animated Background
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                spawnMaxRadius: 50,
                spawnMinSpeed: 10.00,
                particleCount: 30,
                spawnMaxSpeed: 50,
                minOpacity: 0.2,
                spawnOpacity: 0.8,
                image: Image.asset('assets/bg/star.png'),
              ),
            ),
            vsync: this,
            child: Container(), // Required child parameter, we can use an empty container
          ),
          // Foreground with buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mabuhay, $name!',
                  style: TextStyle(
                    fontFamily: 'custom_font2',
                    fontSize: 60,
                    color: Colors.white, // Set text color to contrast with background
                  ),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/icons/start_icon.png',
                    width: 800, // Set the width as needed
                    height: 100, // Set the height as needed
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/icons/aboutus_icon.png',
                    width: 800, // Set the width as needed
                    height: 80, // Set the height as needed
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/icons/exit_icon.png',
                    width: 800, // Set the width as needed
                    height: 80, // Set the height as needed
                  ),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}
class _MainMenuState extends State<MainMenu> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final name = Provider.of<QuizProvider>(context).name;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd92323),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MenuSheet(),
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(0xFFd92323),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 50,
            spawnMinSpeed: 10.00,
            particleCount: 30,
            spawnMaxSpeed: 50,
            minOpacity: 0.3,
            spawnOpacity: 0.4,
            image: Image.asset('assets/bg/star.png'),
          )
        ),
        vsync: this,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PUMILI NG KATEGORYA:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WikaKulturaScreen()));
              },
              child: Text('Wika at Kultura'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LarawanLahiScreen()));
              },
              child: Text('Larawan ng Lahi'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LeaderboardsScreen()));
              },
              child: Text('Leaderboards'),
            ),
          ],
        ),
        )
      ),
    );
  }
}

class MenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About us'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.leaderboard),
            title: Text('Leaderboards'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderboardsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class WikaKulturaScreen extends StatefulWidget {
  @override
  _WikaKulturaScreenState createState() => _WikaKulturaScreenState();
}

class _WikaKulturaScreenState extends State<WikaKulturaScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFd92323),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => MenuSheet(),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background with red color
          Container(
            color: Color(0xFFd92323),
          ),
          // Animated Background
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                spawnMaxRadius: 50,
                spawnMinSpeed: 10.00,
                particleCount: 30,
                spawnMaxSpeed: 50,
                minOpacity: 0.2,
                spawnOpacity: 0.8,
                image: Image.asset('assets/bg/star.png'),
              ),
            ),
            vsync: this,
            child: Container(), // Required child parameter, we can use an empty container
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => KasaysayanScreen()));
                  },
                  child: Text('Kasaysayan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TalasalitaanScreen()));
                  },
                  child: Text('Talasalitaan'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GramatikaScreen()));
                  },
                  child: Text('Gramatika'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Soundpool pool = Soundpool(streamType: StreamType.notification);

class KasaysayanScreen extends StatefulWidget {
  @override
  _KasaysayanScreenState createState() => _KasaysayanScreenState();
}

class _KasaysayanScreenState extends State<KasaysayanScreen> {
  @override
  void initState() {
    super.initState();
    // Stop main menu sound and play game sound
    AudioManager().stop();
    AudioManager().playGameSound();
  }

  @override
  Widget build(BuildContext context) {
    return QuizScreen(
      title: '',
      questions: [
        Question('Anong taon dumating ang grupo ng mag Portuguese explorer na si Ferdinand Magellan sa Pilipinas at ang unang pakikipag-ugnayan ng mag Kastila sa mag Katutubong Pilipino.', ['A. Mayo 18, 1521', 'B. Marso 16, 1521', 'C. Mayo 16, 1622', 'D. Abril 17, 1656'], 'B. Marso 16, 1521',''),
        Question('Kailan naganap ang una misa sa Pilipinas noong araw ng Linggo ng Pagkabuhay?', ['A. Enero 4, 1521', 'B. Disyembre 25, 1521', 'C. Mayo 20, 1521', 'D. Marso 31, 1521'], 'D. Marso 31, 1521',''),
        Question('Sa kauna-unahang pagkakataon sino ang nahalal na unang  Pangulo at Pangalawang Pangulo ng Komonwelt sa Pilipinas?', ['A	Manuel L. Quezon at Sergio Osmeña', 'B Apolinario Mabini at Felipe Agoncillo', 'C Apolinario Mabini at Manuel L. Quezon', 'D Miriam Defensor-Santiago at Felipe Agoncillo'], 'A	Manuel L. Quezon at Sergio Osmeña',''),
        Question('Pinatay ang tatlong paring martir na sina Padre Mariano Gomez, Padre Jose Burgos, at Padre Jacinto Zamora o mas kilala bilang GomBurZa.', ['A 1843', 'B 1863', 'C 1872', 'D 1889'], 'C 1872',''),
        Question('Ang pagdeklara ng Batas Militar ni Pangulong Ferdinand Marcos taong?', ['A 1972', 'B 1696', 'C 1562', 'D 1851'], 'A 1972',''),
        Question('Naganap ang EDSA People Power Revolution na nagbunga ng pagbibitiw ni Pangulong Ferdinand Marcos sa kapangyarihan at pag-akyat sa kapangyarihan ni Corazon Aquino.', ['A Pebrero 26, 1986', 'B Pebrero 25, 1986', 'C Enero 20, 1986', 'D Oktobre 25, 1986'], 'B Pebrero 25, 1986',''),
        Question('Itinatag ni Emilio Aguinaldo ang Malolos Congress sa Bulaan idineklara ang kalayaan ng Pilipinas sa Kawit, Cavite.', ['A 1898', 'B 1854', 'C 1897', 'D 1988'], 'A 1898',''),
        Question('Alin sa mag antas ng lipunan ng mga sinaunang Pilipino ang karaniwan at malalayang mamamayan ng barangay?', ['A Timawa', 'B Aliping mamamahay', 'C Maharlika', 'D Maginoo'], 'A Timawa',''),
        Question('Ilang magkakapatid sina Jose Rizal?', ['A 7', 'B 11', 'C 9', 'D 10'], 'B 11',''),
        Question('Sino ang ama ng Balarila ng wikang Pambansa?', ['A Jose Rizal', 'B Manuel L. Quezon', 'C Apolinario Mabini', 'D Lope Santos'], 'D Lope Santos',''),
        Question('Sino ang gumawa ng disenyo para sa watawat ng Pilipinas?', ['A Apolinario Mabini', 'B Felipe Agoncillo', 'C Emilio Aguinaldo', 'D Marcela Agoncillo'], 'C Emilio Aguinaldo',''),
        Question('Sino ang Pangulo na namatay dahil sa pagsabog ng eroplano?', ['A Manuel Quezon', 'B Joseph Estrada', 'C Cory Aquino', 'D Ramon Magsaysay'], 'D Ramon Magsaysay',''),
        Question('Sino ang nagpangalan sa bansang Pilipinas ?', ['A Ruy López de Villalobos', 'B Lapu-Lapu', 'C Ferdinand Magellan', 'D Prince Philip II of Spain'], 'D Prince Philip II of Spain',''),
	      Question('Pinakamatandang lugar sa Pilipinas?', ['A Cavite', 'B Baguio', 'C Davao', 'D Cebu'], 'D Cebu',''),
        Question('Kailan pinunit ng mag Katipunero ang kanilang mag cedula at sabay-sabay na sumigaw labas sa Espanya na ngayon ay kilala bialng Cry of Pugadlawin?', ['A 1896', 'B 1894', 'C 1895', 'D 1899'], 'A 1896',''),
        Question('Ano ang Unang libro na inilabas sa Pilipinas?', ['A Noli Me Tangere', 'B Florante at Laura', 'C Doctrina Christiana', 'D El Filibusterismo'], 'C Doctrina Christiana',''),
        Question('Alin lugar ang Pinakamalawak na Probinsya sa Pilipinas?', ['A Coron', 'B Palawan', 'C San Vicente', 'D El Nido'], 'B Palawan',''),
        Question('Ilang isla ang bumubuo sa Pilipinas?', ['A 7641', 'B 7741', 'C 7504', 'D 7639'], 'A 7641',''),
        Question('Alin ang pinakamalawak na lawa sa Pilipinas ?', ['A Taal Lake', 'B Laguna de Bay', 'C Manila Bay', 'D Lake Mainit'], 'B Laguna de Bay',''),
        Question('Sino ang Lakambini ng Katipunan?', ['A Gregoria de Jesus', 'B Melchora Aquino', 'C Corry Aquino', 'D Teresa Magbanua'], 'A Gregoria de Jesus',''),
      ],
      category: 'Kasaysayan',
    );
  }
}

class TalasalitaanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TalasalitaanQuizScreen(
        questions:  [
          Question('Ano ang kahulugan ng "Charger"?', ['Pampakarga', 'Pantablay', 'Panribal', 'Panlimbag'], 'Pantablay', 'assets/images/charger.png'),
          Question('Ano ang kahulugan ng "Microphone"?', ['Tagapagsalita', 'Salimbibig', 'Himigting', 'Miktinig'], 'Miktinig', 'assets/images/microphone.png'),
          Question('Ano ang kahulugan ng "Hyperlink"?', ['Sugpungan', 'Kawingan', 'Salin-kawing', 'Hatiran'], 'Kawingan', 'assets/images/hyperlink.png'),
          Question('Ano ang kahulugan ng "Thermodynamics"?', ['Init-agos', 'Paningas', 'Initsigan', 'Init-lagaslas'], 'Initsigan', 'assets/images/thermodynamics.png'),
          Question('Ano ang kahulugan ng "Eclipse"?', ['Balasik', 'Liwanag-salikop', 'Silakbo', 'Duyog'], 'Duyog', 'assets/images/eclipse.png'),
          Question('Ano ang kahulugan ng "Arithmetic"?', ['Sipnayan', 'Matematika', 'Bilnuran', 'Pagbilang'], 'Bilnuran', 'assets/images/arithmetic.png'),
          Question('Ano ang kahulugan ng "Mercury"?', ['Tingga', 'Pilak', 'Asoge', 'Parakamang'], 'Asoge', 'assets/images/mercury.png'),
          Question('Ano ang kahulugan ng "Carpenter"?', ['Panday', 'Anluwage', 'Tagakarpintero', 'Bantay-luwad'], 'Anluwage', 'assets/images/carpenter.png'),
          Question('Ano ang kahulugan ng "Bad Odor"?', ['Alingasaw', 'Sulisok', 'Amoy-baho', 'Sanghir'], 'Sanghir', 'assets/images/bad_odor.png'),
          Question('Ano ang kahulugan ng "Car"?', ['Batlag', 'Sasakyan', 'Pandayapak', 'Tumatakbo'], 'Batlag', 'assets/images/car.png'),
          Question('Ano ang kahulugan ng "Telephone"?', ['Linya-pakinig', 'Panagapit', 'Hatinig', 'Sugnay-tinig'], 'Hatinig', 'assets/images/telephone.png'),
          Question('Ano ang kahulugan ng "Farm"?', ['Ilaya', 'Bukirin', 'Sakahan', 'Taniman'], 'Ilaya', 'assets/images/farm.png'),
          Question('Ano ang kahulugan ng "Radio"?', ['Daluyin', 'Tingwirin', 'Pahatirang-tinig', 'Batid-tinig'], 'Tingwirin', 'assets/images/radio.png'),
          Question('Ano ang kahulugan ng "E-mail"?', ['Sulatroniko', 'Pahatid-diwa', 'Elektronikong liham', 'Pagsusulat-daluyan'], 'Sulatroniko', 'assets/images/email.png'),
          Question('Ano ang kahulugan ng "Website"?', ['Pook-Sapot', 'Tanghalan-diwa', 'Batayang-diwa', 'Lambat-sanggunian'], 'Pook-Sapot', 'assets/images/website.png'),
          Question('Ano ang kahulugan ng "Mathematics"?', ['Sipnayan', 'Siyensiya ng bilang', 'Lining sipnayan', 'Matematika'], 'Sipnayan', 'assets/images/mathematics.png'),
          Question('Ano ang kahulugan ng "Infinity"?', ['Walang hangganan', 'Awanggan', 'Hanggang-hanggan', 'Kalawakan'], 'Awanggan', 'assets/images/infinity.png'),
          Question('Ano ang kahulugan ng "Clue"?', ['Palatandaan', 'Tanda-ugnay', 'Himaton', 'Bahid-pahiwatig'], 'Himaton', 'assets/images/clue.png'),
          Question('Ano ang kahulugan ng "Hydraulics"?', ['Daloy-tubig', 'Agos-pwersa', 'Tubig-lakas', 'Danumsigwasan'], 'Danumsigwasan', 'assets/images/hydraulics.png'),
          Question('Ano ang kahulugan ng "Headphones"?', ['Pantinig-bantay', 'Suot-ulo', 'Pang-ulong Hatinig', 'Ulotinig'], 'Pang-ulong Hatinig', 'assets/images/headphones.png'),
        ],
        category: 'Talasalitaan',
      ),
    );
  }
}

class GramatikaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return QuizScreen(
      title: 'Gramatika',
      questions: [
        Question('Karunungang Bayan Question 1', ['A', 'B', 'C', 'D'], 'A',''),
        Question('Karunungang Bayan Question 2', ['A', 'B', 'C', 'D'], 'B',''),
      ],
      category: 'Gramatika',
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String category;

  QuizScreen({required this.title, required this.questions, required this.category});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text(widget.title),
    backgroundColor: Color(0xFFd5BFF00),
  ),
  body: Stack(
    children: [
      // Background image 1
      Image.asset(
        'assets/bg/bg.png', // Path to your first background image
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
      // Background image 2 (transparent)
      Opacity(
        opacity: 1, // Adjust opacity as needed
        child: Image.asset(
          'assets/bg/wirefence.png', // Path to your second background image
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildQuestion(widget.questions[_currentQuestionIndex]),
            SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 20), // Extra space for the Next button and answer options
                  ...buildOptions(widget.questions[_currentQuestionIndex]),
                  SizedBox(height: 20), // Extra space between answer options and Next button
                  buildNextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

  }

  Widget buildQuestion(Question question) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/bg/qs.png', // Your custom PNG image path
          width: 1200, // Adjust width as needed
          height: 200, // Adjust height as needed
          fit: BoxFit.contain,
        ),
        Positioned(
          top: -10,
          child: Container(
            width: 300, // Adjust width as needed
            height: 200, // Adjust height as needed
            child: Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0), // Adjust opacity for transparency
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  question.question,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'custom_font2',
                    fontSize: 20,
                    height: 1.0,
                  ),
                  softWrap: true, // Enable soft wrapping for the text
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildOptions(Question question) {
    return question.options.map((option) {
      return GestureDetector(
        onTap: _selectedAnswer == null
            ? () {
                setState(() {
                  final AudioPlayer player = AudioPlayer();
                  player.play(AssetSource('sounds/select_sfx.mp3'));

                  _selectedAnswer = option;
                  _isCorrect = option == question.correctAnswer;
                });
                _showSnackbar(context, _isCorrect == true);
              }
            : null,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _selectedAnswer == option
                ? (_isCorrect == true ? Color(0xFFFFD625) : Color(0xFFd92323))
                : (option == question.correctAnswer ? Colors.green : Colors.black), // Highlight correct answer
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white,
              width: 6,
            ),
          ),
          child: Text(
            option,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'custom_font2',
              fontSize: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget buildNextButton() {
  
  return TextButton(
  
    onPressed: _selectedAnswer != null
        ? () async {
            int soundId = await rootBundle.load('assets/sounds/next.mp3').then((ByteData soundData) {
                  return pool.load(soundData);
                  });
            int streamId = await pool.play(soundId);
            if (_isCorrect == true) {
              _score++;
              Provider.of<QuizProvider>(context, listen: false)
                  .setScore(widget.category, _score);
            }
            if (_currentQuestionIndex < widget.questions.length - 1) {
              setState(() {
                _currentQuestionIndex++;
                _selectedAnswer = null;
                _isCorrect = null;
              });

              
            } else {
              Navigator.pop(context);
            }
          }
        : null,
    child: Text('Next'),
  );
}



  void _showSnackbar(BuildContext context, bool isCorrect) {
    final snackBar = SnackBar(
      content: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
      backgroundColor: isCorrect ? Colors.black : Colors.red,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}






class TalasalitaanQuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String category;

  TalasalitaanQuizScreen({required this.questions, required this.category});

  @override
  _TalasalitaanQuizScreenState createState() => _TalasalitaanQuizScreenState();
}

class _TalasalitaanQuizScreenState extends State<TalasalitaanQuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool? _isCorrect;
  int _score = 0;

  void _showSnackbar(BuildContext context, bool isCorrect) {
    final snackBar = SnackBar(
      content: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    // Shuffle the list of questions when the screen initializes
    List<Question> shuffledQuestions = List.from(widget.questions)..shuffle();
    // Select only the first 10 questions if there are more than 10
    if (shuffledQuestions.length > 10) {
      shuffledQuestions = shuffledQuestions.sublist(0, 10);
    }
    // Store the shuffled and trimmed questions in a local variable
    List<Question> trimmedQuestions = shuffledQuestions;
    // Now you can use trimmedQuestions in your widget for displaying questions.
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Talasalitaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(question.contextImage),
            Text(question.question, style: TextStyle(fontSize: 24)),
            ...question.options.map((option) => GestureDetector(
              onTap: _selectedAnswer == null ? () {
                setState(() {
                  _selectedAnswer = option;
                  _isCorrect = option == question.correctAnswer;
                });
                _showSnackbar(context, _isCorrect == true);
              } : null,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _selectedAnswer == option
                      ? (_isCorrect == true ? Colors.green : Colors.red)
                      : (option == question.correctAnswer ? Colors.green : Colors.blue), // Highlight correct answer
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(option, style: TextStyle(color: Colors.white)),
              ),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedAnswer != null ? () {
                if (_isCorrect == true) {
                  _score++;
                  Provider.of<QuizProvider>(context, listen: false).setScore(widget.category, _score);
                }
                if (_currentQuestionIndex < widget.questions.length - 1) {
                  setState(() {
                    _currentQuestionIndex++;
                    _selectedAnswer = null;
                    _isCorrect = null;
                  });
                } else {
                  Navigator.pop(context);
                }
              } : null,
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scores = Provider.of<QuizProvider>(context).allScores;
    final name = Provider.of<QuizProvider>(context).name;

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboards'),
      ),
      body: ListView(
        children: scores.entries.map((entry) {
          return ListTile(
            title: Text('Category: ${entry.key}'),
            subtitle: Text('Score: ${entry.value}'),
            trailing: Text(name),
          );
        }).toList(),
      ),
    );
  }
}

class LarawanLahiScreen extends StatefulWidget {
  @override
  _LarawanLahiScreenState createState() => _LarawanLahiScreenState();
}

class _LarawanLahiScreenState extends State<LarawanLahiScreen> {
  int _currentRoundIndex = 0;
  int _score = 0;

  final List<List<String>> _imageSets = [
    ['assets/images/image1.png', 'assets/images/image2.png', 'assets/images/image3.png'],
    ['assets/images/image4.png', 'assets/images/image5.png', 'assets/images/image6.png'],
    ['assets/images/image7.png', 'assets/images/image8.png', 'assets/images/image9.png'],
  ];

  final List<String> _words = ['Word1', 'Word2', 'Word3'];
  final List<int> _correctImageIndices = [0, 1, 2];  // Define correct image index for each round

  String _currentWord = 'Word1';
  int _correctImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentWord = _words[_currentRoundIndex];
    _correctImageIndex = _correctImageIndices[_currentRoundIndex];
  }

  void _nextRound() {
    if (_currentRoundIndex < _imageSets.length - 1) {
      setState(() {
        _currentRoundIndex++;
        _currentWord = _words[_currentRoundIndex];
        _correctImageIndex = _correctImageIndices[_currentRoundIndex];
      });
    } else {
      _showGameOverDialog();
    }
  }

  void _showSnackbar(BuildContext context, bool isCorrect) {
    final snackBar = SnackBar(
      content: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
      backgroundColor: isCorrect ? Colors.green : Colors.red,
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showGameOverDialog() {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.setScore('Larawan ng Lahi', _score);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your score has been saved.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainMenu()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Larawan ng Lahi'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Round ${_currentRoundIndex + 1}: Drag the word to the correct image',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_imageSets[_currentRoundIndex].length, (index) {
              return DragTarget<String>(
                onAccept: (receivedWord) {
                  final isCorrect = receivedWord == _currentWord && index == _correctImageIndex;
                  _showSnackbar(context, isCorrect);
                  if (isCorrect) {
                    setState(() {
                      _score++;
                    });
                  }
                  _nextRound();
                },
                builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Image.asset(_imageSets[_currentRoundIndex][index]),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 40),
          Draggable<String>(
            data: _currentWord,
            child: Text(
              _currentWord,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            feedback: Material(
              color: Colors.transparent,
              child: Text(
                _currentWord,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            childWhenDragging: Container(),
            onDragCompleted: () {
              // You can add logic here if needed when the word is dragged
            },
          ),
        ],
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String contextImage;

  Question(this.question, this.options, this.correctAnswer, this.contextImage);
}
