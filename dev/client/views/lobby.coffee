#View responsible for the game lobby
class LobbyView extends Backbone.View
  collection: S.Collections.Messages

  initialize: ->
    @communicator = @options.communicator

    #Get temaplates
    @messageTemplate = Handlebars.templates['lobbyMessage']
    @messagesTemplate = Handlebars.templates['lobbyMessages']
    #@gamesTemplate = Handlebars.templates['lobbyGames']
    #@gameTemplate = Handlebars.template['lobbyGame']

    #Bind to changes and update the view
    @collection.bind 'add', @addMessage
    @collection.bind 'reset', @resetMessages
    @games = new S.Collections.Messages
    @games.bind 'add', @addGame

    #Listen to the server
    @communicator.on 'message:new', @handleServerMessage
    @communicator.on 'user', @handleUser
    #Update list of games when something interesting happens
    @communicator.on 'game:lobby:new', @handleNewGame
    @communicator.on 'game:lobby:change', @handleGameChange
    @communicator.on 'game:lobby:close', @handleGameClose

    #Bootstrap data
    @communicator.on 'friends:load', @handleFriends
    @communicator.on 'chat:load', @handleChat

    KeyboardJS.bind.key 'enter', @newMessage, =>
      $( '#chat textarea:focus' ).val ''

  #Add new message to the chat
  addMessage: ( model ) =>
    msg = model.toJSON()
    console.log "[Chat] New message", msg

    msg = @messageTemplate msg
    $( '#chat ul' ).append msg
    $( "#chat .nano" ).nanoScroller scroll: 'bottom'

  # Reset chat with messages from the server
  resetMessages: () =>
    msgs = @collection.toJSON()
    console.log "[Chat] Reset", msgs

    html = @messagesTemplate messages: msgs
    $( '#chat ul' ).html html
    $( "#chat .nano" ).nanoScroller scroll: 'bottom'

  # Add new game to lobby
  addGame: ( model ) =>
    console.log "Lobby: New Game"

  handleFriends: ( friends  ) =>
    console.log "[Lobby] friends", friends

    friends.push @user
    friends = _.sortBy friends, ( o ) -> o.highscore

    maxScore = friends[0].highscore
    if maxScore < 1000
      maxScore = 1000

    minScore = 0
    scale = (maxScore + minScore) / 10

    now = maxScore
    groups = {}
    group = 10

    groups[10] =
      class: 10
      users: []

    (
      #prepare object
      f.firstname = f.name.split(' ')[0]

      if f.highscore > now - scale
        #add user to a group if it is not already full
        if groups[group].users.length < 3
          groups[group].users.push f
      else
        #fix the group index
        m = Math.floor (now - f.fighscore)/scale
        now = now - m*scale
        group -= m

        #create new group and add user
        groups[group] =
          class: group
          users: []

        groups[group].users.push f
    ) for f in friends

    if groups[10].users.length == 0
      delete groups[10]

    scoreTemplate = Handlebars.templates.highscoreTicker
    html = scoreTemplate groups: groups

    console.log html, maxScore, groups

    $( ".ranking ul" ).html html
    $( ".userScore" ).html maxScore

  handleChat: ( messages ) =>
    console.log "[Lobby] chat ", messages

    if messages.length? and messages.length > 0
      msgs = ((
        msg.author = msg.sender.name
        msg.sender = msg.sender._id
        msg)for msg in messages)

      @collection.reset msgs

  handleNewGame: ( data ) =>
    console.log 'Lobby: New game has been created'
    game = new S.Models.Game data
    @games.add game

  handleServerMessage: ( data ) =>
    console.log "Lobby: Server message"
    msg = new S.Models.Message data
    @collection.add msg

  handleUser: ( user ) =>
    @user = user
    @communicator.trigger "fetch:friends", user
    @communicator.trigger "fetch:messages", 'lobby'

  newMessage: =>
    #Get the textarea and check if we are focused on it
    textarea = $ '#chat textarea:focus'
    if textarea.length > 0

      #set message attributes
      author = @user.name
      message = textarea.val()
      sender = @user._id

      date = new Date()
      hour = date.getHours()
      minute = date.getMinutes()

      if hour < 10
        hour = "0#{ hour }"

      if minute < 10
        minute = "0#{ minute }"

      time = "#{ hour }:#{ minute }"

      #clean textarea value
      textarea.val ''

      #create the message
      msg = new S.Models.Message
        author: author
        content: message
        sender: sender
        time: time
        channel: 'lobby'

      #add message to the collection
      @collection.add msg

      #send message to the server
      @communicator.trigger 'message:add', msg.toJSON()

  render: =>
    msgs =  @messagesTemplate messages: @collection.toJSON()

    $( '#chat ul' ).html msgs
    $( "#chat .nano" ).nanoScroller()

window.S.Views.LobbyView = LobbyView
