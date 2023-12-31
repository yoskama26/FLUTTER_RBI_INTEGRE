
// ensembles des lib que j'utilise
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
//import 'package:async/async.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

//définitions du menu pricipale ici qui s'appel "home"
void main() {
  runApp(
    MaterialApp(
      routes: {
        '/home': (BuildContext context) => const Home(),
      },
      debugShowCheckedModeBanner: false,
      home: const FirstScreen(),
    ),
  );
}

//============== Classes ==============


class Connexion extends StatefulWidget {
  const Connexion({Key? key}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class MesFiches extends StatefulWidget {
  const MesFiches({Key? key}) : super(key: key);

  @override
  State<MesFiches> createState() => _MesFichesState();
}

//============ States classes ============
//Création des différentes pages
class _ConnexionState extends State<Connexion> {
  TextEditingController textController = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  String? _deviceIdMatricule;
  String? _deviceId;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //ici on défini la taille et les différentes valeurs que l'on souhaite donner a notre page
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget!),
          maxWidth: 2000,
          minWidth: 1000,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint(breakpoint: 100, name: MOBILE),
          ],
          background: Container(color: Color(0xFFF5F5F5))
      ),
      home: Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Bienvenue !'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                //Chaque Container contient le contenu de l'application ici l'image par exemple ou il faut définir les parametres directement a la création de l'objet
                width: 600,
                height: 540,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/Splash_screen2.PNG"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                controller: textController,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  labelText: 'Entrer votre matricule :',
                ),
              ),
              TextFormField(
                style: TextStyle(color: Colors.black),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                controller: textController2,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black
                  ),
                  labelText: 'Entrer votre mot de passe :',
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return Colors.red; // Use the component's default.
                      },
                    ),
                  ),
                  onPressed: () {
                    _getId();
                  },
                  child: const Text('Go !')
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = await iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = await androidDeviceInfo.androidId; // unique ID on Android
    }
    setState(() => _deviceId = deviceId);

    String matric = textController.text;
    String MDP = textController2.text;
    checkMDP(matric, MDP).then((String result){
      setState(() {
        if(result == "ok") {
          insertUser();
        } else {
          print('Mauvais mdp');
        }
      });
    });
  }
