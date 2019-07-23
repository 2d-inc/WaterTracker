import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'flare_controller.dart';

class TrackingInput extends StatefulWidget {

  @override
  TrackingState createState() => new TrackingState();

}

class TrackingState extends State<TrackingInput> {

  AnimationControls _flareController;

  ///the current number of glasses drunk
  int currentWaterCount = 0;

  ///this will come from the selectedGlasses times ouncesPerGlass
  /// we'll use this to calculate the transform of the water fill animation
  int maxWaterCount = 0;
  ///we'll default at 8, but this will change based on user input
  int selectedGlasses = 8;
  ///this doesn't change, hence the 'final', we always count 8 ounces per glass (it's assuming)
  final ouncePerGlass = 8;

  ///we'll use this to show the settings UI or hide it from view using a 'Visibility' widget
  bool isTrayOpen = false;

  @override
  void initState() {

    _flareController = AnimationControls();
    _getThingsOnStartup().then((value){
      playOnLoad();
    });
    super.initState();
  }

  @override

  void dispose() {

    super.dispose();

  }
  Future _getThingsOnStartup() async {
    await Future.delayed(Duration(seconds: 4));
  }

  void playOnLoad(){
    _flareController.mixAnimation("ripple");

  }
  ///this is a quick reset for the user, to reset the intake back to zero
  void _resetDay(){
    setState(() {
      currentWaterCount = 0;
      _flareController.resetWater();
      _toggleTray(false);
    });
  }


  ///we'll use this to increase how much water the user has drunk, hooked via button
  void _incrementWater(){
    setState(() {
      if(currentWaterCount < selectedGlasses){
        currentWaterCount = currentWaterCount +1;

        double diff = currentWaterCount/selectedGlasses;

        _flareController.mixAnimation("plus select");
        _flareController.mixAnimation("ripple");

        _flareController.updateWaterPercent(diff);
      }
      if(currentWaterCount == selectedGlasses){
        _flareController.mixAnimation("iceboy_win");
      }

    });

  }

  ///we'll use this to decrease our user's water intake, hooked to a button
  void _decrementWater(){
    setState(() {
      if(currentWaterCount > 0){

        currentWaterCount = currentWaterCount -1;
        double diff = currentWaterCount/selectedGlasses;

        print("new - $diff");
        _flareController.updateWaterPercent(diff);

        _flareController.mixAnimation("ripple");

      }else{
        currentWaterCount = 0;
      }
      _flareController.mixAnimation("minus select");
    });
  }

  ///user will push a button to increase how many glasses they want to drink per day
  void _incrementGoal(){
    setState(() {

      if(selectedGlasses <= 25){
        selectedGlasses = selectedGlasses +1;
        calculateMaxOunces();
        _flareController.mixAnimation("arrow right select");
      }
    });
  }

  ///users will push a button to decrease how many glasses they want to drink per day
  void _decrementGoal(){
    setState(() {
      if(selectedGlasses > 0){
        selectedGlasses = selectedGlasses -1;
      }
      else{
        selectedGlasses = 0;
      }
      calculateMaxOunces();
      _flareController.mixAnimation("arrow left select");
    });
  }

  ///toggle on the settings tray to open or close
  void _toggleTray(bool shouldOpen){
    setState(() {
      if (shouldOpen == false) {
        _flareController.mixAnimation("UI tray down");
        isTrayOpen = false;
      } else {
        _flareController.mixAnimation("UI tray up");
        isTrayOpen = true;
      }
    });
  }

  void calculateMaxOunces(){
    maxWaterCount = (selectedGlasses * ouncePerGlass);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
          //Stack some widgets
            child: Stack(fit: StackFit.expand, children: [
              //The Flare Widget!
              FlareActor("assets/WaterApp.flr",
                  controller: _flareController,
                  fit: BoxFit.contain,
                  animation: "iceboy"
              ),
              Container(
                  child: new Stack(
                      children: <Widget>[
                        new Positioned(
                            left: 167.0,
                            top: 410,
                            child:  new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ///Plus Button
                                  new Container(child: new Visibility(child:
                                  new FlatButton(

                                    onPressed: _incrementWater,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    padding: EdgeInsets.only(top: 50.0),

                                  ),
                                    visible: !isTrayOpen,),width: 80.0, height: 90.0,),
                                  Padding(
                                    padding: EdgeInsets.all(35.0),
                                  ),
                                  ///Minus Button
                                  new Container(child:new Visibility(child: new FlatButton(

                                    onPressed: _decrementWater,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    padding: EdgeInsets.only(top: 50.0),

                                  )
                                    , visible: !isTrayOpen,),width: 80.0, height: 90.0,),
                                  Padding(
                                    padding: EdgeInsets.all(15.0),
                                  ),
                                  ///Our 'Settings' Button
                                  new Container(child:new Visibility(child:
                                  new FlatButton(
                                    onPressed: () => _toggleTray(true),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,

                                  ), visible: !isTrayOpen,),width: 80.0, height: 30.0,),

                                ]
                            )),
                        new Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(120),
                              ),
                              ///Close Tray Button
                              new Container(child:
                              new Visibility(child:
                              new FlatButton(
                                onPressed: () => _toggleTray(false),
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,

                              ),visible: isTrayOpen,),width: 80.0, height: 80.0,),

                              Padding(
                                padding: EdgeInsets.fromLTRB(40, 90, 40, 0),
                              ),
                              Row(children: <Widget>[

                                Padding(
                                  padding: EdgeInsets.fromLTRB(45, 130, 40, 0),
                                ),
                                ///Decrease Goal Button
                                new Container(child: new Visibility(child:new FlatButton(

                                  onPressed: _decrementGoal,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  padding: EdgeInsets.only(top: 6.0),

                                ),
                                    visible: isTrayOpen
                                ),width: 80.0, height: 90.0,),
                                ///Text for how many glasses to drink
                                new Container(child:new Visibility(
                                    child: new Text(" $selectedGlasses ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                          fontSize: 50.0,
                                          height: 2.00
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    visible: isTrayOpen
                                ),width: 70.0, height: 150.0,),
                                ///Increase Goal Button
                                new Container(child:
                                new Visibility(
                                    child:new FlatButton(

                                      onPressed: _incrementGoal,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    visible: isTrayOpen
                                ),width: 80.0, height: 90.0,)
                              ]),

                              Padding(
                                padding: EdgeInsets.all(0.0),
                              ),
                              ///Reset Progress Button
                              new Container(child:
                              new Visibility(child:  new FlatButton(
                                onPressed: _resetDay,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.only(top: 90.0),

                              ),
                                  visible: isTrayOpen
                              ),width: 80.0, height: 65.0,)

                            ])

                      ])
              )
            ])

        )
    );
  }
}
