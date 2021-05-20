import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_app/states/chat_data.dart';
import 'package:flutter_chat_app/states/chat_state_controller.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_highlight/text_highlight.dart';
import 'package:text_highlight/tools/highlight_theme.dart';

//var http = httpPackage.Client();
bool inProduction = true;

void main() {
  runApp(GetMaterialApp(title: 'Flutter ChatApp',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      primaryColor: Color.fromRGBO(20, 20, 20, 1),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: HomePage(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ChatApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}


class HomePage extends StatefulWidget{
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageStates createState() => _HomePageStates();
}


class _HomePageStates extends State<HomePage>{
  var _url = inProduction ? 'https://flutter-chat-app-api.herokuapp.com/' :'http://10.0.2.2:3001/';
  var _dropdownValue;
  var _isLoggedIn=false , _toggleLoginSignup =true;
  var _searchList = [];
  ChatData _chatData  = ChatData();
  TextEditingController _emailController= TextEditingController(),
      _passwordController=TextEditingController(),
      _nameController=TextEditingController(),
      _tokenController = TextEditingController();
  _saveCookie()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('cookie', _chatData.getCookie);
    sharedPreferences.setString('token', _chatData.getToken);
  }

  _getCookie()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _chatData.cookie = sharedPreferences.get('cookie') ?? '';
    _chatData.setToken = sharedPreferences.get('token');
  }

  getChatList()async{
    var res = await http.post(_url+'chatlist',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'authorization': 'bearer '+_chatData.getToken,
      'cookie' : _chatData.getCookie
    });
    return res;
  }

  _getSearchList()async{
    var res = await http.post(_url+'searchlist',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'authorization': 'bearer '+_chatData.getToken,
      'cookie' : _chatData.getCookie
    });
    return res;
  }

  setUser()async{
    var res = await http.post(_url+'userdata',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'authorization': 'bearer '+_chatData.getToken,
      'cookie' : _chatData.getCookie
    });
    var data = json.decode(res.body);
    setState(() {
      _chatData.currentUserId =  data['user_id'];
      _chatData.currentUserName = data['name'];
    });
  }


  _logInUser()async{
    var email = _emailController.text,password = _passwordController.text;
    var res = await http.post(_url+'login',
        body: json.encode(<String,String>{
          'email':email,
          'password':password,
        }),headers:<String ,String>{
          'Content-type': 'application/json; charset=UTF-8',
          'authorization': 'bearer '+_chatData.getToken,
          'cookie' : _chatData.getCookie
        }
    );
    print(res.body);
    if(res.statusCode == 403)
      return;
    var data = json.decode(res.body);
    setState(() {
      _isLoggedIn = data['stat'];
      _chatData.cookie = res.headers['set-cookie'];
      _saveCookie();
      if(_isLoggedIn){
        setUser();
        getChatList();
        _getSearchList();
      }
    });
  }

  _signUpUser()async{
    var name = _nameController.text,email = _emailController.text,password = _passwordController.text;
    var res = await http.post(_url+'signup',body:json.encode(<String,String> {
      'name':name,
      'email':email,
      'password':password,
    }),headers:<String,String>{
    'Content-type': 'application/json; charset=UTF-8',
    'authorization': 'bearer '+_chatData.getToken,
    'cookie' : _chatData.getCookie
    });
    if(res.statusCode == 403)
      return;
    var data = json.decode(res.body);
    setState(() {
      _isLoggedIn = data['stat'];
    });
  }

  _logOutUser()async{
    var res = await http.post(_url+'logout',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'authorization': 'bearer '+_chatData.getToken,
      'cookie' : _chatData.getCookie
    });
    if(res.statusCode == 403)
      return;
    var data = json.decode(res.body);
    setState(() {
      _searchList = [];
      _chatData.currentUserId = 0;
      _chatData.currentUserName = '';
      _chatData.cookie = '';
      _isLoggedIn = false;
    });
  }

  showNormalSnackBar(BuildContext context , String text){
    var snackBar = SnackBar(
        content: Text(text , style: TextStyle(color: Colors.white),),
      backgroundColor: Color.fromRGBO(20, 20, 20, 1),

    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  showActionSnackBar(BuildContext context , String text , String actionText , void Function() onAction){
    var snackBar = SnackBar(
      content: Text(text , style: TextStyle(color: Colors.white),),
      backgroundColor: Color.fromRGBO(20, 20, 20, 1),
      action: SnackBarAction(label: actionText, textColor: Colors.red, onPressed: onAction),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  optionsDialog(){
    return AlertDialog(
      backgroundColor: Color.fromRGBO(0, 0, 20, 1),
      content: Text('Are you sure you want to log out?',style: TextStyle(color: Colors.white,fontSize: 25 ),),
      actions: [
        TextButton(
          child: Text('cancel',style: TextStyle(color: Colors.yellow,),),
          onPressed: (){
            Get.back();
            //Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text('logout',style: TextStyle(color: Colors.red,),),
          onPressed: (){
            _logOutUser();
            Get.back();
            //Navigator.pop(context);
          },
        )
      ],
    );
  }

  logInView() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      appBar: AppBar(
        title: Text('ChatApp'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Colors.white),
                  controller: _emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Email'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Email';
                    return '';
                  },
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Password'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Password';
                    if(value.length<8)return 'password should be of atleast 8 chracters';
                    return '';
                  },
                ),
                TextButton(
                    onPressed: (){
                      showDialog(context: context, builder: (context) => AlertDialog(
                        backgroundColor: Colors.indigo,
                          title: TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _tokenController,
                            decoration: InputDecoration(
                              hintText: 'Enter Token Here',
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Verify Token' , style: TextStyle( color: Colors.lime),),
                              onPressed: (){
                                _chatData.setToken = _tokenController.text.trim();
                                _saveCookie();
                                _logInUser();
                                Get.back();
                              },
                            ),
                            TextButton(
                              child: Text('Clear' , style: TextStyle( color: Colors.white),),
                              onPressed: (){
                                _tokenController.text = '';
                              },
                            ),
                            TextButton(
                              child: Text('Cancel',style: TextStyle( color: Colors.red),),
                              onPressed: (){
                                Get.back();
                              },
                            )
                          ],
                        )
                      );
                    },
                    child: Text(
                        'Login',
                    )
                ),
                TextButton(
                    onPressed: (){
                      setState(() {
                        _toggleLoginSignup=!_toggleLoginSignup;
                      });
                    },
                    child: Text(
                      'SignUp',
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  signUpView(){
    return Scaffold(
      backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      appBar: AppBar(
        title: Text('ChatApp'),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context){
          return Center(
            child: Container(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _nameController,
                      decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Name'),
                      validator: (String value){
                        if(value.trim().isEmpty)return 'please Enter Name';
                        return '';
                      },
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _emailController,
                      decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Email'),
                      validator: (String value){
                        if(value.trim().isEmpty)return 'please Enter Email';
                        return '';
                      },
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Password'),
                      validator: (String value){
                        if(value.trim().isEmpty)return 'please Enter Password';
                        if(value.length<8)return 'password should be of at least 8 characters';
                        return '';
                      },
                    ),
                    TextButton(
                        onPressed: (){
                          showDialog(context: context, builder: (context) => AlertDialog(
                            backgroundColor: Colors.indigo,
                            title: TextFormField(
                              style: TextStyle(color: Colors.white),
                              controller: _tokenController,
                            ),
                            actions: [
                              TextButton(
                                child: Text('Verify Token' ,style: TextStyle( color: Colors.lime),),
                                onPressed: ()async{
                                  _chatData.setToken = _tokenController.text.trim();
                                  _saveCookie();
                                  await _signUpUser();
                                  if(_isLoggedIn)
                                    showActionSnackBar(context, 'Sign Up Successful ', 'Log In', () {setUser(){{_toggleLoginSignup=true; }}});
                                  else
                                    showNormalSnackBar(context, "Can't sign up");
                                  Get.back();
                                },
                              ),
                              TextButton(
                                child: Text('Clear' , style: TextStyle( color: Colors.white),),
                                onPressed: (){
                                  _tokenController.text = '';
                                },
                              ),
                              TextButton(
                                child: Text('Cancel' , style: TextStyle( color: Colors.red),),
                                onPressed: (){
                                  Get.back();
                                },
                              ),
                            ],
                          )
                          );

                        },
                        child: Text(
                          'SignUp',
                        )
                    ),
                    TextButton(
                        onPressed: (){
                          setState(() {
                            _toggleLoginSignup=!_toggleLoginSignup;
                          });
                        },
                        child: Text(
                          'LogIn',
                        )
                    )
                  ],
                ),
              ),
            ),
          );
        },
      )
    );
  }
  mainView(){
    return Scaffold(
        backgroundColor: Color.fromRGBO(0, 0, 0, 1),
        appBar: AppBar(
          leading: Container(
              child: Center(
                child:
                IconButton(
                  icon: Icon(
                    Icons.person_rounded,
                    color: Colors.blue,
                  ),
                ),
              )
          ),
          title: Text('ChatApp'),
          actions: [
            IconButton(
                icon: Icon(Icons.search_outlined,color: Colors.blue,),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (context) => Dialog(
                          elevation: 5,
                          child: Container(
                            height: 120.0,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 0, 20, 1)
                            ),
                            child:FutureBuilder(
                                future: _getSearchList(),
                                builder: (context,searchListState){
                                  if(searchListState.connectionState == ConnectionState.none || !searchListState.hasData || searchListState.hasError){
                                    return LinearProgressIndicator();
                                  }else{
                                    var searchList = json.decode(searchListState.data.body)['searchlist'];
                                    return Column(
                                        children: [
                                          Center(
                                                  child: DropdownButtonFormField(
                                                    dropdownColor: Color.fromRGBO(0, 0, 20, 1),
                                                    value: _dropdownValue = searchList[0]['user_id'],
                                                    itemHeight: 100,
                                                    items: searchList.map<DropdownMenuItem>((e){
                                                      return DropdownMenuItem(
                                                        value: e['user_id'],
                                                        child: Text(e['name'] + '\n ' , style: TextStyle(color: Colors.white),),
                                                      );
                                                    }).toList(),
                                                    onChanged: (v){
                                                      _dropdownValue = v;
                                                    },
                                                  )
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              IconButton(icon: Icon(Icons.send_rounded , color: Colors.purple ,), onPressed: (){
                                                var id = _dropdownValue,n;
                                                for(var e in searchList){
                                                  if(e['user_id']== id){
                                                    n=e['name'];
                                                    break;
                                                  }
                                                }
                                                Get.back();
                                                _chatData.roomId = id;
                                                _chatData.roomName = n;
                                                Get.to(()=>ChatView( _chatData ),);
                                                //Navigator.pop(context);
                                                //Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, id, n , _cookie , (){Navigator.pop(context);})));
                                              }),
                                              IconButton(icon: Icon(Icons.close , color: Colors.red,), onPressed: (){
                                                Get.back();
                                                //Navigator.pop(context);
                                              })
                                            ],
                                          )
                                        ],
                                      );
                                  }
                              }
                            ),
                          )
                      )
                  );
                }
            ),
            IconButton(
                icon: Icon(Icons.logout,color: Colors.blue,),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context){
                      return optionsDialog();
                    },
                  );
                }
            )
          ],
        ),
        drawer: Drawer(
          child: Container(
            color: Color.fromRGBO(0, 30, 30, 1.0),
            alignment: Alignment.topLeft,
            child: ListView(
              children: [
                  ListTile(
                  title: Align( alignment: Alignment.topLeft, child: Icon(Icons.person , size: 50, color: Colors.blueGrey,),),
                ),
                ListTile(
                  title: Text('Name' , style: TextStyle( color: Colors.lime, ), ),
                  subtitle: Text('${_chatData.getCurrentUserName}' , style: TextStyle( color: Colors.white),),
                ),
                ListTile(
                  title: Text('Email' , style: TextStyle( color: Colors.lime, ), ),
                  subtitle: Text('${_chatData.getCurrentUserName}@gmail.com' , style: TextStyle( color: Colors.white),),
                )
              ],
            ),
          ),
        ),
        body:FutureBuilder(
          future: getChatList(),
          builder: (context,chatListState){
            if(chatListState.connectionState == ConnectionState.none || !chatListState.hasData || chatListState.hasError){
              return Center(
                child: CircularProgressIndicator(),
              );
            }else{

              var chatList = json.decode(chatListState.data.body)['chatlist'];
              return ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (BuildContext context,int i){
                    return Container(
                        child: GestureDetector(
                            onTap: (){
                              _chatData.roomId = chatList[i]['uid'];
                              _chatData.roomName = chatList[i]['name'];
                              Get.to(()=>ChatView( _chatData));
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, chatList[i]['uid'], chatList[i]['name'] , _cookie , (){Navigator.pop(context);})));
                            },
                            child:Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  border: i==(chatList.length-1)? Border() : Border(bottom: BorderSide(color: Color.fromRGBO(0,75, 0, 1) )),
                                  color: Color.fromRGBO(0, 30, 30, 0.6)
                              ),
                              child:Row(
                                mainAxisSize: MainAxisSize.max,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Container(
                                        padding: EdgeInsets.all(1),
                                        child:
                                        IconButton(
                                          iconSize: 30,
                                          icon: Icon(
                                            Icons.person_rounded,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      )
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          chatList[i]['name'],
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 25 , color: Colors.white),
                                        ),
                                        Text(
                                          chatList[i]['lastmsg'] ==null ?  '' :chatList[i]['lastmsg'],
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 20 , color: Colors.white),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                        )
                    );
                  });
            }
          },

        ),
    );
  }


  @override
  Widget build(BuildContext context) {
    ()async{
      await _getCookie();
      var res = await http.get(_url+'home',headers: {
        'Content-type': 'application/json; charset=UTF-8',
        'authorization': 'bearer '+_chatData.getToken,
        'cookie' : _chatData.getCookie
      });
      if(res.statusCode == 403)
        return;
      var data = json.decode(res.body);
      if(data['stat']!=_isLoggedIn)
      setState(() {
        _isLoggedIn = data['stat'];
        if(_isLoggedIn){
          setUser();
          getChatList();
          _getSearchList();
        }
      });
    }();
    return _isLoggedIn ? (
        mainView()
    ):(
        _toggleLoginSignup ? (
            logInView()
    ):(
         signUpView()
    )
    );
  }

}


