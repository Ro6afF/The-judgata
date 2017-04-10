crypto = require 'crypto'

modules = 
    db: require '../modules/db'
    user: require '../modules/user'
    
models = 
    user: require '../models/user'
    session: require '../models/session'
    result: require '../models/result'

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
            res.render 'user/login', title: 'Login'
        else    
            res.redirect '/'
        return
    return

postLogin = (req, res) ->
    user = modules.db.find models.user.type, { username: req.body.email }, (err, usr) ->
        if !usr.length
            res.render 'user/login',
                title: 'Login',
                err: 'Invalid username or password!'
        else
            if usr[0].password == crypto.createHmac('sha256', usr[0].passwordsha256).update(req.body.password).digest 'hex'
                sessionId = ''
                loop
                    sessionId = randomString 64, '`1234567890-=qwetyuiop[]asdfghjkl;\'\\zxcvbnm,./~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:"|ZXCVBNM<>?åöäÅÖÄßüÜявертъуиопшщасдфгхйклюзьцжбнмЧ№€§=-½¤=ЯВЕРТЪУИОПШЩАСДФГХЙКЛЗѝЦЖБНМ“;ςερτυθιοπλκξηγφδσαζχψωβνμ3ΕΡΤΥΘΙΟΠΑΣΔΦΓΗΞΚΛΖΧΨΩΒΝΜ'
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
                res.render 'user/login',
                    title: 'Login'
                    err: 'Invalid username or password!'
        return
    return


getRegister = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if !name
            res.render 'user/register', title: 'Register'
        else    
            res.redirect '/'
        return
    return

postRegister = (req, res) ->
    modules.db.find models.user.type, {username: req.body.email}, (err, usr) ->
        if usr.length
            res.render 'user/register', 
                title: 'Register'
                err: 'User with that email has already registered!'
        else 
            if req.body.password.length > 6 && req.body.password.length < 100
                if req.body.password == req.body.password2
                    date = (new Date).toString()
                    date = crypto.createHmac('sha256', 'QuiZ3rr$').update(date).digest 'hex'
                    modules.db.add new (models.user.type)(
                        username: req.body.email
                        passwordsha256: date
                        password: crypto.createHmac('sha256', date).update(req.body.password).digest 'hex'
                        email: req.body.email
                        avatar: undefined), (a) ->
                        res.redirect '/'
                        return
                else
                    res.render 'user/register', 
                        title: 'Register'
                        err: 'Passwords do not match!'
            else
                res.render 'user/register', 
                        title: 'Register'
                        err: 'Password\'s length must be between 6 and 100 symbols!'
        return
    return 


logout = (req, res) ->
    res.cookie 'sessionId', undefined
    modules.db.remove models.session.type, { id: req.cookies.sessionId }, (err) ->
    res.redirect '/'
    return

calculateResultsFor = (name, cb) ->
    modules.db.find models.result.type, { user: name }, (err, resultsdb) ->
            results = {}
            for i in resultsdb
                if (!results[i.contestName])
                    results[i.contestName] = {}
                if (!results[i.contestName][i.task]) || results[i.contestName][i.task] < i.result
                    results[i.contestName][i.task] = i.result
            for i of results
                results[i]['total'] = 0
                for j of results[i]
                    if j != 'total'
                        results[i]['total'] += results[i][j]
            results['total'] = 0
            for i of results
                if i != 'total'
                    results['total'] += results[i]['total']
            cb(results)

getDetails = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        calculateResultsFor name, (results) ->
                res.render 'user/details', 
                    title: 'Details'
                    username: name
                    results: results

getDetailsGlobal = (req, res) ->
    calculateResultsFor req.params.username, (results) ->
        modules.user.getUsername req.cookies.sessionId, (name) ->
            res.render 'user/detailsGlobal', 
                title: 'Details for ' + req.params.username
                username: name
                targetUsername: req.params.username
                results: results
    

exports.getLogin = getLogin
exports.postLogin = postLogin
exports.getRegister = getRegister
exports.postRegister = postRegister
exports.logout = logout
exports.getDetails = getDetails
exports.getDetailsGlobal = getDetailsGlobal