//appel du script pour voir si les mdp correspondes a ceux écrit par rapport au Matricule
  Future<String> checkMDP(MATR, MDP) async {
    final url = Uri.parse('https://outils-casino.fr/checkMDP.php')
        .replace(queryParameters: {
      'MATR': MATR,
      'MDP': MDP,
    });
    http.Response response = await http.get(url);
    var data = jsonDecode(response.body);
    return data;
  }

  Future insertUser() async {
    String monMatricule = textController.text;
    if(monMatricule!='' && monMatricule.length==7) {
      final url = Uri.parse('https://outils-casino.fr/insert.php')
          .replace(queryParameters: {
        'req': "UPDATE users SET id_tel = '$_deviceId' WHERE matricule='$monMatricule'",
      });
      http.Response response = await http.post(url);
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

}
// ici la nouvelle page de séléction de type de magasin



// Ici c'est la page principale du l'app et la classes gerent l'ensemble de l'application (ligne 271 -> 950+)
class _HomeState extends State<Home> {

  List<String> yourListOfOptions = [];
  String selectedResponsableActivite = ""; // Variable pour stocker la valeur sélectionnée
  String uploadEndPoint = 'https://outils-casino.fr/image_upload.php';
  Future<File>? file;
  String status = '';
  String? base64Image;
  File? tmpFile;
  String errMessage = 'Error Uploading Image';
  String? _selectMagasin;
  String? _selectTheme;
  String? _selectResponsable = "Non défini";
  String? _deviceIdMatricule;
  String? _deviceId;
  TextEditingController textController = TextEditingController();
  TextEditingController actionController = TextEditingController();
  int Note = 5;
  String? ID;
  String? mnImage;
  DateTime now = DateTime.now();
  DateTime? selectedDate1;
  DateTime? selectedDate2;
  String? _selectedMagasin;
  @override
  void initState() {
    super.initState();
    // Initialiser selectedDate1 à la date du jour
    selectedDate1 = DateTime.now();

  }
  String currentDate = DateFormat('y-MM-dd').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    if (arguments.isNotEmpty) {
      _selectMagasin = arguments['CM'];
      _selectTheme = arguments['Motif'];
      Note = arguments['Note'];
      ID = arguments['ID'];
      now = DateTime.parse(arguments['Date']);
      currentDate = arguments['Date'];
      textController.text = arguments['Rapport'];
      //tmpFile = File('https://outils-casino.fr/fdvpict/'+);
      mnImage = arguments['Image'];
      actionController.text = arguments['Action'];
      selectedDate2 = DateTime.parse(arguments['Date_Fin']);
      _selectResponsable = arguments['Responsable'];

    }else{
// C'est la que j'essaye de faire en sorte que le magasins reste enregistré
    }
    // en dessous ce trouve l'ensemble de l'affichage du menu principale ou on peut remplir la fiche
    arguments.clear();
    return Scaffold(
      backgroundColor: Color.fromRGBO(255,255,255, 1),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Nouvelle fiche de visite'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_copy_outlined),
            onPressed: () {
              Navigator.push(
                this.context,
                MaterialPageRoute(builder: (context) => MesFiches()),
              );
            },
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getData(
                  'SELECT DISTINCT "test" AS COD_MAG, CONCAT(COD_MAG, " - ", LIB_MAG) AS COD_MAG FROM ref_mag_rbi_actu WHERE COD_BRC = "S" AND COD_MAG LIKE "CS%" ORDER BY LIB_MAG'
                  ,'COD_MAG'
              ),


              builder: (BuildContext context,
                  AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData && snapshot.data != null) {
                  List<String> listeMagasins = [];
                  for (var i = 0; i < snapshot.data.length; i++) {
                    listeMagasins.add(snapshot.data[i].replaceAll("[", "")
                        .replaceAll("]", "")
                    );
                  }
                  return
                    Container(
                      //Ici le choix du magasins
                        height: 30,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectMagasin,
                          onChanged: (String? magasin) {
                            setState(() {
                              _selectMagasin = magasin!;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          hint: Text("Choix Magasin"), // Placeholder
                          items: listeMagasins.map((String value) {
                            return
                              DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.replaceAll('"', '')),
                              );
                          }).toSet().toList(),
                        )
                    );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            FutureBuilder(
              //ici on select dans la table theme-integré pour afficher dans la liste déroulante les différents theme possible
              future: getData('SELECT DISTINCT No_Theme_Sujet FROM theme_integre', 'No_Theme_Sujet'),
              builder: (BuildContext context,
                  AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                  List<String> listeThemes = [];
                  for (var i = 0; i < snapshot.data.length; i++) {
                    listeThemes.add(snapshot.data[i].replaceAll("[", "")
                        .replaceAll("]", "")
                    );
                  }
                  return
                    Container(
                        height: 40,
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectTheme,
                          onChanged: (String? theme) {
                            setState(() {
                              _selectTheme = theme!;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          hint: Text("Choix Thème Contrôle"), // Placeholder
                          items: listeThemes.map((String value) {
                            return
                              DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.replaceAll('"', '').replaceAll(
                                    "_", " ")),
                              );
                          }).toSet().toList(),
                        )
                    );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            // Ici c'est la gestion de la photos avec l'image de rubis cube au centre
            if(tmpFile != null)
              Container(
                width: 320,
                height: 160,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(tmpFile!),
                  ),
                ),
              )
            else if(tmpFile == null && mnImage == null)
              GestureDetector(
                onTap: () => getImage(source: ImageSource.camera),
                child: Container(
                  width: 320,
                  height: 160,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/Splash_screen.PNG"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if(tmpFile == null && mnImage != null)
              Container(
                width: 320,
                height: 160,
                alignment: Alignment.center,
                child: Image.network('https://outils-casino.fr/fdvpict/'+mnImage.toString()),
              ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              // Ici la zone de texte d'observation
              controller: textController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                focusColor: Colors.red,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                hintText: 'Observations', // Le texte indicatif
              ),
              minLines: 1,
              keyboardType: TextInputType.multiline,
              maxLines: 20,
            ),
            Row(
              // Row permet de faire comprendre a l'application que l'ont souhaite mettre les bouton/elements a coté les uns des autres et pas en dessous (row = colonnes)
              children: [
                Expanded(
                  child: Container(
                    // ici on donne la note
                    alignment: Alignment.center,
                    child: Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _itemCountDecrease(),
                          ),
                          const SizedBox(width: 15,),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                Note = 11;
                              });
                            },
                            // ici c'est si la note est egal a 11 l'affichage montre ø a la place et plus tard en dessous je change la valeur de 11
                            child: Note == 11 ? Text("Ø") : Text(Note.toString()),
                          ),
                          const SizedBox(width: 15,),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _itemCountIncrease(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                const SizedBox(width: 20,),
                Expanded(
                  //ici c'est la date
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: Colors.red,
                        iconSize: 30,
                        onPressed: () {
                          _selectDate(context, 1); // Utilisez 1 pour le premier calendrier
                        },
                      ),
                      Text('Contrôle du ${selectedDate1 != null ? DateFormat('dd/MM/yyyy').format(selectedDate1!) : DateFormat('dd/MM/yyyy').format(DateTime.now())}'),


                    ],
                  ),
                ),
              ],
            ),



            Row(
              children: [
                Expanded(
                  //Ici on fait un appel au téléphone pour lui demander d'utiliser la caméra du tel si besoin (bouton appareil photo)
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red;
                            }
                            return Colors.red; // Use the component's default.
                          },
                        ),
                      ),
                      onPressed: () => getImage(source: ImageSource.camera),
                      child: const Text(
                          'Appareil photo', style: TextStyle(fontSize: 18))
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  // Pareil que pour l'apareil photo sauf que cette fois on demande l'acces a la galerie du téléphone
                  child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.red;
                            return Colors.red; // Use the component's default.
                          },
                        ),
                      ),
                      onPressed: () => getImage(source: ImageSource.gallery),
                      child: const Text(
                          'Galerie', style: TextStyle(fontSize: 18))
                  ),
                )
              ],
            ),
            Row(
              //ici c'est juste le texte de choix responsable au dessus car ne pouvant pas l'utiliser en placeholder
                children: [
                  const SizedBox(width: 20,),
                  Text("\nChoix responsable :"),
                ]

            ),
            Row(
              children: [
                const SizedBox(width: 20,),

                Expanded(
                  // et la c'est le menu déroulant du choix responsable avec une valeur par défaut

                  child: FutureBuilder(
                    future: getData('SELECT DISTINCT `RESP_ACT` from int_liste_resp_act ORDER BY ORDRE', 'RESP_ACT'),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                        List<String> listeThemes = [];
                        for (var i = 0; i < snapshot.data.length; i++) {
                          listeThemes.add(snapshot.data[i].replaceAll("[", "").replaceAll("]", ""));
                        }
                        return Container(
                          height: 40,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectResponsable,
                            onChanged: (String? theme) {
                              setState(() {
                                _selectResponsable = theme!;
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                            hint: Text("Choix Responsable"), // Placeholder
                            items: listeThemes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value.replaceAll('"', '').replaceAll("_", " ")),
                              );
                            }).toSet().toList(),
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),

                Expanded(
                  // Encore le choix de date
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: Colors.red,
                        iconSize: 30,
                        onPressed: () {
                          _selectDate(context, 2); // Utilisez 2 pour le deuxième calendrier
                        },
                      ),
                      Text('Fin Actions'
                          ' ${selectedDate2 != null ? DateFormat('dd/MM/yyyy').format(selectedDate2!) : ''}'),
                    ],
                  ),
                ),


              ],
            ),
