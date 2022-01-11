import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const MaterialApp(
    title: "MyClock App",
    debugShowCheckedModeBanner: false,
    home:MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  TimeOfDay _timeOfDay = TimeOfDay.now();
  var currentTime;
  var time;
  var day;
  var month ;
  var weekDay;
  var timeZoneDetails;

  List<String> timeZonesHHMM=[];
  @override
  void initState() {

    currentTime = DateTime.now();
    getIST_Details(currentTime);
    setTimeZoneDetails(currentTime);

    super.initState();

    Timer.periodic(Duration(seconds: 1),(timer){
      if(_timeOfDay.minute!=TimeOfDay.now().minute)
      {
        setState(() {
          currentTime = DateTime.now();
          getIST_Details(currentTime);
          setTimeZoneDetails(currentTime);
        });
      }
    });
  }

  //Retrieving the Current Timezone Details
  getIST_Details(var currentTime)
  {
    setState(() {
      time = DateFormat("hh:mm a").format(currentTime);
      weekDay = DateFormat('EEEE').format(currentTime);
      day = DateFormat('d').format(currentTime);
      month = DateFormat('MMMM').format(currentTime);
    });
  }


  //Coverts IST to other TimeZones
  void setTimeZoneDetails(var currentTime)
  {
    var temp_timeZoneDetails={};
    var listed_zones = {
      "Los Angeles":["-13:30"],
      "New York":["-10:30"],
      "Singapore":["+02:30"],
      "London":["-05:30"],
      "Rio de Janerio":["-08:30"],
    };

    var timeZoneNames = listed_zones.keys.toList();

    for(int i=0;i<listed_zones.length;i++)
    {
      var delayOrAheadTime=(listed_zones[timeZoneNames[i]]as List)[0];
      List time = delayOrAheadTime.substring(1,).split(':');
      var timeHours = int.parse(time[0]);
      var timeMinutes = int.parse(time[1]);
      int constant = 1;
      String timeDifferenceMessage="";

      if(timeHours>0) {
        timeDifferenceMessage+= timeHours.toString()+"hr ";
      }
      if(timeMinutes>0) {
        timeDifferenceMessage+= timeMinutes.toString()+"min ";
      }

      if(delayOrAheadTime.startsWith('-'))
      {
        constant = -1;
        timeDifferenceMessage+= "behind";
      }
      else
      {
        timeDifferenceMessage+= "ahead";
      }

      var regionTime = currentTime.add(Duration(hours: timeHours*constant,minutes: timeMinutes*constant));
      //removing addtional string content from regionTime(2022-01-10 11:23:54.294195) (to)===> regionTime(2022-01-10 11:23:55)
      regionTime = DateTime.parse(regionTime.toString().split('.')[0]);

      var regionTimeFormated = DateFormat("hh:mm a").format(regionTime);

      temp_timeZoneDetails[timeZoneNames[i]]=[regionTimeFormated.toString(),timeDifferenceMessage];
    }//for loop end

    setState(() {
      timeZoneDetails = temp_timeZoneDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    var timeZoneNames = timeZoneDetails.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Clock",style: TextStyle(fontSize: 20),),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF505050),
        actions: [
          PopupMenuButton<String>(
            onSelected: (title)  { setTimeZoneDetails(DateTime.now()); },
            itemBuilder: (context)=>[
              PopupMenuItem<String>(
                value:"Options",
                child: Text("Click Here"),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFF505050),
      body: Column(
        children: [
          // Time and offset
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(time.split(' ')[0].split(':').join(' : '),style: TextStyle(fontSize: 50,color: Colors.blueAccent ),),
                ),
                Container(
                  margin: EdgeInsets.only(top:size.height*0.02),
                  child: Text(time.split(' ')[1].toString().toLowerCase(),style: TextStyle(fontSize: 20,color: Colors.blueAccent ),),
                ),
              ],
            ),
          ),

          //Day, Date, Month
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Text(weekDay.substring(0,3)+", "+day+" "+month.substring(0,3),
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
          ),

          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: size.width*0.05),
            child: Divider(
              color: Colors.white,
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: timeZoneNames.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context,index)=>Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Region, time ahead/behind
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          SizedBox(
                              width:size.width*0.4,
                              child: Text(timeZoneNames[index],style: TextStyle(fontSize: 20,color: Colors.white),)
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                              width:size.width*0.4,
                              child: Text(timeZoneDetails[timeZoneNames[index]][1],style: TextStyle(fontSize: 12,color: Colors.white),)),
                        ],
                      ),
                    ),

                    //Time and am/pm
                    Container(
                      child: Row(
                          children: [
                            Container(
                                alignment:Alignment.topRight,
                                child: Text(
                                  timeZoneDetails[timeZoneNames[index]][0],
                                  style: TextStyle(fontSize: 35,color: Colors.white),)
                            ),
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
