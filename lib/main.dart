import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future <void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
  
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

bool overlay = false;
bool tooltip = false;
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
   Set<Heatmap> _heatmaps = {};
   Set<Marker> _markers ={};
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(1.2847, 103.8610),
    zoom: 14.4746,
  );
  LatLng _heatmapLocation = LatLng(1.2847, 103.8610);
  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Going Out?', 'Remember to bring your mask!', platformChannelSpecifics,
        payload: 'item x');
  }


  

  





  @override
  Widget build(BuildContext context) {

  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;
    return new Scaffold(
     
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            heatmaps: _heatmaps,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          Positioned(
            right: width*0.05,
            top: width*0.1,
            child: IconButton(tooltip:'Test',
            color: Colors.white,

            icon: Icon(Icons.info, color: Colors.black,) , onPressed: _removetooltip )

            ),
            Positioned(
              right: width*0.2, top: height*0.06,child: SizedBox(height: height*0.1,width: width*0.2,child: 
            Visibility(
              visible: tooltip ,
                          child: ClipRRect(borderRadius: BorderRadius.circular(20),child:
              Opacity(opacity: 0.6,child: Container(color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: width*0.02,),
                      SizedBox(width: width*0.18, child: Opacity(opacity: 1,child: Text(" The Least Crowded Area is Marina Square", style: TextStyle(color: Colors.white, fontSize: 10),))),
                    ],
                  ),
                ],
              ),
              ))
              ),
            )
            ,))

        ]),
          
      
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(opacity: 0.0,child: FloatingActionButton.extended(label:Text("test"),onPressed:_removeoverlay)),
          FloatingActionButton.extended(
            onPressed: _addHeatmap,
            label: Text('Add Heatmap'),
            icon: Icon(Icons.add_box),
          ),
          Opacity( opacity: 0.0,
           child: FloatingActionButton.extended(onPressed: ()async{ await _showNotification();} , label: Text('MQTT')))
        ],
      ),


    );
  }
  void _addHeatmap(){
    setState(() {
      markersadd();
      _heatmaps.add(
        Heatmap(
          heatmapId: HeatmapId(_heatmapLocation.toString()),
          points: _createPoints(_heatmapLocation),
          radius: 50,
          visible: true,
          gradient:  HeatmapGradient(
            colors: <Color>[Colors.green, Colors.red], startPoints: <double>[0.5, 0.6]
          )
        )
      );
    });
  }

  void _removetooltip(){
    setState(() {
      tooltip = !tooltip;
    });
  }

  void _removeoverlay()
  {
    setState(() {
       _heatmaps={};
       _markers={};
    });
  }

  void markersadd()
  {
    setState(() {

      _markers.add(_createmarker(1.2847,103.8610, "Marina Bay","Very Crowded"));
      _markers.add(_createmarker(1.2842,103.8511, "One Raffles Place","Very Crowded"));
      _markers.add(_createmarker(1.2803,103.8543,"Marina Bay Link Mall","Very Crowded"));
      _markers.add(_createmarker(1.2938,103.8534,"Raffles City","Very Crowded"));
      _markers.add( _createmarker(1.293494,103.857170, "Suntec City","Very Crowded"));
      _markers.add( _createmarker(1.2928,103.8598 ,"Milenia Walk","Very Crowded"));
      _markers.add(_createmarker(1.2912,103.8577, "Marina Square","Moderately Crowded"));
      
      
    });
  }

  Marker _createmarker(double latt,double lng, String title, String level){
    var rng = new Random();
    String id = rng.nextInt(10000).toString();
    LatLng lat = LatLng(latt, lng);
    return Marker(markerId: MarkerId(id), position: lat, infoWindow: InfoWindow(title: title, snippet: level));


  }

  LatLng _createlatlng(double lat, double lng)
  {
    return LatLng(lat, lng);
  }

  //heatmap generation helper functions
  List<WeightedLatLng> _createPoints(LatLng location) {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    //Can create multiple points here
    points.add(_createWeightedLatLng(location.latitude,location.longitude, 3));
    points.add(_createWeightedLatLng(1.2912,103.8577, 2)); 
    points.add(_createWeightedLatLng(1.293494,103.857170, 3));
    points.add(_createWeightedLatLng(1.2842,103.8511, 3));
    points.add(_createWeightedLatLng(1.2803,103.8543, 3));
    points.add(_createWeightedLatLng(1.2938,103.8534, 3));
    points.add(_createWeightedLatLng(1.2928,103.8598, 3));


    return points;
  }

  WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
    return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  }

 
}
