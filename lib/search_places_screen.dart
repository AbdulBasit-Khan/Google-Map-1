import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:google_map_practice/book_ride_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  TextEditingController _controller=TextEditingController();
  var uuid=Uuid();
  String _sessionToken='1234';
  List<dynamic> placesList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      onChange();
    });

  }
  void onChange(){
    if(_sessionToken==null){
      setState(() {
        _sessionToken=uuid.v4();
      });
    }
    getSuggestion(_controller.text);
  }
  void getSuggestion(String input)async{
    String kPLACES_API_KEY="AIzaSyCJiLKgEG7tD63lXUD-9OY72XkobajQGbg";
    String baseURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken';
    var response =await http.get(Uri.parse(request));
    var data=response.body.toString();

    print(response.body.toString());
    if(response.statusCode==200 && mounted) {
      setState(() {
        placesList=jsonDecode(response.body.toString())['predictions'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Google Search Places Api'),

      ),
      body:Padding(padding: const EdgeInsets.symmetric(vertical:12),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                  hintText: 'Search places with name'
              ),
            ),
            Expanded(child: ListView.builder(itemCount:placesList.length,itemBuilder: (context,index){
              return ListTile(
                  onTap: ()async{
                      List<Location> locations = await locationFromAddress(placesList[index]['description']);
                        double latitude = locations.first.latitude!;
                        double longitude = locations.first.longitude!;
                        Navigator.pop(context, {'latitude': latitude, 'longitude': longitude});
                                     },
                  title:Text(placesList[index]['description'])
              );
            }))
          ],
        ),
      ),

    );
  }
  }