// ici une zone de texte pour Actions
            TextFormField(
              controller: actionController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                focusColor: Colors.red,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                hintText: 'Actions', // Le texte indicatif
              ),
              minLines: 1,
              keyboardType: TextInputType.multiline,
              maxLines: 20,
            ),


            Row(
              // enfin ici le bouton enregistrer qui envoi les données
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          return Colors.red; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () => {
                      uploadFile(ID, tmpFile),
                      _getId()
                    },
                    child: const Text(
                        'Enregistrer', style: TextStyle(fontSize: 18)
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, int calendarNumber) async {

    DateTime? pickedDate = await showDatePicker(
      initialDate: calendarNumber == 1 ? selectedDate1 ?? DateTime.now() : selectedDate2 ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2050),
      context: context,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.grey,
            splashColor: Colors.black,
            textTheme: const TextTheme(
              subtitle1: TextStyle(color: Colors.black),
              button: TextStyle(color: Colors.black),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent,
              primaryVariant: Colors.black,
              secondaryVariant: Colors.black,
              onSecondary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.black,
              secondary: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child ?? Text(""),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (calendarNumber == 1) {
          selectedDate1 = pickedDate;
        } else {
          selectedDate2 = pickedDate;
        }
      });
    }
  }


  void getImage({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 60,
    );
    setState(() {
      tmpFile = File(file!.path);
    });
  }

  Future insertData(monImage) async {

    // Ici c'est la manipulation et la mise en forme des données entré précedement

    actionController.text ??= 'R.A.S';
    textController.text ??= 'R.A.S';


    String monComm2 = actionController.text;
    String monMag = _selectMagasin!.substring(0, 5);
    String monMotif = _selectTheme!.replaceAll('"', '');
    String monResponsable = _selectResponsable!.replaceAll('"', '');
    String monComm = textController.text;
    // ici par exemple je transforme la note qui été un "Entier" en chaine de caractere afin de pouvoir mettre a la a ø deux lignes en dessous
    String maNote = Note.toString();

    if(maNote == '11'){
      maNote = 'ø';
    }
    // Ici je défini la date de base
    selectedDate2 ??= DateTime(0, 0, 0);

    String dateVisite = DateFormat('y-MM-dd').format(selectedDate1!);
    String dateFin = DateFormat('y-MM-dd').format(selectedDate2!);

    if (selectedDate2!.isBefore(DateTime(1, 11, 30)) || selectedDate2!.isAtSameMomentAs(DateTime(1, 11, 30))) {
      dateFin = '0000-00-00';
    }

    if (selectedDate1!.isBefore(DateTime(1, 11, 30)) || selectedDate1!.isAtSameMomentAs(DateTime(1, 11, 30))) {
      dateVisite = '0000-00-00';
    }

    // Ici c'est la requetes SQL qu'on envoi directement au serveur pour mettre a jour l'application
    final url = Uri.parse('https://outils-casino.fr/insert.php')
        .replace(queryParameters: {
      'req': "INSERT INTO fiche_visite_integre (Code_CM, Motif_Visite, Matricule_creation, Rapport_Visite, IMAGE_1, NOTE_1, Date_Visite, Responsable, Action, Date_Fin, Compilation) VALUES ('$monMag', '$monMotif', '$_deviceIdMatricule', '$monComm', '$monImage', '$maNote', '$dateVisite', '$monResponsable', '$monComm2', '$dateFin', '0')",
    });
    http.Response response = await http.post(url);
  }

  Future updateData(id, [fileP]) async {
    // et Ici c'est exactement comme en haut sauf que c'est pour la modifications des fiches

    actionController.text ??= 'vide';
    textController.text ??= 'vide';

    String monMag = _selectMagasin!.substring(0, 5);
    String monMotif = _selectTheme!.replaceAll('"', '');
    String monResponsable = _selectResponsable!.replaceAll('"', '');
    String monComm = textController.text;
    String monComm2 = actionController.text;

    String maNote = Note.toString();
    if(maNote == '11'){
      maNote = 'ø';
    }

    selectedDate2 ??= DateTime(0, 0, 0);

    String dateVisite = DateFormat('y-MM-dd').format(selectedDate1!);
    String dateFin = DateFormat('y-MM-dd').format(selectedDate2!);

    if (selectedDate2!.isBefore(DateTime(1, 11, 30)) || selectedDate2!.isAtSameMomentAs(DateTime(1, 11, 30))) {
      dateFin = '0000-00-00';
    }

    if (selectedDate1!.isBefore(DateTime(1, 11, 30)) || selectedDate1!.isAtSameMomentAs(DateTime(1, 11, 30))) {
      dateVisite = '0000-00-00';
    }

    String? monImage = "";
    if(fileP!=null) {
      monImage = "IMAGE_1 = '$fileP',";
    }
    final url = Uri.parse('https://outils-casino.fr/insert.php')
        .replace(
        queryParameters: {
          'req': "UPDATE fiche_visite_integre SET Code_CM = '$monMag', Motif_Visite = '$monMotif', Matricule_Modif = '$_deviceIdMatricule', $monImage Rapport_Visite = '$monComm', NOTE_1 = '$maNote', Date_Visite = '$dateVisite', Responsable = '$monResponsable', Action = '$monComm2', Date_Fin = '$dateFin' WHERE ID = '$id'",
        }
    );
    http.Response response = await http.post(url);
  }

  void uploadFile(id, filePath) async {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 80,
            width: 200,
            margin: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                Text("   Enregistrement en cours"),
              ],
            ),
          ),
        );
      },
    );
