express = require 'express'
hbs = require 'hbs'
app = module.exports = express.createServer()
app.everyauth = require 'everyauth'
app.everyauth.helpExpress(app)

Pusher = require 'node-pusher'
app.RedisStore = require('connect-redis')(express)

pusher = new Pusher
  appId: '21008',
  key: 'a610720749c820f0e140',
  secret: '160b340e826a3776e4a6'

# Heroku redistogo connection
if process.env.REDISTOGO_URL
  rtg   = require('url').parse process.env.REDISTOGO_URL
  app.redis = require('redis').createClient rtg.port, rtg.hostname
  app.redis.auth rtg.auth.split(':')[1] # auth 1st part is username and 2nd is password separated by ":"
# Localhost
else
  app.redis = require("redis").createClient()


config = require('./config.coffee')(app, express);

app.get '/', ( req, res ) ->
  if app.requireAuth and not req.loggedIn
    #res.redirect('/auth/facebook');
  #else
    res.render 'testchat',
      title: 'Signals early chat tests'

port = process.env.PORT || 3000

app.listen port, ->
  console.log "Listening on " + port

app.on 'close', ->
  done()
