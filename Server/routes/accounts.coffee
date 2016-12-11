crypto = require 'crypto'

modules = 
    db: require '../modules/db'
    user: require '../modules/user'
    
models = 
    user: require '../models/user'
    session: require '../models/session'

randomString = (length, chars) ->
    result = ''
    i = length
    while i > 0
        result += chars[Math.floor Math.random() * chars.length]
        --i
    result

checkSessionId = (sessionId) ->
    asd = true
    modules.db.find models.session.type, { id: sessionId }, (err, sessions) ->
        if sessions.length > 0
            asd = false
        return
    asd
    
getLogin = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if !name
            res.render 'login', title: 'Login'
        else    
            res.redirect '/'
        return
    return

postLogin = (req, res) ->
    user = modules.db.find models.user.type, { username: req.body.email }, (err, usr) ->
        if !usr.length
            res.render 'login',
                title: 'Login',
                err: 'Invalid username or password!'
        else
            if usr[0].password == crypto.createHmac('sha1', usr[0].passwordsha1).update(req.body.password).digest 'hex'
                sessionId = ''
                loop
                    sessionId = randomString 64, '`1234567890-=qwetyuiop[]asdfghjkl;\'\\zxcvbnm,./~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:"|ZXCVBNM<>?åöäÅÖÄявертъуиопшщасдфгхйклюзьцжбнмЧ№€§=-½¤='
                    if checkSessionId(sessionId)
                        break
                if req.body.rememberme
                    res.cookie 'sessionId', sessionId, expires: new Date(253402300000000)
                else
                    res.cookie 'sessionId', sessionId
                modules.db.add new (models.session.type)(
                    id: sessionId
                    username: usr[0].username), (a) ->
                res.redirect '/'
            else
                res.render 'login',
                    title: 'Login'
                    err: 'Invalid username or password!'
        return
    return


getRegister = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if !name
            res.render 'register', title: 'Register'
        else    
            res.redirect '/'
        return
    return

postRegister = (req, res) ->
    modules.db.find models.user.type, {username: req.body.email}, (err, usr) ->
        if usr.length
            res.render 'register', 
                title: 'Register'
                err: 'User with that email has already registered!'
        else 
            if req.body.password.length > 6 && req.body.password.length < 100
                if req.body.password == req.body.password2
                    date = (new Date).toString()
                    date = crypto.createHmac('sha1', 'QuiZ3rr$').update(date).digest 'hex'
                    modules.db.add new (models.user.type)(
                        username: req.body.email
                        passwordsha1: date
                        password: crypto.createHmac('sha1', date).update(req.body.password).digest 'hex'
                        email: req.body.email
                        avatar: undefined), (a) ->
                        res.redirect '/'
                        return
                else
                    res.render 'register', 
                        title: 'Register'
                        err: 'Passwords do not match!'
            else
                res.render 'register', 
                        title: 'Register'
                        err: 'Password\'s length must be between 6 and 100 symbols!'
        return
    return 


logout = (req, res) ->
    res.cookie 'sessionId', undefined
    modules.db.remove models.session.type, { id: req.cookies.sessionId }, (err) ->
    res.redirect '/'
    return


exports.getLogin = getLogin
exports.postLogin = postLogin

exports.getRegister = getRegister
exports.postRegister = postRegister

exports.logout = logout