// ici c'est le check de tout ce qui est obligatoire dans notre cas : le mag, le theme, la date et le responsable (mais qui en a un par défaut)
    if (_selectMagasin != null && _selectTheme != null && selectedDate1 != null && _selectResponsable != null) {
      String fileName = filePath != null ? "fdvrbs_" + basename(filePath.path) : "";

      try {
        FormData formData = FormData();
        if (filePath != null) {
          formData = FormData.fromMap({
            "file": await MultipartFile.fromFile(filePath.path, filename: fileName),
          });
        }

        Response response = await Dio().post(
          "https://outils-casino.fr/image_upload.php",
          data: formData,
        );

        if (id == null) {
          insertData(fileName);
        } else {
          updateData(id, fileName);
        }

        showDialog(
          barrierDismissible: false,
          context: this.context,
          builder: (context) => AlertDialog(
            title: Text('Chargement...'),
            content: Text('Fiche modifiée !'),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return Colors.red; // Use the component's default.
                    },
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                child: Text('Ok'),
              )
            ],
          ),
        );
      } catch (e) {
        print("exception caught: $e");
      }
    } else {
      showDialog(
        barrierDismissible: false,
        context: this.context,
        builder: (context) => AlertDialog(
          title: Text('Chargement...'),
          content: Text('Veuillez renseigner un magasin et un theme au minimum...'),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.red; // Use the component's default.
                  },
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Text('Ok'),
            )
          ],
        ),
      );
    }
  }


  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = await iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = await androidDeviceInfo.androidId; // unique ID on Android
    }
    String matric = (await getData("SELECT DISTINCT matricule FROM users WHERE id_tel='$deviceId'", 'matricule')).first.replaceAll('"', '');
    setState(() => _deviceIdMatricule = matric);
    setState(() => _deviceId = deviceId);
  }
  _itemCountIncrease() {
    setState(() {
      if (Note < 10) {
        Note += 1;
      }
    });
  }
  _itemCountDecrease() {
    setState(() {
      if (Note > 0) {
        Note -= 1;
      }
    });
  }
}

