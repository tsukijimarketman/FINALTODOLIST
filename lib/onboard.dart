import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_list_1/content_model.dart';
import 'package:todo_list_1/todo_list_screen.dart';
import 'package:todo_list_1/widget_support.dart';


class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  int currenIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index){
                setState(() {
                  currenIndex = index;
                });
              }, 
              itemBuilder: (_, i){
                return Padding(padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                  child: Column(
                    children: [
                Image.asset(contents[i].image, height: 450, width: MediaQuery.of(context).size.width, fit: BoxFit.fill,),
                SizedBox(height: 30,),
                Text(contents[i].title, style: AppWidget.HeadlineTextFieldStyle(),),
                SizedBox(height: 15,),
                Text(contents[i].description, style: AppWidget.SoftTextFieldStyle(),),
                ],
              ),);
            }),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(contents.length, (index)=> 
                buildDot(index, context)
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              if(currenIndex==contents.length-1){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ToDoList(),));
              }
              _controller.nextPage(duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFD61C38),
                borderRadius: BorderRadius.circular(20)
              ),
              height: 50,
              margin: EdgeInsets.all(30),
              width: double.infinity,
              child: Center(child: Text(currenIndex==contents.length-1?"Proceed":"Next", style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold),)),
            ),
          )
        ],
      ),
    );
  }
  Container buildDot(int index, BuildContext context){
    return Container(
      height: 10, 
      width: currenIndex==index?18:7, 
      margin: EdgeInsets.only(right: 5), 
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Color(0xFFD61C38)));
  }
}