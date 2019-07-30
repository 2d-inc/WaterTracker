import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'flare_controller.dart';
import 'package:flare_flutter/flare_controls.dart';

class TrackingInput extends StatefulWidget {

  @override
  TrackingState createState() => new TrackingState();

}

class TrackingState extends State<TrackingInput> {

    ///these get set when we build the widget
    double screenWidth = 0.0;
    double screenHeight = 0.0;

    ///let's set up all of the animation controllers
    AnimationControls _flareController;

    final FlareControls plusWaterControls = FlareControls();
    final FlareControls minusWaterControls = FlareControls();

    final FlareControls plusGoalControls = FlareControls();
    final FlareControls minusGoalControls = FlareControls();

    final FlareControls resetDayControls = FlareControls();

    ///the current number of glasses drunk
    int currentWaterCount = 0;

    ///this will come from the selectedGlasses times ouncesPerGlass
    /// we'll use this to calculate the transform of the water fill animation
    int maxWaterCount = 0;

    ///we'll default at 8, but this will change based on user input
    int selectedGlasses = 8;

    ///this doesn't change, hence the 'final', we always count 8 ounces per glass (it's assuming)
    final ouncePerGlass = 8;


  void initState() {
    _flareController = AnimationControls();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///this is a quick reset for the user, to reset the intake back to zero
  void _resetDay() {
    setState(() {
      currentWaterCount = 0;
      _flareController.resetWater();
    });
  }

  ///we'll use this to increase how much water the user has drunk, hooked via button
  void _incrementWater() {
    setState(() {

      if (currentWaterCount < selectedGlasses) {
        currentWaterCount = currentWaterCount + 1;

        double diff = currentWaterCount / selectedGlasses;

        plusWaterControls.play("plus press");

        _flareController.playAnimation("ripple");

        _flareController.updateWaterPercent(diff);
      }

      if (currentWaterCount == selectedGlasses) {
        _flareController.playAnimation("iceboy_win");
      }
    });
  }

  ///we'll use this to decrease our user's water intake, hooked to a button
  void _decrementWater() {
    setState(() {
      if (currentWaterCount > 0) {
        currentWaterCount = currentWaterCount - 1;
        double diff = currentWaterCount / selectedGlasses;

        _flareController.updateWaterPercent(diff);

        _flareController.playAnimation("ripple");
      } else {
        currentWaterCount = 0;
      }
      minusWaterControls.play("minus press");

    });
  }

  ///user will push a button to increase how many glasses they want to drink per day
  void _incrementGoal(StateSetter updateModal) {
    updateModal(() {
      if (selectedGlasses <= 25) {
        selectedGlasses = selectedGlasses + 1;
        calculateMaxOunces();
        plusGoalControls.play("arrow right press");
      }
    });
  }

  ///users will push a button to decrease how many glasses they want to drink per day
  void _decrementGoal(StateSetter updateModal) {
    //setState(() {
    updateModal(() {
      if (selectedGlasses > 0) {
        selectedGlasses = selectedGlasses - 1;
      }
      else {
        selectedGlasses = 0;
      }
      calculateMaxOunces();
      minusGoalControls.play("arrow left press");

    });
  }

  void calculateMaxOunces() {
    maxWaterCount = (selectedGlasses * ouncePerGlass);
  }

    @override
    Widget build(BuildContext context) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      return new Scaffold(
          backgroundColor: Color.fromRGBO(93, 93, 93, 1),
          body: new Container(
            //Stack some widgets
              color: Color.fromRGBO(93, 93, 93, 1),
              child:
              Stack(fit: StackFit.expand, children: [
                new FlareActor("assets/WaterArtboards.flr",
                  controller: _flareController,
                  fit: BoxFit.contain,
                  animation: "iceboy",
                  artboard: "Artboard",
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Spacer(),
                    addWaterBtn(),
                    subWaterBtn(),
                    settingsButton(),
                  ],
                )


              ])

          )
      );
    }

    ///set up our bottom sheet menu
    void _showMenu() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context){
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter updateModal){
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(93, 93, 93, 1),
                  ),
                  child: SizedBox(
                      height: (56 * 6).toDouble(),
                      child: Stack(
                        alignment: Alignment(0, 0),
                        overflow: Overflow.clip,
                        children: <Widget>[
                          baseText(),
                          goalText(),
                          increaseGoalBtn(updateModal),
                          decreaseGoalBtn(updateModal),
                          resetProgressBtn(),
                        ],
                      )
                  ),
                );
              },
            );
          });
    }

  Widget settingsButton() {
    return new RawMaterialButton(
            constraints: BoxConstraints.tight(Size(95, 30)),
            onPressed: _showMenu,
            shape: new Border(),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            elevation: 0.0,
            child: new FlareActor("assets/WaterArtboards.flr",
                fit: BoxFit.contain,
                sizeFromArtboard: true,
                artboard: "UI Ellipse"),

    );
  }

    Widget addWaterBtn() {
      return new RawMaterialButton(
              constraints: BoxConstraints.tight(Size(150, 150)),
              onPressed: _incrementWater,
              shape: new Border(),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              elevation: 0.0,
              child: new FlareActor("assets/WaterArtboards.flr",
                  controller: plusWaterControls,
                  fit: BoxFit.contain,
                  animation: "plus press",
                  sizeFromArtboard: false,
                  artboard: "UI plus"),

      );
    }
  Widget subWaterBtn() {
    return RawMaterialButton(
            constraints: BoxConstraints.tight(Size(150, 150)),
            onPressed: _decrementWater,
            shape: new Border(),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            elevation: 0.0,
            child: new FlareActor("assets/WaterArtboards.flr",
                controller: minusWaterControls,
                fit: BoxFit.contain,
                animation: "minus press",
                sizeFromArtboard: true,
                artboard: "UI minus"),

    );
  }

    Widget increaseGoalBtn(StateSetter updateModal) {
      return Positioned(
        left: screenWidth * .7,
        top: screenHeight * .1,
        child:  new RawMaterialButton(
          constraints: BoxConstraints.tight(Size(95, 85)),
          onPressed: () => _incrementGoal
            (updateModal),
          shape: new Border(),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          elevation: 0.0,
          child: new FlareActor("assets/WaterArtboards.flr",
              controller: plusGoalControls,
              fit: BoxFit.contain,
              animation: "arrow right press",
              sizeFromArtboard: true,
              artboard: "UI arrow right"),
        ),
      );
    }
    Widget decreaseGoalBtn(StateSetter updateModal) {
      return Positioned(
        left: screenWidth * .1,
        top: screenHeight * .1,
        child:  new RawMaterialButton(
          constraints: BoxConstraints.tight(Size(95, 85)),
          onPressed: () => _decrementGoal
            (updateModal),
          shape: new Border(),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          elevation: 0.0,
          child: new FlareActor("assets/WaterArtboards.flr",
              controller: minusGoalControls,
              fit: BoxFit.contain,
              animation: "arrow left press",
              sizeFromArtboard: true,
              artboard: "UI arrow left"),
        ),

      );
    }
    Widget resetProgressBtn() {
      return Positioned(
        left: screenWidth * .42,
        top: screenHeight * .30,
        child:  new RawMaterialButton(
          constraints: BoxConstraints.tight(Size(95, 85)),
          onPressed: _resetDay,
          shape: new Border(),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          elevation: 0.0,
          child: new FlareActor("assets/WaterArtboards.flr",
              controller: resetDayControls,
              fit: BoxFit.contain,
              animation: "Untitled",
              sizeFromArtboard: true,
              artboard: "UI refresh"),
        ),
      );
    }
    Widget goalText() {
      return Positioned(
        left: screenWidth * .48,
        top: screenHeight * .05,
        child: new Text("$selectedGlasses",
          style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white,
              fontSize: 50.0,
              height: 2.00
          ),
          textAlign: TextAlign.center,
        ),


      );
    }
    Widget baseText() {
      return Positioned(
          left: screenWidth * -0.20,
          top: screenHeight * -1.12,
          child: Container(
            width: 600,
            height: 1200,
            child: new FlareActor("assets/WaterArtboards.flr",
                controller: resetDayControls,
                fit: BoxFit.contain,
                sizeFromArtboard: true,
                artboard: "UI text"),
          )


      );
    }
}