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
    console.log('someone moved');
    if (!player.id || !players[player.id]) return;
    const currentPlayer = players[player.id];
    players[player.id] = Object.assign({}, currentPlayer, player);
    // Emit to other players
    io.emit('some_player_move', players[player.id]);
  })

  // When a player logs in to the room
  socket.on('player_login', function(player) {
    console.log('someone is logging in')
	  console.log(player);	  
    if (!player.id || players[player.id]) return;
    let playerNumber = findPlayerNumber();
    players[player.id] = Object.assign(initialPlayer, player, { socketId: socket.conn.id, number: playerNumber });
    console.log('A Player has logged in')
    console.log(players);
    io.emit('player_logged_in', players);
  });

  socket.on('player_finish', function(player) {
    // save date of arrival for player if it exists and if it did not finish the race yet
    if (!player || !player.id || !players[player.id] || players[player.id].finishedAt) return;
    players[player.id] = Object.assign(players[player.id], player, { finishedAt: Date.now() });

    // check if all players finished the race
    let i = 0;
    let allFinished = true;
    const playersArray = Object.values(players);
    do {
      const currentPlayer = playersArray[i];
      if (!currentPlayer.finishedAt) allFinished = false;
      i++;
    } while(i < playersArray.length || allFinished);

    if (allFinished) {
      // Sort players -> Time of finish line
      playersArray.sort(function(a,b){
        return b.finishedAt - a.finishedAt;
      });
      io.emit('game_finished', playersArray);
    }
  });

  socket.on('disconnect', function() {
    // Find and remove delete player
    console.log('a Player disconnected')
    const disconnectedPlayer = Object.values(players).find(player => player.socketId === socket.conn.id);
    if (!disconnectedPlayer || !disconnectedPlayer.id || !players[disconnectedPlayer.id]) return;
    delete players[disconnectedPlayer.id];
    console.log('A player disconnected');
    io.emit('player_disconnected', disconnectedPlayer);
  });
});

const findPlayerNumber = () => {
  let playerNumber = 1;
  while (true) {
    const player = Object.values(players).find(p => p.number === playerNumber);
    if (!player) {
      return playerNumber;
    }
    playerNumber++;
  }
}

http.listen(3000, function(){
  console.log('listening on *:3000');
});
