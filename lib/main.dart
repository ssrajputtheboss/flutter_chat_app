import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_highlight/text_highlight.dart';
import 'package:text_highlight/tools/highlight_theme.dart';

var http = httpPackage.Client();
bool inProduction = true;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  var _url = inProduction ? 'http://192.168.43.148:3001/' :'http://10.0.2.2:3001/';
  int _uid = 0 ;String _name = '';
  var _dropdownValue;
  var _cookie='';
  var _isLoggedIn=false , _toggleLoginSignup =true;
  var _chatList = [] , _searchList = [];
  TextEditingController _emailController= TextEditingController(), _passwordController=TextEditingController(),_nameController=TextEditingController();

  _saveCookie()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('cookie', _cookie);
  }

  _getCookie()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _cookie = sharedPreferences.get('cookie') ?? '';
  }

  getChatList()async{
    var res = await http.post(_url+'chatlist',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _chatList = data['chatlist'];
    });
  }

  _getSearchList()async{
    var res = await http.post(_url+'searchlist',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _searchList = data['searchlist'];
    });
  }

  setUser()async{
    var res = await http.post(_url+'userdata',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _uid =  data['user_id'];
      _name = data['name'];
    });
  }

  _logInUser()async{
    var email = _emailController.text,password = _passwordController.text;
    var res = await http.post(_url+'login',
        body: json.encode(<String,String>{
          'email':email,
          'password':password,
        }),headers:<String ,String>{
          'Content-type':'application/json; charset=UTF-8'
        }
    );
    /*var res = await http.post(_url+'login',body: json.encode({
      'email':email,
      'password':password,
    }),headers:{
      'Content-type':'application/json; charset=UTF-8'
    });*/
    var data = json.decode(res.body);
    setState(() {
      _isLoggedIn = data['status'];
      _cookie = res.headers['set-cookie'];
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
      'Content-type': 'application/json; charset=UTF-8'
    });
    var data = json.decode(res.body);
    setState(() {
      _isLoggedIn = data['status'];
    });
  }

  _logOutUser()async{
    var res = await http.post(_url+'logout',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _chatList = [];
      _searchList = [];
      _uid = 0;
      _name = '';
      _cookie = '';
      _isLoggedIn = false;
    });
  }

  optionsDialog(){
    return Align(alignment: Alignment.topRight, child :RaisedButton(
      elevation: 10,
      child: Text('logout',style: TextStyle(fontSize: 25 ),),
      onPressed: (){
        _logOutUser();
        Navigator.pop(context);
      },
    ),);
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
                    onPressed: _logInUser,
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
      body: Center(
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
                    if(value.length<8)return 'password should be of atleast 8 chracters';
                    return '';
                  },
                ),
                TextButton(
                    onPressed: _signUpUser,
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
      ),
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
                  child: Dialog(
                    elevation: 5,
                    child: Container(
                      height: 120.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red , width: 2),
                        color: Color.fromRGBO(50, 50, 50, 1)
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: DropdownButtonFormField(
                              dropdownColor: Color.fromRGBO(50, 50, 50, 1),
                              value: _dropdownValue=_searchList[0]['user_id'],
                              itemHeight: 100,
                              items: _searchList.map((e){
                                return DropdownMenuItem(
                                  value: e['user_id'],
                                  child: Text(e['name'] + '\n ' , style: TextStyle(color: Colors.white),),
                                );
                              }).toList(),
                              onChanged: (v){
                                _dropdownValue = v;
                              },
                            ),
                          ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                             IconButton(icon: Icon(Icons.send_rounded), onPressed: (){
                               var id = _dropdownValue,n;
                               for(var e in _searchList){
                                 if(e['user_id']== id){
                                   n=e['name'];
                                   break;
                                 }
                               }
                               Navigator.pop(context);
                               Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, id, n , _cookie , (){Navigator.pop(context);})));
                             }),
                             IconButton(icon: Icon(Icons.close), onPressed: (){
                                Navigator.pop(context);
                             })
                           ],
                         )
                        ],
                      ),
                    )
                  )
                );
              }
          ),
          IconButton(
              icon: Icon(Icons.more_vert,color: Colors.blue,),
              onPressed: (){
                showDialog(
                    context: context,
                  child: optionsDialog(),
                );
              }
          )
        ],
      ),
      body: ListView.builder(
          itemCount: _chatList.length,
          itemBuilder: (BuildContext context,int i){
            return Container(
              child: GestureDetector(
                  onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, _chatList[i]['uid'], _chatList[i]['name'] , _cookie , (){Navigator.pop(context);})));
                  },
                  child:Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: i==(_chatList.length-1)? Border() : Border(bottom: BorderSide(color: Color.fromRGBO(0,75, 0, 1) )),
                      color: Color.fromRGBO(0, 30, 30, 1.0)
                    ),
                    child:Row(
                      mainAxisSize: MainAxisSize.max,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(1),
                            child:IconButton(
                              icon: Icon(
                                  Icons.person_rounded,
                                size: 40,
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
                                    _chatList[i]['name'],
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 25 , color: Colors.white),
                                  ),
                                  Text(
                                    _chatList[i]['lastmsg'] ==null ?  '' :_chatList[i]['lastmsg'],
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
      })
    );
  }


  @override
  Widget build(BuildContext context) {
    ()async{
      await _getCookie();
      var res = await http.get(_url+'home',headers: {
        'Content-type': 'application/json; charset=UTF-8',
        'cookie' : _cookie
      });
      var data = json.decode(res.body);
      if(data['status']!=_isLoggedIn)
      setState(() {
        _isLoggedIn = data['status'];
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

class ChatViewStateLess extends StatelessWidget{
  int _uid=0,_pid=0;
  String _name='';
  var _cookie,_callback;
  ChatViewStateLess(int pid,int id,String name,cookie,callback){
    _pid = pid;
    _uid = id;
    _name = name;
    _cookie = cookie;
    _callback = callback;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatView(_pid,_uid,_name,_cookie,_callback),
    );
  }

}


class ChatView extends StatefulWidget{
  int _uid,_pid;String _name='';var _callback;
  var _cookie;
  ChatView(int pid,int uid,String name, cookie, callback, {Key key}) : _pid=pid,_uid=uid,_name=name,_cookie = cookie,_callback = callback,super(key: key);
  @override
  _ChatViewStates createState() => _ChatViewStates(_pid,_uid,_name , _cookie , _callback);
}

class _ChatViewStates extends State<ChatView>{
  var _url = inProduction ? 'http://192.168.43.148:3001/' :'http://10.0.2.2:3001/';
  int _uid,_pid;String _name='',_pName;
  var _chats=[];
  var _cookie,_callback;
  double screenWidth ;
  TextEditingController _messaggeController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  _getChats()async{
    var res = await http.post(_url+'chats',
        body: json.encode(<String,dynamic>{
          'to_id' : _uid
        }),
        headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _chats =  data['chats'];
    });
  }

  _getUserData()async{
    var res = await http.post(_url+'userdata',headers: {
      'Content-type': 'application/json; charset=UTF-8',
      'cookie' : _cookie
    });
    var data = json.decode(res.body);
    setState(() {
      _pName = data['name'];
    });
  }

  sendMessage(String msg)async{
    var res = await http.post(_url+'sendmsg',
        body: json.encode(<String,dynamic>{
          'to_id' : _uid,
          'to_name' : _name,
          'my_name' : _pName,
          'msg' : msg,
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'cookie' : _cookie
        });
    var data = json.decode(res.body);
    setState(() {
      if(data['msg_status']){
        _getChats();
        _messaggeController.text = '';
      }
    });
  }

  _ChatViewStates(int pid,int uid,String name,cookie,callback){
    _pid = pid;
    _uid =uid;
    _name = name;
    _cookie = cookie;
    _getUserData();
    _callback = callback;
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

  messageView(data){
    return Align(
      alignment: data['to_id']==_uid ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth*0.9),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          //border: Border.all(color: Colors.yellow),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(25.0) , right: Radius.circular(25.0)),
          color: Color.fromRGBO(20, 20, 20, 1)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Text(data['to_id']==_uid ? 'You' : _name , style: TextStyle( fontWeight: FontWeight.bold , color: data['to_id']==_uid ? Color.fromRGBO(180, 0, 180, 1) : Color.fromRGBO(0, 180, 180, 1)),),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                   Container(
                    child: HighlightText(data['msg']+'\n  ' , mode: HighlightTextModes.AUTO,),
                  ),
                Container(
                  child: Text(stringTime(data['msgtime']) , style: TextStyle(fontSize: 10 , fontWeight: FontWeight.w300, color: Colors.yellow,)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    screenWidth = MediaQuery.of(context).size.width;
    _getChats();
     return Scaffold(
      backgroundColor: Color.fromRGBO(50, 50, 50, 1),
      appBar: AppBar(
        leading: Container(
            child: Center(
              child:
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                  ),
                  onPressed: (){
                    _callback();
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
            Text(_name,style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        ) ,
        actions: [
          IconButton(
              icon: Icon(Icons.more_vert,color: Colors.blue,),
              onPressed: null
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chats.length,
                  itemBuilder: (context,i){
                return messageView(_chats[i]);
              })
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



