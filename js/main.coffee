class Servers extends Spine.Controller
  constructor: ->
    super
    @connect()
  connect: =>
    #$('#rooms').html '正在连接...'
    wsServer = 'ws://mycard-server.my-card.in:9998'
    websocket = new WebSocket(wsServer);
    websocket.onopen = ->
      #$('#rooms').html '正在读取房间列表...'
      console.log("websocket: Connected to WebSocket server.")
      Room.deleteAll()
    websocket.onclose = (evt)=>
      $('#rooms').html '大厅连接中断, '
      $('<a />', id: 'reconnect', text: '重新连接').appendTo $('#rooms')
      $('#reconnect').click @connect
      console.log("websocket: Disconnected");
    websocket.onmessage = (evt)->
      rooms = JSON.parse(evt.data)
      for room in rooms
        if room._deleted
          Room.find(room.id).destroy() if Room.exists(room.id)
      Room.refresh ($.extend({ip: '127.0.0.1', player1: (if room.users.length then room.users[0].name), player2: (if room.status == 'wait' then '等待中' else '已开始'), port: 10800, name: '', ping: '-'}, room) for room in rooms when !room._deleted)
    websocket.onerror = (evt)->
      console.log('websocket: Error occured: ' + evt.data);


class Room extends Spine.Model
  @configure "Room", "name", "status", "ip", "port"

class Rooms extends Spine.Controller
  events:
    'click .room': 'clicked'
  constructor: ->
    super
    Room.bind "refresh", @render
  render: =>
    #@html $('#room_template').tmpl Room.all()
    $('#rooms_table').dataTable().fnClearTable()
    $('#rooms_table').dataTable().fnAddData(Room.all())
  clicked: (e)->
    room = $(e.target).tmplItem().data
    console.log room


rooms = new Rooms(el: '#rooms')
servers = new Servers()
$('#rooms_table').dataTable
  aoColumns: [
    {sTitle: '玩家', mData: 'player1'}
    {sTitle: '状态', mData: 'player2' }
    {sTitle: 'IP', mData: 'ip' }
    {sTitle: '端口', mData: 'port' }
    {sTitle: '说明', mData: 'name' }
    {sTitle: 'Ping', mData: 'ping' }
  ]
  aaSorting: [ [1,'desc'], [5,'asc'] ]

$('#rooms_table tbody tr').live 'click', ->
  row = $('td', this)
#  row[]

$('#login').submit ->
  $('#candy').show()
  Candy.init 'http://my-card.in:5280/http-bind/',
    core:
      debug: false
      autojoin: ['shinkirou@conference.my-card.in']
    view:
      language: 'cn'
      resources: 'js/vendor/candy/res/'

  Candy.Core.connect(@name.value + '@my-card.in', @password.value)
  false

