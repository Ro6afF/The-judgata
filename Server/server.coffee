http = require 'http'
https = require 'https'
express = require 'express'
stylus = require 'express-stylus'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
coffee = require 'coffee-middleware'

routes = 
    accounts: require __dirname + '/routes/accounts' 
    home: require __dirname + '/routes/home'
    quizes: require __dirname + '/routes/quizes'
    problems: require __dirname + '/routes/problems'

modules = 
    user: require __dirname + '/modules/user'
    
app = express()
        
app.use coffee
    src: __dirname + '/static/js'
    compress: true
    bare: true
    
app.use stylus 
    src: __dirname + '/static/css'
    
app.use express.static 'static/css'
app.use express.static 'static/html'
app.use express.static 'static/js'
app.use express.static 'static/images'
app.use express.static 'node_modules'

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)

app.use cookieParser()

app.set 'view engine', 'jade'

app.get '/', routes.home.getIndex

app.get '/about', routes.home.getAbout

app.get '/user/login', routes.accounts.getLogin
app.post '/user/login', routes.accounts.postLogin

app.get '/user/register', routes.accounts.getRegister
app.post '/user/register', routes.accounts.postRegister

app.get '/user/logout', routes.accounts.logout
app.post '/user/logout', routes.accounts.logout

app.get '/user/details', routes.accounts.getDetails
app.get '/user/details/:username', routes.accounts.getDetailsGlobal

app.get '/quiz/create', routes.quizes.getCreate
app.post '/quiz/create', routes.quizes.postCreate

app.get '/quiz/edit/:id', routes.quizes.getEdit
app.post '/quiz/edit/:id', routes.quizes.postEdit

app.post '/quiz/newProblem/:id', routes.quizes.postNewProblem

app.get '/quiz/submit/:id', routes.quizes.getSubmit
app.post '/quiz/submit/:id', routes.quizes.postSubmit

app.get '/quiz/test/:id', routes.quizes.getTest

app.get '/quiz/results/:id', routes.quizes.getResults

app.get '/quiz/source/:id', routes.quizes.downloadSource

app.get '/quiz/details/:id', routes.quizes.getSubmitDetails

app.get '/problem/create', routes.problems.getCreate
app.post '/problem/create', routes.problems.postCreate

app.get '/problem/edit/:id', routes.problems.getEdit
app.post '/problem/edit/:id', routes.problems.postEdit

app.post '/problem/newOption/:id', routes.problems.postNewOption

app.use (req, res, next) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
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