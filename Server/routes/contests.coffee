modules = 
    user: require('../modules/user')
    db: require('../modules/db')
        
models = 
    task: require('../models/task')
    problem: require('../models/problem')

lastId = 0
    
getSubmit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if req.params.contest == 'practice'
            modules.db.find models.problem.type, {active: true}, (err, problems) ->
                res.render 'contest/submit',
                    title: 'Submit'
                    username: name
                    problems: problems
        else
            res.render 'error',
                title: '500'
                username: name
                text: 'Internal server error'
        return
    return

postSubmit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.add new (models.task.type)(
            id: lastId++
            code: req.body.code
            user: name
            task: req.body.task
            lang: 'cpp'), (a) ->
                res.redirect('/')
                return
        return
    return

exports.getSubmit = getSubmit
exports.postSubmit = postSubmit