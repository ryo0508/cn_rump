Games = new Meteor.Collection("games")
Players = new Meteor.Collection("players")

# Set Player ID
Session.setDefault('player_id', null)

# Set Current Game 
Session.setDefault('current_game', null)

if Meteor.isClient
  Template.game_list.games = () ->
    Games.find()

  Template.player_list.players = () ->
    Players.find()

  Template.add_players.events
    'click #login': () ->
      Players.insert {name: document.getElementById('your_name').value}, (err, id) ->
        console.log "set player id => #{id}"
        Session.set('player_id', id)
    'click #logout_btn': () ->
      Players.remove({_id: Session.get('player_id')})
      Session.set('player_id', null)
  Template.add_players.is_logged_in = () ->
    Session.equals('player_id', null)
  Template.add_players.player = () ->
    unless Session.equals('player_id', null)
      Players.findOne(Session.get('player_id'))

  Template.game_list_row.is_logged_in = () ->
    !Session.equals('player_id', null)

  Template.game_list_row.events
    'click .join_btn': () ->
      
      _this_game = Games.findOne(this._id)
      unless _this_game.player_one?
        Games.update({ _id: this._id }, {$set: { 'player_one': Session.get('player_id')}})
      else unless _this_game.player_two?
        Games.update({ _id: this._id }, {$set: { 'player_two': Session.get('player_id')}})
      else
        return false

      Session.set('current_game', this._id)
      $('#game_main').modal('toggle')

      $('#game_main').one 'hidden', () ->
        Games.update({player_one: Session.get('player_id')}, {$set: { 'player_one': null}})
        Games.update({player_two: Session.get('player_id')}, {$set: { 'player_two': null}})

  Template.game_main.game = () ->
    Games.findOne(Session.get('current_game'))


if Meteor.isServer
  Meteor.startup ->
    # Players.remove({})
    # Games.remove({})
    if Games.find().count() == 0
      games = [
        'room1',
        'room2',
        'room3',
        'room4',
        'room5',
        'room6',
      ]

      for game in games
        Games.insert({name: game, progress: null, player_one: null, player_two: null})
