class ChatData{
  String _currentUserName='',_roomName='';
  int _currentUserId,_roomId;
  var _cookie = '';
  set currentUserId (int userId){
    this._currentUserId = userId;
  }
  set currentUserName(String userName){
      this._currentUserName = userName;
  }
  set roomId(int roomId){
    this._roomId = roomId;
  }
  set roomName(String roomName){
    this._roomName = roomName;
  }
  set cookie(cookie){
    this._cookie = cookie;
  }

  get getCookie => _cookie;
  get getCurrentUserId => _currentUserId;
  get getCurrentUserName => _currentUserName;
  get getRoomId => _roomId;
  get getRoomName => _roomName;


}