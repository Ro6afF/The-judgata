modules = 
        user: require('../modules/user')
        db: require('../modules/db')
        
models = 
        quiz: require '../models/quiz' 

getIndex = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {}, (err, quizes) ->
            if quizes
                res.render 'index',
                    title: 'Home'
                    quizes: quizes
                    username: name
        return
    return

getAbout = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        res.render 'about',
            title: 'About'
            username: name
        return
    return

exports.getIndex = getIndex
exports.getAbout = getAbout