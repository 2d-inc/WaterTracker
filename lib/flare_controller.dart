import 'dart:math';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';

class AnimationControls extends FlareController {
  ///so we can reference this any where once we declare it
  FlutterActorArtboard _artboard;

  ///our fill animation, so we can animate this each time we add/reduce water intake
  ActorAnimation _fillAnimation;

  ///our ice cube that moves on the Y Axis based on current water intake
  ActorAnimation _iceboyMoveY;

  ///used for mixing animations
  final List<FlareAnimationLayer> _baseAnimations = [];

  ///our overall fill
  double _waterFill = 0.00;

  ///current amount of water consumed
  double _currentWaterFill = 0;

  ///time used to smooth the fill line movement
  double _smoothTime = 5;

  void initialize(FlutterActorArtboard artboard) {
    //get the reference here on start to our animations and artboard

    if (artboard.name.compareTo("Artboard") == 0) {
      _artboard = artboard;

      _fillAnimation = artboard.getAnimation("water up");
      _iceboyMoveY = artboard.getAnimation("iceboy_move_up");
    }
  }

  void setViewTransform(Mat2D viewTransform) {}

  bool advance(FlutterActorArtboard artboard, double elapsed) {
    //we need this separate from our generic mixing animations,
    // b/c the animation duration is needed in this calculation
    if (artboard.name.compareTo("Artboard") == 0) {
      _currentWaterFill +=
          (_waterFill - _currentWaterFill) * min(1, elapsed * _smoothTime);
      _fillAnimation.apply(
          _currentWaterFill * _fillAnimation.duration, artboard, 1);
      _iceboyMoveY.apply(
          _currentWaterFill * _iceboyMoveY.duration, artboard, 1);
    }

    int len = _baseAnimations.length - 1;
    for (int i = len; i >= 0; i--) {
      FlareAnimationLayer layer = _baseAnimations[i];
      layer.time += elapsed;
      layer.mix = min(1.0, layer.time / 0.01);
      layer.apply(_artboard);

      if (layer.isDone) {
        _baseAnimations.removeAt(i);
      }
    }
    return true;
  }

  ///called from the 'tracking_input'
  void playAnimation(String animName) {
    ActorAnimation animation = _artboard.getAnimation(animName);

    if (animation != null) {
      _baseAnimations.add(FlareAnimationLayer()
        ..name = animName
        ..animation = animation);
    }
  }

  ///called from the 'tracking_input'
  ///updates the water fill line
  void updateWaterPercent(double amt) {
    _waterFill = amt;
  }

  ///called from the 'tracking_input'
  ///resets the water fill line
  void resetWater() {
    _waterFill = 0;
  }
}
