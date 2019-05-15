var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

const players = {};

const initialPlayer = {
  x: 0,
  y: 0
};

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', function(socket){
  console.log('user connected to socket');

  socket.on('player_move', function(player) {
    if (!player.id || !players[player.id]) return;
    const currentPlayer = players[player.id];
    players[player.id] = Object.assign({}, currentPlayer, player);
    // Emit to other players
    socket.emit('some_player_move', players[player.id]);
  })

  // When a player logs in to the room
  socket.on('player_login', function(player) {
    if (!player.id || players[player.id]) return;
    players[player.id] = Object.assign(initialPlayer, player, { socketId: socket.conn.id, number: Object.values(players).length + 1 });
    console.log('A Player has logged in')
    console.log(players);
    socket.emit('player_logged_in', players[player.id]);
  });

  socket.on('disconnect', function() {
    // Find and remove delete player
    console.log('a Player disconnected')
    const disconnectedPlayer = Object.values(players).find(player => player.socketId === socket.conn.id);
    if (!disconnectedPlayer || !disconnectedPlayer.id || !players[disconnectedPlayer.id]) return;
    delete players[disconnectedPlayer.id];
    console.log('A player disconnected');
    socket.emit('player_disconnected', disconnectedPlayer);
  });
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});