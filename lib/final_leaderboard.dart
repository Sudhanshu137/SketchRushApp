import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinalLeaderBoard extends StatelessWidget{
  final scoreboard;
  final String winner;
  const FinalLeaderBoard({Key?key, this.scoreboard, required this.winner}) : super(key:key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        padding: EdgeInsets.all(8),
        height: double.maxFinite,
        child: Column(
          children: [
            ListView.builder(
              primary: true,
                shrinkWrap: true,
                itemCount: scoreboard.length,
                itemBuilder:(context,index){
                  var data = scoreboard[index].values;
                  return ListTile(
                    title: Text(data.elementAt(0),style: TextStyle(color:Colors.black,fontSize: 23)),
                    trailing: Text(data.elementAt(1), // was data.elementAt(0)
                        style: TextStyle(color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold)),
                  );
                }),
            Text("$winner has won the game",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }

}