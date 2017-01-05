http = require 'http'
https = require 'https'
express = require 'express'
stylus = require 'stylus'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
coffee = require 'coffee-middleware'

routes = 
    accounts: require __dirname + '/routes/accounts' 
    home: require __dirname + '/routes/home'
    quizes: require __dirname + '/routes/quizes'
    contests: require __dirname + '/routes/contests'
    problems: require __dirname + '/routes/problems'

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

app.get '/quiz/results/:id', routes.quizes.getResults

app.get '/:contest/submit', routes.contests.getSubmit
app.post '/:contest/submit', routes.contests.postSubmit

app.get '/problem/create', routes.problems.getCreate
app.post '/problem/create', routes.problems.postCreate


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