class _FirstScreenState extends State<FirstScreen> {
  TextEditingController textController = TextEditingController();
  TextEditingController actionController = TextEditingController();
  String? _deviceIdMatricule;
  String? _deviceId2;



  @override
  Widget build(BuildContext context) {
    // Ici c'est l'affichage de la page de connexion
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget!),
          maxWidth: 2000,
          minWidth: 1000,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint(breakpoint: 100, name: MOBILE),
          ],
          background: Container(color: Color(0xFFF5F5F5))
      ),
      home: Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 600,
                height: 450,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/Splash_screen.PNG"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text('Version 1.0.5'),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return Colors.red; // Use the component's default.
                      },
                    ),
                  ),
                  onPressed: () {
                    _getId();
                  },
                  child: const Text('Connexion')
              ),


            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = await iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = await androidDeviceInfo.androidId; // unique ID on Android
    }
    List ListIdPhone = (await getData("SELECT DISTINCT id_tel FROM users", 'id_tel'));
    setState(() => _deviceId2 = deviceId);

    if(ListIdPhone.contains(deviceId)) {
      String matric = (await getData("SELECT DISTINCT matricule FROM users WHERE id_tel='$deviceId'", 'matricule')).first.replaceAll('"', '');
      setState(() => _deviceIdMatricule = matric);
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    return matric;
    } else {
      Navigator.push(
        this.context,
        MaterialPageRoute(builder: (context) => Connexion()),
      );
    }
  }
}

class _MesFichesState extends State<MesFiches> {
  String? _selectedMagasin;
  String? _selectedMotif;
  String? _selectedImage;
  String? _selectedRapport;
  String? _selectedNote;
  String? _selectedID;
  int? _selectedNoteInt;
  String? _selectedDate;
  String? _selectedDateFin;
  String? _selectedAction;
  String? _selectedResponsable;
  String? _deviceIdMatricule;
  String? _deviceId;

