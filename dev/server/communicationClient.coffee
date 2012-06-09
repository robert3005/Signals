class ComClient
  constructor: ( @socket ) ->
    @id = 7
    @channel = null

  getChannel: =>
    @channel

  getSocket: =>
    @socket

  getId: =>
    @id

  joinChannel: ( channel ) =>
    @channel = channel
    @socket.join channel

  leaveChannel: ( channel ) =>
    @channel = null

module.exports = exports = ComClient
