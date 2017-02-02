modules = 
        db: require('../modules/db')
        user: require('../modules/user')
    
models =
        problem: require('../models/problem')

    
getCreate = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        res.render 'problem/create',
            title: 'Create new problem'
            username: name
        return
    return

postCreate = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.add (new models.problem.type (
            name: req.body.name
            admins: [name]
        )), (err, b) ->
            res.redirect '/problem/edit/' + b.id
            return
        return
    return

exports.getCreate = getCreate
exports.postCreate = postCreate