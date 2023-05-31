import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_practice/search_places_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({Key? key}) : super(key: key);

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  var pickUpController=TextEditingController();
  bool cameraMovement=false;

  var dropOffController=TextEditingController();
  final Completer<GoogleMapController> _controller=Completer();
  static const CameraPosition _kGooglePlex =  CameraPosition(
    target: LatLng(25.361064, 68.350958),
    zoom: 14,
  );
  List<LatLng> polylineCoordinates=[];
  final List<Marker> _markers = <Marker> [

    ];
    void getPolyPoints()async{
      PolylinePoints polylinePoints=PolylinePoints();
      PolylineResult result =await polylinePoints.getRouteBetweenCoordinates('AIzaSyCJiLKgEG7tD63lXUD-9OY72XkobajQGbg',
       PointLatLng(latlng[0].latitude,latlng[0].longitude),
        PointLatLng(latlng[1].latitude,latlng[1].longitude));
        if(result.points.isNotEmpty){
          polylineCoordinates=[];
          result.points.forEach((PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude))
          );
        }
        setState(() {

        });
    }
  loadData(){
    getUserCurrentLocation().then((value)async{
      print('My current location');
      print(value.latitude.toString()+' '+value.longitude.toString());
      _markers.add(
          Marker(markerId: MarkerId('1'),draggable: true,
              position:LatLng(value.latitude, value.longitude),
              infoWindow: InfoWindow(
                  title:'My current location'
              ),

          )
      );
      _markers.add(
          Marker(markerId: MarkerId('2'),draggable: true,
            position:LatLng(value.latitude, value.longitude),
            infoWindow: InfoWindow(
                title:'My current location'
            ),

          )
      );

      CameraPosition cameraPosition=CameraPosition(
          zoom:14,
          target: LatLng(value.latitude, value.longitude));
       GoogleMapController controller=await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {
      });
    });

  }
 Future<List<Placemark>> getAddressFromCoordinatesasync(Marker marker)async{
    List<Placemark> placemarks = await placemarkFromCoordinates(marker.position.latitude,marker.position.longitude);
    return placemarks;
  }
  Future<Position> getUserCurrentLocation() async{
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      print(error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  List<LatLng> latlng=[
  LatLng(0, 0),
  LatLng(0, 0),
  ];
  Future<void> updateCameraLocation(
      LatLng source,
      LatLng destination,
      GoogleMapController mapController,
      ) async {
    if (mapController == null) return;

    LatLngBounds bounds;

    if (source.latitude > destination.latitude &&
        source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(source.latitude, destination.longitude),
          northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destination.latitude, source.longitude),
          northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);

    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(
      CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();

    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(cameraUpdate, mapController);
    }
  }
  final Set<Polyline> _polyline={};
  FocusNode _focusNode = FocusNode();
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      body:Stack(
        children: [
          GoogleMap(
            polylines: {
              Polyline(polylineId: PolylineId("route"),points: polylineCoordinates,width: 5)
            },
            zoomControlsEnabled: false,
            initialCameraPosition: _kGooglePlex,
            markers: Set<Marker>.of(_markers),
            onCameraMove: cameraMovement?(CameraPosition position){}:(CameraPosition position){
              setState(() {
                _markers[0] = _markers[0].copyWith(positionParam: position.target);
                _markers[1]=_markers[0];
                latlng[0]=LatLng(_markers[0].position.latitude,_markers[0].position.longitude);
                // _polyline.add(Polyline(polylineId:PolylineId('1'),
                //     color: Colors.orange
                //     ,
                //     points: latlng
                // ));
              });
            },
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },

          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top:10,right:10,left:10),
                  child: Column(
                    children:[
                      TextFormField(
                        controller: pickUpController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                      ),
                      SizedBox(height:5),
                      TextFormField(
                        focusNode: _focusNode,
                        onTap: () async {
                         setState(() {
                           _focusNode.unfocus();
                           cameraMovement=true;
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => SearchPlacesScreen()),
                           ).then((value) async {
                             if (value != null) {
                               _markers[1]=
                                 Marker(
                                   markerId: MarkerId('2'),
                                   draggable: true,
                                   position: LatLng(value['latitude'], value['longitude']),

                               );

                               latlng[1]= LatLng(
                                   _markers[1].position.latitude,
                                   _markers[1].position.longitude
                               );
                               GoogleMapController controller=await _controller.future;
                               await updateCameraLocation(latlng[0], latlng[1],controller) ;
                                 getPolyPoints();
                            


                             }
                           });


                         });
                         setState(() {

                         });
                        },

                        controller: dropOffController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                      )
                    ]
                  ),
                ),
                decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(15)
                  ,color: Colors.teal,
                ),

                height: MediaQuery.of(context).size.height*0.25,

              ),
            ),
          )
        ],
      )

    );
  }
}

