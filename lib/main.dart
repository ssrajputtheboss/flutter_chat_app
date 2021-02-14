import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpPackage;
import 'package:shared_preferences/shared_preferences.dart';
var http = httpPackage.Client();
bool inProduction = false;

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
  var _url = inProduction ? 'server base url' :'http://10.0.2.2:3001/';
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
      _isLoggedIn = json.decode(data['status']);
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

  logInView() {
    return Scaffold(
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
                  controller: _emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Email'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Email';
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Password'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Password';
                    if(value.length<8)return 'password should be of atleast 8 chracters';
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
                  controller: _nameController,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Name'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Name';
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Email'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Email';
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(border: OutlineInputBorder(),hintText: 'Password'),
                  validator: (String value){
                    if(value.trim().isEmpty)return 'please Enter Password';
                    if(value.length<8)return 'password should be of atleast 8 chracters';
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
                      child: Column(
                        children: [
                          Center(
                            child: DropdownButtonFormField(
                              value: _dropdownValue=_searchList[0]['user_id'],
                              itemHeight: 100,
                              items: _searchList.map((e){
                                return DropdownMenuItem(
                                  value: e['user_id'],
                                  child: Text(e['name'] + '\n '),
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
                               Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, id, n , _cookie)));
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
                _logOutUser();
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatViewStateLess( _uid, _chatList[i]['uid'], _chatList[i]['name'] , _cookie)));
                  },
                  child:Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Color.fromRGBO(200, 200, 200, 1.0)
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
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    'last message',
                                    style: TextStyle(fontSize: 25),
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
  var _cookie;
  ChatViewStateLess(int pid,int id,String name,cookie){
    _pid = pid;
    _uid = id;
    _name = name;
    _cookie = cookie;
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
      home: ChatView(_pid,_uid,_name,_cookie),
    );
  }

}


class ChatView extends StatefulWidget{
  int _uid,_pid;String _name='';
  var _cookie;
  ChatView(int pid,int uid,String name, cookie, {Key key}) : _pid=pid,_uid=uid,_name=name,_cookie = cookie,super(key: key);
  @override
  _ChatViewStates createState() => _ChatViewStates(_pid,_uid,_name , _cookie);
}

class _ChatViewStates extends State<ChatView>{
  var _url = inProduction ? 'server base url' :'http://10.0.2.2:3001/';
  int _uid,_pid;String _name='',_pName;
  var _chats=[];
  var _cookie;
  TextEditingController _messaggeController = TextEditingController();

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

  _ChatViewStates(int pid,int uid,String name,cookie){
    _pid = pid;
    _uid =uid;
    _name = name;
    _cookie = cookie;
    _getUserData();
  }

  messageView(data){
    return Align(
      alignment: data['to_id']==_uid ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(5.0) , right: Radius.circular(5.0)),
          color: Colors.lightGreen
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Text(data['to_id']==_uid ? _pName : _name , style: TextStyle( fontWeight: FontWeight.bold),),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  child: Text(data['msg']+'\n  ' , style: TextStyle(),),
                ),
                Container(
                  child: Text(data['msgtime'] , style: TextStyle(fontSize: 10),),
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
    _getChats();
    return Scaffold(
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
        title: Text(_name,style: TextStyle(fontWeight: FontWeight.bold),),
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
                itemCount: _chats.length,
                  itemBuilder: (context,i){
                return messageView(_chats[i]);
              })
          ),
          Expanded(
            flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black , width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                        flex:4,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1,color: Colors.grey),
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(10),right: Radius.circular(10))
                          ),
                          child: TextField(
                            controller: _messaggeController,
                          ),
                        )
                    ),
                    Expanded(
                        flex: 1,
                        child: IconButton(
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


