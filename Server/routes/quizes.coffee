modules = 
        db: require('../modules/db')
        user: require('../modules/user')
    
models =
        quiz: require('../models/quiz')

getCreate = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        res.render 'quiz/create',
            title: 'Create new quiz'
            username: name
        return
    return

postCreate = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.add (new models.quiz.type (
            id: 1
            name: req.body.name
            author: name
        )), (b) ->
            res.redirect '/quiz/edit/' + b.id
            return
        return
    return

getEdit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {id: req.params.id}, (err, quizes) ->
            if quizes || quizes.length
                for q in quizes
                    if q.author == name
                        res.render 'quiz/edit', 
                            title: 'Edit quiz ' + q.name,
                            username: name,
                            quiz: q
                        return
            res.render 'error', 
                title: 'Not perimted',
                username: name,
                text: 'You are not permited to edit this quiz!'
            return
        return
    return

exports.getCreate = getCreate
exports.postCreate = postCreate
exports.getEdit = getEdit