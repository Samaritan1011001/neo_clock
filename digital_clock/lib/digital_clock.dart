// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Colors.black,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.black,
  _Element.shadow: Color(0xFF174EA6),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Timer _secondsTimer;

  bool selected = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _secondsTimer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      if (_dateTime.second % 1 == 0) {
        selected = !selected;
      }

      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final second = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 6.5;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontWeight: FontWeight.w200,
      fontSize: fontSize,
    );
    return new NeoContainer(
      switchCase: false,
      size: Size(350.0, 350.0),
      child: ProgressLine(
        completeColor: Colors.teal,
        completePercent: (_dateTime.hour / 24) * 100,
        child: Container(
          padding: EdgeInsets.all(7),
          child: ProgressLine(
            completePercent: (_dateTime.minute / 60) * 100,
            completeColor: Colors.black38,
            child: Center(
              child: DefaultTextStyle(
                style: defaultStyle,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      hour,
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w300,
                        fontSize: fontSize,
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      height: 35.0,
                      child: NeoContainer(
                        switchCase: selected,
                        size: Size(35.0, 35.0),
                        child: Center(
                          child: Text(
                            second,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black38,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      minute,
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w300,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NeoContainer extends StatelessWidget {
  final bool switchCase;
  final Widget child;
  final Size size;
  NeoContainer({this.child, this.switchCase, this.size});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      width: switchCase ? 25.0 : size.width,
      height: switchCase ? 25.0 : size.height,
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(-1.0, -4.0),
          end: Alignment(1.0, 4.0),
          colors: [
            Color(0xFFadadad),
            Color(0xFFcdcdcd),
          ],
        ),
        boxShadow: switchCase
            ? null
            : [
                BoxShadow(
                    color: Colors.black54,
                    offset: Offset(7.0, 7.0),
                    blurRadius: 15.0,
                    spreadRadius: 5.0),
                BoxShadow(
                    color: Color(0xFFdddddd),
                    offset: Offset(-7.0, -7.0),
                    blurRadius: 15.0,
                    spreadRadius: 5.0),
              ],
      ),
      child: child,
    );
  }
}

class ProgressLine extends StatefulWidget {
  final Color completeColor;
  final double completePercent;
  final Widget child;

  ProgressLine({this.child, this.completeColor, this.completePercent});
  @override
  ProgressLineState createState() => ProgressLineState();
}

class ProgressLineState extends State<ProgressLine>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Tween<double> valueTween;
  @override
  void initState() {
    super.initState();
    this.valueTween = Tween<double>(
      begin: 0,
      end: this.widget.completePercent,
    );
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: this._controller,
      child: Container(),
      builder: (context, child) {
        return new CustomPaint(
          foregroundPainter: new ProgressLinePainter(
            lineColor: Colors.transparent,
            completeColor: widget.completeColor,
            completePercent: this.valueTween.evaluate(this._controller),
            width: 2.0,
          ),
          child: widget.child,
        );
      },
    );
  }

  @override
  void didUpdateWidget(ProgressLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (this.widget.completePercent != oldWidget.completePercent) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue = this.valueTween?.evaluate(this._controller) ??
          oldWidget?.completePercent ??
          0;

      // Update the value tween.
      this.valueTween = Tween<double>(
        begin: beginValue,
        end: this.widget.completePercent ?? 1,
      );

      this._controller
        ..value = 0
        ..forward();
    }
  }
}

class ProgressLinePainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  ProgressLinePainter(
      {this.lineColor, this.completeColor, this.completePercent, this.width});
  @override
  void paint(Canvas canvas, Size size) {
    Paint line = new Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, line);
    double arcAngle = 2 * pi * (completePercent / 100);
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2,
        arcAngle, false, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