class ChatView extends StatefulWidget{
  ChatData _chatData = ChatData();
  ChatView(ChatData chatData ,{Key key}) : _chatData = chatData,super(key: key);
  @override
  _ChatViewStates createState() => _ChatViewStates(_chatData);
}

class _ChatViewStates extends State<ChatView>{
  var _url = inProduction ? 'https://flutter-chat-app-api.herokuapp.com/' :'http://10.0.2.2:3001/';
  var _chats=[] , _isSelected = [];
  bool _isMessageSelected = false;
  ChatData _chatData = ChatData();
  double screenWidth ;
  TextEditingController _messaggeController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  _getChats()async{
    var res = await http.post(_url+'chats',
        body: json.encode(<String,dynamic>{
          'to_id' : _chatData.getRoomId
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'authorization': 'bearer '+_chatData.getToken,
          'cookie' : _chatData.getCookie
        });
    var data;
    if(res.statusCode == 403)
      data = {'chats':[]};
    else
      data = json.decode(res.body);
    setState(() {
      _chats =  data['chats'];
    });
    return res;
  }

  sendMessage(String msg)async{
    var res = await http.post(_url+'sendmsg',
        body: json.encode(<String,dynamic>{
          'to_id' : _chatData.getRoomId,
          'to_name' : _chatData.getRoomName,
          'my_name' : _chatData.getCurrentUserName,
          'msg' : msg,
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'authorization': 'bearer '+_chatData.getToken,
          'cookie' : _chatData.getCookie
        });
    if(res.statusCode == 403)return;
    var data = json.decode(res.body);
    setState(() {
      if(data['msg_status']){
        _getChats();
        _messaggeController.text = '';
      }
    });
  }

  Future<dynamic> performDelete(deleteList,int roomId)async{
    var res = await http.post(_url+'deletemsg',
        body: json.encode(<String,dynamic>{
          'roomId': roomId ,
          'deleteList': deleteList
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'authorization': 'bearer '+_chatData.getToken,
          'cookie' : _chatData.getCookie
        });
    var data;
    if(res.statusCode == 403)
      data = {'stat':'forbidden' , 'dc':0 , 'ndc':0 };
    else
      data = json.decode(res.body);
    return data;
  }

  _ChatViewStates(chatData){
    _chatData = chatData;
    Future.delayed(Duration(seconds: 2) , (){
      try{
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }catch(err){}
    });
  }

  String stringTime(String dateString){
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    Duration timestamp = now.difference(date);
    if(timestamp.inHours < 24){
      if(timestamp.inSeconds < 60)
        return 'Just Now';
      else if(timestamp.inMinutes < 60)
        return timestamp.inMinutes.toString() + 'minute${timestamp.inMinutes<2?'':'s'} ago';
      return timestamp.inHours.toString() + 'hour${timestamp.inHours<2?'':'s'} ago';
    }else{
      if(timestamp.inDays < 7)
        return timestamp.inDays.toString() + 'day${timestamp.inDays<2?'':'s'} ago';
      else if(timestamp.inDays < 30){
        int weeks = timestamp.inDays ~/ 7;
        return weeks.toString() + 'week${weeks<2?'':'s'} ago';
      }else if(timestamp.inDays < 365){
        int months = timestamp.inDays ~/ 30;
        return months.toString() + 'month${months<2?'':'s'} ago';
      }else{
        int years = timestamp.inDays ~/ 365;
        return years.toString() + 'year${years<2?'':'s'} ago';
      }
    }
  }

  messageView(data, int index){
    bool isSender = data['to_id']==_chatData.getRoomId;
    return GestureDetector(
      onLongPress: (){
        _isSelected = List.filled(_chats.length, false , growable: true);
        _isSelected[index] = true;
        setState(() {
          _isMessageSelected = true;
        });
      },
      onTap: (){
        if(_isMessageSelected)
          _isSelected[index] = ! _isSelected[index];
      },
      child: Container(
        color: _isSelected[index] ? Color.fromRGBO(30, 0, 0, 1) : Colors.transparent,
        child: Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth*0.9),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: isSender? 10.0:0 , top: 1.0 , left: isSender? 0:10.0),
            decoration: BoxDecoration(
              //border: Border.all(color: Colors.yellow),
                borderRadius: isSender ? BorderRadius.only(topLeft: Radius.circular(25.0) , topRight: Radius.circular(25.0) ,bottomLeft:Radius.circular(25.0) ):BorderRadius.only(topLeft: Radius.circular(25.0) , topRight: Radius.circular(25.0) ,bottomRight: Radius.circular(25.0)),
                color: Color.fromRGBO(40, 40, 40, 1)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Text(isSender ? 'You' : _chatData.getRoomName , style: TextStyle( fontWeight: FontWeight.bold , color: data['to_id']==_chatData.getRoomId ? Color.fromRGBO(180, 0, 180, 1) : Color.fromRGBO(0, 180, 180, 1)),),
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      child: HighlightText(data['msg']+'\n  ' , mode: HighlightTextModes.AUTO,theme: HighlightTheme(bgColor:  Color.fromRGBO(40, 40, 40, 1)) ,  fontSize: 16,),
                    ),
                    Container(
                      child: Text(stringTime(data['msgtime']) , style: TextStyle(fontSize: 10 , fontWeight: FontWeight.w300, color: Colors.yellow,)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  messageListFutureBuilder(){
    return FutureBuilder(
      future: _getChats(),
      builder: (context,chatsState){
          if(chatsState.connectionState == ConnectionState.none || !chatsState.hasData || chatsState.hasError){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else {
            var chats = json.decode(chatsState.data.body)['chats'];
            if(chats.length != _isSelected.length)
              _isSelected = List.filled(chats.length, false , growable: true);
            return ListView.builder(
                    controller: _scrollController,
                    itemCount: chats.length,
                    itemBuilder: (context,i){
                      return messageView(chats[i]  , i);
                  });
          }
    },
    );
  }

  AppBar mainAppBar(){
    return AppBar(
      leading: Container(
          child: Center(
            child:
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.blue,
              ),
              onPressed: (){
                Get.back();
                //_callback();
              },
            ),
          )
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(
              Icons.person_rounded,
              color: Colors.blue,
            ),
          ),
          Text(" "+_chatData.getRoomName,style: TextStyle(fontWeight: FontWeight.bold),),
        ],
      ) ,
      actions: [
        PopupMenuButton(
          color: Color.fromRGBO(20, 20, 20, 1),
          itemBuilder: (context){
            String value;
            return [
                PopupMenuItem(
                value: 'search',
                  child: ListTile(
                    title: TextField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'ScrollTo:',
                        labelStyle: TextStyle(color: Colors.white),
                        suffixText: '%',
                        suffixStyle: TextStyle(color: Colors.white)
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      onChanged: (String v){
                        value = v;
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.search_outlined, color: Colors.white,),
                      onPressed: (){
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent * (double.parse(value) / 100));
                        Get.back();
                      },
                    ),
                  )
              ),
              PopupMenuItem(
                  value: 'Clear chat',
                  child: ListTile(
                    title: Text('Clear chat', style: TextStyle(color: Colors.white),),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_forever ,color: Colors.white,),
                    ),
                      onTap: (){
                        Get.back();
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            backgroundColor: Colors.indigo,
                            content: Text('Are you sure you want to delete all your messages with current user?', style: TextStyle(color: Colors.black,fontSize: 20 ),),
                            actions: [
                              TextButton(
                                child: Text('Cancel',style: TextStyle(color: Colors.yellow,),),
                                onPressed: (){
                                  Get.back();
                                  //Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('Delete',style: TextStyle(color: Colors.red,),),
                                onPressed: ()async{
                                  var deleteList = [];
                                  for(int i=0;i<_chats.length;++i){
                                    if(_chats[i]['to_id'] != _chatData.getCurrentUserId && _chatData.getRoomId != _chatData.getCurrentUserId) {
                                      deleteList.add({
                                        'toId':_chats[i]['to_id'],
                                        'msgId': _chats[i]['msgid']
                                      });
                                    }
                                  }
                                  var data = await performDelete( deleteList, _chatData.getRoomId);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check_circle , color: Colors.lime, size: 30,),
                                        Text('  ${data['dc']} messages successfully deleted' , style: TextStyle(color: Colors.white),)
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                  ));
                                  Get.back();
                                },
                              )
                            ],
                          );
                        });
                      },
                    ),
                  )
            ];
            //return ['Item1','Item2','Item3'].map((item) {return PopupMenuItem<String>(value:'Item1',child: Text(item),);}).toList();
          },
        ),
      ],
    );
  }

  AppBar selectionAppBar(){
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: (){
          setState(() {
            _isSelected = List.filled(_chats.length, false , growable: true);
            _isMessageSelected = false;
          });
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.copy_rounded),
          onPressed: (){
            String copyText='';
            for(int i = 0;i< _isSelected.length ; ++i){
            if(_isSelected[i]) {
                copyText += _chats[i]['msg'];
              }
            }
            Clipboard.setData(ClipboardData(text: copyText));
            setState(() {
              _isSelected = List.filled(_chats.length, false , growable: true);
              _isMessageSelected = false;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: ()async{
            var deleteList = [];
            for(int i = 0;i< _isSelected.length ; ++i){
              if(_isSelected[i]) {
                deleteList.add({
                  'toId':_chats[i]['to_id'],
                  'msgId': _chats[i]['msgid']
                });
              }
            }
            if(deleteList.length == 0){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded , color: Colors.white, size: 30,),
                    Text('  No message selected please select a message to delete ' , style: TextStyle(color: Colors.white),)
                  ],
                ),
                backgroundColor: Colors.red,
              ));
              return;
            }
            var data = await performDelete(deleteList, _chatData.getRoomId);
            if(data['dc']>0){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle , color: Colors.lime, size: 30,),
                  Text('  ${data['dc']} messages successfully deleted' , style: TextStyle(color: Colors.white),)
                ],
              ),
            backgroundColor: Colors.green,
            ));
            }
            if(data['ndc']>0){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded , color: Colors.white, size: 30,),
                    Text('  ${data['ndc']} messages not deleted\nReason: ${data['stat']}' , style: TextStyle(color: Colors.white),)

                  ],
                ),
                backgroundColor: Colors.red,
              ));
            }
            _getChats();
            setState(() {
              _isSelected = List.filled(_isSelected.length, false , growable: true);
              _isMessageSelected = false;
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    screenWidth = MediaQuery.of(context).size.width;
    _getChats();
     return Scaffold(
       backgroundColor: Colors.black,
      //backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      appBar: _isMessageSelected ? selectionAppBar(): mainAppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 8,
              child: messageListFutureBuilder()
          ),
          Expanded(
            flex: 1,
              child: Container(
                height: 200,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent, width: 2),
                  color: Colors.black45
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex:4,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1,color: Colors.black),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(10),right: Radius.circular(10))
                          ),
                          child: Center(
                              child:TextField(
                              style: TextStyle(color: Colors.white , fontSize: 20),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: 'Enter Message here',
                                hintStyle: TextStyle(color: Colors.white , fontSize: 15),
                                border: InputBorder.none
                              ),
                              controller: _messaggeController,
                              minLines: 1,
                              maxLines: 1000,
                              textInputAction: TextInputAction.newline,
                            ),
                          )
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          iconSize: 25,
                          icon: Icon(Icons.send , color: Colors.indigo,),
                          onPressed: (){
                            sendMessage(_messaggeController.text);
                          },
                        )
                    ),
                  ],
                ),
              )
          )
        ],
      ),
    );
  }

}



