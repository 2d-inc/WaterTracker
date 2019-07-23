import 'dart:math';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';

class AnimationControls extends FlareController {
  FlutterActorArtboard _artboard;

  ActorAnimation _fillAnimation;
  ActorAnimation _iceboyMoveY;

  final List<FlareAnimationLayer> _baseAnimations = [];

  String _animationName;

  double _waterFill = 0.00;
  double _currentWaterFill = 0;

  double _smoothTime = 5;

  void initialize(FlutterActorArtboard artboard) {
    _artboard = artboard;
    _fillAnimation = artboard.getAnimation("water up");
    _iceboyMoveY = artboard.getAnimation("iceboy_move_up");

  }

  void setViewTransform(Mat2D viewTransform) {}

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    //we need this separate from our generic mixing animations,
    // b/c the animation duration is needed in this calculation
    _currentWaterFill += (_waterFill-_currentWaterFill) * min(1, elapsed * _smoothTime);
    _fillAnimation.apply( _currentWaterFill * _fillAnimation.duration, artboard, 1);
    _iceboyMoveY.apply(_currentWaterFill * _iceboyMoveY.duration, artboard, 1);


    int len = _baseAnimations.length - 1;
    for (int i = len; i >= 0; i--) {
      FlareAnimationLayer layer = _baseAnimations[i];
      layer.time += elapsed;
      layer.mix = min(1.0, layer.time / 0.01);
      layer.apply(artboard);

      if (layer.isDone) {
        _baseAnimations.removeAt(i);
      }
    }
    return true;
  }

  void mixAnimation(String animName){
    ActorAnimation animation = _artboard.getAnimation(animName);

    if (animation != null) {
      _baseAnimations.add(FlareAnimationLayer()
        ..name = _animationName
        ..animation = animation
      );
    }

  }
  void mixAnimationOverride(String animName, double time){
    ActorAnimation animation = _artboard.getAnimation(animName);

    if (animation != null) {
      _baseAnimations.add(FlareAnimationLayer()
        ..time = time
        ..name = _animationName
        ..animation = animation
        ..mix = 1);
    }

  }
  void updateWaterPercent(double amt){

    //TODO: ask Luigi: why no loop? mixAnimation("iceboy");
    _waterFill = amt;

  }
  void resetWater(){

    _waterFill = 0;
  }

}