  @override
  Widget build(BuildContext context) {
    //Ici c'est l'affichage du menu édition
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget!),
          maxWidth: 10000,
          minWidth: 10000,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint(breakpoint: 500, name: MOBILE),
          ],
          background: Container(color: Color(0xFFF5F5F5))
      ),
      home: Scaffold(
        backgroundColor: Color.fromRGBO(255,255,255, 1),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.add_a_photo_outlined),
              onPressed: () {
                Navigator.push(
                  this.context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
          ],
          title: const Text('Mes visites'),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder(
            future: getData('SELECT DISTINCT fiche_visite_integre.*, ref_mag_rbi_actu.LIB_MAG FROM fiche_visite_integre, ref_mag_rbi_actu WHERE fiche_visite_integre.Code_CM = ref_mag_rbi_actu.COD_MAG', '*'),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                List<dynamic> _mesColones = snapshot.data;
                List<DataRow> rows = [];
                for (var i = 0; i < _mesColones.length; i++) {
                  rows.add(DataRow(cells: [
                    DataCell(
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  child: Image.network('https://outils-casino.fr/fdvpict/'+_mesColones[i]['IMAGE_1'].toString()),
                                );
                              }
                          );
                        },
                        icon: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        onPressed: () {
                          setState(() => {
                            _selectedMagasin = _mesColones[i]['Code_CM']+" - "+_mesColones[i]['LIB_MAG'].toString(),
                            _selectedMotif = _mesColones[i]['Motif_Visite'].toString(),
                            _selectedImage = _mesColones[i]['IMAGE_1'].toString(),
                            _selectedRapport = _mesColones[i]['Rapport_Visite'].toString(),
                            _selectedID = _mesColones[i]['ID'].toString(),
                            _selectedNote = _mesColones[i]['NOTE_1'].toString(),
                            _selectedNoteInt = int.parse(_selectedNote!),
                            _selectedDate = _mesColones[i]['Date_Visite'].toString(),
                            _selectedAction = _mesColones[i]['Action'].toString(),
                            _selectedDateFin = _mesColones[i]['Date_Fin'].toString(),
                            _selectedResponsable = _mesColones[i]['Responsable'].toString(),



                          });
                          //Navigator.push(
                          //this.context,
                          //MaterialPageRoute(builder: (context) => Home()),
                          _modifierFiche(_selectedID, _selectedMagasin, _selectedMotif, _selectedImage, _selectedRapport, _selectedNoteInt, _selectedDate,_selectedAction, _selectedDateFin,_selectedResponsable);
                          //);
                        },
                        icon: const Icon(
                          Icons.mode_edit_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Code_CM'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['LIB_MAG'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Motif_Visite'].replaceAll('_', ' ').toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Date_Visite'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['NOTE_1'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Rapport_Visite'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Action'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Date_Fin'].toString()),
                    ),
                    DataCell(
                      Text(_mesColones[i]['Responsable'].replaceAll('_', ' ').toString()),
                    ),

                  ]));
                }

                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //child: _getData01(_mesColones, context)
                    child: DataTable(
                      columnSpacing: 30.0,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Afficher',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Editer',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Code CM',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Magasin',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Motif',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Note',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Commentaire',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Action',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Date_Fin',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Responsable',
                            style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                          ),
                        ),

                      ],
                      rows: rows,
                    ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
  void _modifierFiche(id, cm, motif, image, rapport, note, date, action, datefin, responsable) async {
    Navigator.pushNamed(this.context, '/home',
        arguments: {
          "ID":  id,
          "CM":  cm,
          "Motif": motif,
          "Image": image,
          "Rapport": rapport,
          "Note": note,
          "Date": date,
          "Action": action,
          "Date_Fin": datefin,
          "Responsable": responsable,


        }
    );
  }
}

//=========== Global functions ===========
Future<List> getData(maReq, maData) async {
  final url = Uri.parse('https://outils-casino.fr//SelectTest.php')
      .replace(queryParameters: {
    'req': maReq,
    'data': maData,
  });
  http.Response response = await http.get(url);
  var data = jsonDecode(response.body);
  return data;
}