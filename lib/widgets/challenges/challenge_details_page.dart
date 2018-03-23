import 'dart:math' as math;

import 'package:cap_challenge/models/bottle.dart';
import 'package:cap_challenge/models/challenge.dart';
import 'package:cap_challenge/widgets/challenges/challenge_common_views.dart';
import 'package:flutter/material.dart';

List<Bottle> bottleCollection = [
  new Bottle(BottleName.SPRITE, Capacity.CAN_300, 50),
  new Bottle(BottleName.SPRITE, Capacity.PLASTIC_500, 10),
  new Bottle(BottleName.COCA_COLA_ZERO, Capacity.PLASTIC_1L, 50),
  new Bottle(BottleName.SPRITE, Capacity.PLASTIC_2L, 10),
  new Bottle(BottleName.COCA_COLA, Capacity.PLASTIC_2L, 50),
  new Bottle(BottleName.SPRITE, Capacity.PLASTIC_500, 10),
  new Bottle(BottleName.COCA_COLA, Capacity.PLASTIC_1L, 50),
  new Bottle(BottleName.SPRITE, Capacity.PLASTIC_2L, 10),
  new Bottle(BottleName.COCA_COLA, Capacity.PLASTIC_1L, 50),
  new Bottle(BottleName.COCA_COLA, Capacity.PLASTIC_1L, 50),
  new Bottle(BottleName.COCA_COLA, Capacity.PLASTIC_1L, 50),
  new Bottle(BottleName.COCA_COLA_ZERO, Capacity.CAN_300, 50),
];

class ChallengeDetailsPage extends StatefulWidget {
  final Challenge challenge;

  ChallengeDetailsPage(this.challenge);

  @override
  ChallengeDetailsPageState createState() {
    return new ChallengeDetailsPageState();
  }
}

class ChallengeDetailsPageState extends State<ChallengeDetailsPage> {
  static const double _rowHeight = 32.0;

  static const double _appBarHeight = 256.0;

  static const double _appBarMarginBottom = 8.0;

  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          _buildSliverAppBar(),
          new SliverList(
            delegate: new SliverChildListDelegate(
              <Widget>[
                _buildConfirmButtonOrLabel(bottleCollection, widget.challenge),
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new Row(
                    children: <Widget>[
                      new Text("Poziom trudności:  "),
                      buildDifficultyIndicator(widget.challenge),
                    ],
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: new Row(
                    children: <Widget>[
                      new Text("Nagroda:  "),
                      getRewardView(widget.challenge),
                    ],
                  ),
                ),
              ]..addAll(widget.challenge.requirements.keys.map((bottle) {
                return _buildRequirementRow(
                  context,
                  bottle,
                  widget.challenge.requirements[bottle],
                  bottleCollection
                      .where((btl) => btl == bottle)
                      .length,
                );
              }).toList())..addAll(
                  widget.challenge.requirements.keys.map((bottle) {
                    return _buildRequirementRow(
                      context,
                      bottle,
                      widget.challenge.requirements[bottle],
                      bottleCollection
                          .where((btl) => btl == bottle)
                          .length,
                    );
                  }).toList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButtonOrLabel(List<Bottle> collection,
      Challenge challenge) {
    return new Builder(builder: (context) {
      return new Padding(
        padding: new EdgeInsets.all(16.0),
        child: _canChallengeBeCompleted(collection, challenge)
            ? new Column(
          children: <Widget>[
            new RaisedButton(
              onPressed: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("Tak jakby wykonane")));
              },
              color: Colors.red,
              child: new Text("WYKONAJ!"),
            ),
          ],
        )
            : new Text(
          "Brakuje Ci tylko ${_getMissingBottles(
              bottleCollection, challenge)}!",
          textAlign: TextAlign.center,
        ),
      );
    });
  }

  bool _canChallengeBeCompleted(List<Bottle> collection, Challenge challenge) {
    return _getMissingBottles(collection, challenge) == 0;
  }

  int _getMissingBottles(List<Bottle> collection, Challenge challenge) {
    int missing = 0;
    challenge.requirements.forEach((bottle, required) {
      int diff = required - collection
          .where((bot) => bot == bottle)
          .length;
      if (diff > 0) {
        missing += diff;
      }
    });
    return missing;
  }

  Widget _buildRequirementRow(BuildContext context, Bottle bottle, int required,
      int current) {
    return new ListTile(
      title: new Text(bottleNameToString(bottle.bottleName)),
      subtitle: new Text(bottleCapacityToString(bottle.capacity)),
      trailing: _buildProgressIndicator(required, current),
    );
  }

  Widget _buildProgressIndicator(int required, int current) {
    int viewCurrent = math.min(current, required);
    int missing = required - viewCurrent;
    List<Widget> filledBottles = new Iterable.generate(
      viewCurrent,
          (i) =>
      new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new Image.asset(
          "images/bottle_filled.png",
          height: _rowHeight,
        ),
      ),
    ).toList();
    List<Widget> emptyBottles = new Iterable.generate(
      missing,
          (i) =>
      new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: new Image.asset(
          "images/bottle_empty.png",
          height: _rowHeight,
        ),
      ),
    ).toList();
    return new Row(
      children: filledBottles..addAll(emptyBottles),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    double titleMargin = _appBarMarginBottom;
    Color backgroundColor = Colors.transparent;
    double fabOpacity = 1.0;
    if (_scrollController.hasClients) {
      double _base = _appBarHeight - 42.0 - _appBarMarginBottom;
      double factor = math.max((_base - _scrollController.offset) / _base, 0.0);
      titleMargin *= factor;
      backgroundColor = factor < 0.2 ? Colors.red : Colors.transparent;
      fabOpacity = math.max(8 * factor - 7, 0.0);
      print(factor);
    }
    return new SliverAppBar(
      backgroundColor: backgroundColor,
      expandedHeight: _appBarHeight,
      pinned: true,
      flexibleSpace: new FlexibleSpaceBar(
        title: new Padding(
          padding: new EdgeInsets.only(bottom: titleMargin),
          child: new Text(widget.challenge.name),
        ),
        background: new Stack(
          children: <Widget>[
            new Container(
              height: _appBarHeight - _appBarMarginBottom,
              color: Colors.white,
              child: new Hero(
                tag: "challenge_image_${widget.challenge.name}",
                child: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new Image.network(
                      widget.challenge.photoUrl,
                      height: _appBarHeight - _appBarMarginBottom,
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: const LinearGradient(
                          begin: const Alignment(0.0, -1.0),
                          end: const Alignment(0.0, -0.4),
                          colors: const <Color>[
                            const Color(0x60FF0000),
                            const Color(0x00FF0000)
                          ],
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: const LinearGradient(
                          begin: const Alignment(0.0, 1.0),
                          end: const Alignment(0.0, 0.4),
                          colors: const <Color>[
                            const Color(0x60FF0000),
                            const Color(0x00FF0000)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Positioned(
              right: 16.0,
              top: _appBarHeight - 48.0,
              child: new Opacity(
                  opacity: fabOpacity,
                  child: new FloatingActionButton(onPressed: () {})),
            )
          ],
        ),
      ),
    );
  }
}