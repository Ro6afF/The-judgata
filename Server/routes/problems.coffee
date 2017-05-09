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
            type: req.body.type
            author: name
        )), (err, b) ->
            res.redirect '/problem/edit/' + b.id
            return
        return
    return

getEdit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.problem.type, {_id: req.params.id, author: name}, (err, problems) ->
            if problems
                for p in problems
                    res.render 'problem/edit', 
                        title: 'Edit problem ' + p.name,
                        username: name,
                        problem: p
                    return
            res.render 'error', 
                title: 'Not perimted',
                username: name,
                text: 'You are not permited to edit this problem!'
            return
        return
    return

postNewOption = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.problem.type, {_id: req.params.id, author: name}, (err, problems) ->
            if problems
                for p in problems
                    opts = []
                    for i in p.options
                        opts.push i
                    opts.push ''
                    modules.db.update models.problem.type, p, {options: opts}, (err, raw) ->
                        if err
                            res.status 500
                        else if raw.ok != 1
                            res.status 401
                        else
                            res.status 200
                        res.send ''
            else
                res.status 401
                res.send ''

postEdit = (req, res) ->
    opts = []
    for k,v of req.body
        opts[parseInt k] = v
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.problem.type, {_id: req.params.id, author: name}, (err, problem) ->
            if problem[0].type == 'test'
                modules.db.update models.problem.type, problem[0], {options: opts, description: req.body.description, ans: parseInt req.body.ans}, (err, raw) ->
                    if err
                        res.render 'error', 
                            title: '500',
                            username: name,
                            text: 'Internal server error'
                    else if raw.ok != 1
                        res.render 'error', 
                            title: 'Not perimted',
                            username: name,
                            text: 'You are not permited to edit this problem!'
                    else
                        res.redirect '/'
            else
                modules.db.update models.problem.type, problem[0], {description: req.body.description}, (err, raw) ->
                    if err
                        res.render 'error', 
                            title: '500',
                            username: name,
                            text: 'Internal server error'
                    else if raw.ok != 1
                        res.render 'error', 
                            title: 'Not perimted',
                            username: name,
                            text: 'You are not permited to edit this problem!'
                    else
                        res.redirect '/'
                
exports.getCreate = getCreate
exports.postCreate = postCreate
exports.getEdit = getEdit
exports.postEdit = postEdit
exports.postNewOption = postNewOption