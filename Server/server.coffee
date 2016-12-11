http = require 'http'
https = require 'https'
express = require 'express'
stylus = require 'stylus'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
coffee = require 'coffee-middleware'

routes = 
    accouts: require __dirname + '/routes/accounts' 
    home: require __dirname + '/routes/home'
    quizes: require __dirname + '/routes/quizes'

modules = 
    user: require __dirname + '/modules/user'
    
app = express()
        
app.use express.static 'static/css'
app.use express.static 'static/html'
app.use express.static 'static/js'
app.use express.static 'static/images'

app.use coffee
    src: __dirname + '/static/js'
    compress: true
    bare: true

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)

app.use cookieParser()

app.use stylus.middleware __dirname + '/static/css'

app.set 'view engine', 'jade'


app.get '/', routes.home.getIndex

app.get '/about', routes.home.getAbout

app.get '/login', routes.accouts.getLogin
app.post '/login', routes.accouts.postLogin

app.get '/register', routes.accouts.getRegister
app.post '/register', routes.accouts.postRegister

app.get '/logout', routes.accouts.logout
app.post '/logout', routes.accouts.logout

app.get '/quiz/create', routes.quizes.getCreate
app.post '/quiz/create', routes.quizes.postCreate

app.get '/quiz/edit/:id', routes.quizes.getEdit
# Implement post

app.use (req, res, next) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        res.status 404
        res.render 'error', 
            title: '404',
            user: name,
            text: 'Page not found'
    return

httpServer = http.createServer app 
httpServer.listen 3000
console.info 'Listening on *:3000'

#httpsServer = https.createServer(app)
#httpsServer.listen 5000