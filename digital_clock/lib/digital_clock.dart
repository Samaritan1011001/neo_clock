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
      if(_dateTime.second % 1 ==0){
        selected =!selected;
      }
      // Update once per minute. If you want to update every second, use the
      // following code.
//      _timer = Timer(
//        Duration(minutes: 1) -
//            Duration(seconds: _dateTime.second) -
//            Duration(milliseconds: _dateTime.millisecond),
//        _updateTime,
//      );
      _timer = Timer(
//        Duration(minutes: 1) -
            Duration(seconds: 1) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );


      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
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
    final offset = -fontSize / 7;
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontWeight: FontWeight.w200,
//      fontFamily: 'PressStart2P',
      fontSize: fontSize,
    );
  print(second);
    return GestureDetector(
      onTap: () {
        print("tapped");
        setState(() {
          selected = !selected;
        });
      },
      child: new AnimatedContainer(
        duration: Duration(seconds: 1),
        width: 350.0,
        height: 350.0,
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
//          borderRadius: BorderRadius.all(Radius.circular(35)),
            boxShadow:
            [
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
          border: Border.all(color: Color(0xFFdddddd),width: 0.3)
        ),

//      new BoxDecoration(
//        color: Colors.white70,
//        shape: BoxShape.circle,
//        boxShadow: [
//          new BoxShadow(
//            color: Colors.black45,
//            offset: new Offset(15.0, 10.0),
//            blurRadius: 25.0,
//            spreadRadius: 0.2,
//          )
//        ],
//      ),

        child: new CustomPaint(
          foregroundPainter: new MyPainter(
            lineColor: Colors.transparent,
            completeColor: Colors.teal,
            completePercent: (_dateTime.hour / 24) * 100,
            width: 2.0,
          ),
          child: Container(
            padding: EdgeInsets.all(7),
            child: CustomPaint(
              foregroundPainter: new MyPainter(
                lineColor: Colors.transparent,
                completeColor: Colors.black38,
                completePercent: (_dateTime.minute / 60) * 100,
                width: 2.0,
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: defaultStyle,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(hour),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[

                          SizedBox(
                            width:35.0,
                            height:35.0,
                            child: AnimatedContainer(
                                duration: Duration(seconds: 1),
                                width: selected ? 25.0 : 35.0,
                                height: selected ? 25.0 : 35.0,
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
//                        borderRadius: BorderRadius.all(Radius.circular(35)),
                                  boxShadow: selected ? null :
                                  [
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
//                            border: Border.all(color: Color(0xFFdddddd),width: 0.3)
                                ),
                                child: Center(
                                  child: Text(second,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
                                )

                            ),
                          ),
                        ],
                      ),
                      Text(minute),
//                      Stack(
//                        alignment: AlignmentDirectional.topCenter,
//                        children: <Widget>[
//                          CustomPaint(
//                            size: Size(50, 50),
//                            painter: ShadowPainter(),
//                          ),
//                          Positioned(
//                            top: 12.5,
//                            child: CustomPaint(
//                              size: Size(30, 30),
//                              painter: HeartPainter(),
////                        child: AnimatedContainer(
////                          duration: Duration(seconds: 2),
////                          width: 30.0,
////                          height: 30.0,
////                          padding: EdgeInsets.all(7),
////                          decoration: BoxDecoration(
////                            shape: BoxShape.circle,
////                            gradient: LinearGradient(
////                              begin: Alignment(-1.0, -4.0),
////                              end: Alignment(1.0, 4.0),
////                              colors: [
////                                Color(0xFFadadad),
////                                Color(0xFFcdcdcd),
////                              ],
////                            ),
//////                        borderRadius: BorderRadius.all(Radius.circular(35)),
////                            boxShadow: selected ? null :
////                            [
////                              BoxShadow(
////                                  color: Colors.black54,
////                                  offset: Offset(7.0, 7.0),
////                                  blurRadius: 15.0,
////                                  spreadRadius: 5.0),
////                              BoxShadow(
////                                  color: Color(0xFFdddddd),
////                                  offset: Offset(-7.0, -7.0),
////                                  blurRadius: 15.0,
////                                  spreadRadius: 5.0),
////                            ],
//////                            border: Border.all(color: Color(0xFFdddddd),width: 0.3)
////                          ),
////
////                        ),
//                            ),
//                          ),
//                        ],
//                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor;
  Color completeColor;
  double completePercent;
  double width;
  MyPainter(
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

class HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint();
    paint
//      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    Paint fillPainter = Paint();
    fillPainter
      ..color = Colors.transparent
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    double width = size.width;
    double height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);

    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6,
        0.5 * width, height);

//    canvas.drawShadow(shadowPath, Colors.black54, 0.0, true);
//    canvas.drawPath(path, fillPainter);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    var gradient = LinearGradient(
      begin: Alignment(-1.0, -4.0),
      end: Alignment(1.0, 4.0),
      colors: [
        Color(0xFFadadad),
        Color(0xFFcdcdcd),
      ],
    );
    Paint shadowPaint = Paint();
    shadowPaint
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Offset.zero & size)
      ..strokeWidth = 50;
    
    double width = size.width;
    double height = size.height;
    Path shadowPath = Path();

    shadowPath.moveTo(0.5 * width, height * 0.35);
    shadowPath.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6,
        0.5 * width, height);

    shadowPath.moveTo(0.5 * width, height * 0.35);
    shadowPath.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6,
        0.5 * width, height);

    canvas.drawShadow(shadowPath, Colors.black54, 0.0, true);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}