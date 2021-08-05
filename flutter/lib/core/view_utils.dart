import 'package:flutter/material.dart';

class SpacingHelp {}

extension SpacingExt on num {
  Container get vSpace => Container(height: toDouble());
  Container get hSpace => Container(width: toDouble());
}
