modules = 
        db: require '../modules/db'
        user: require '../modules/user'
    
models =
        quiz: require '../models/quiz' 
        problem: require '../models/problem'
        task: require '../models/task'
        result: require '../models/result'
    
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
            name: req.body.name
            author: name
        )), (err, b) ->
            res.redirect '/quiz/edit/' + b.id
            return
        return
    return

getEdit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {_id: req.params.id, author: name}, (err, quizes) ->
            if quizes
                for q in quizes
                    modules.db.find models.problem.type, {active: true}, (err, problems) ->
                        res.render 'quiz/edit', 
                            title: 'Edit quiz ' + q.name,
                            username: name,
                            quiz: q
                            problems: problems
                        return
                    return
            res.render 'error', 
                title: 'Not perimted',
                username: name,
                text: 'You are not permited to edit this quiz!'
            return
        return
    return

postEdit = (req, res) ->
    tasks = []
    for k,v of req.body
        tasks[parseInt k] = v
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.update models.quiz.type, {_id: req.params.id, author: name}, {problems: tasks}, undefined, (err, raw) ->
            if err
                console.log err
                res.render 'error', 
                    title: '500',
                    username: name,
                    text: 'Internal server error'
            else if raw.ok != 1
                res.render 'error', 
                    title: 'Not perimted',
                    username: name,
                    text: 'You are not permited to edit this quiz!'
            else
                res.redirect '/'
    return

postNewProblem = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {_id: req.params.id, author: name}, (err, quizes) ->
            if quizes && quizes.length
                for q in quizes
                    tasks = []
                    for i in q.problems
                        tasks.push i
                    tasks.push ''
                    modules.db.update models.quiz.type, q, {problems: tasks}, undefined, (err, raw) ->
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

getSubmit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
            if quizes && quizes.length
                for q in quizes
                    res.render 'quiz/submit', 
                        title: 'Submiting in ' + q.name
                        username: name
                        quiz: q

postSubmit = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
            modules.db.add new (models.task.type)(
                code: req.body.code
                user: name
                task: req.body.task
                lang: 'cpp'
                contest: req.params.id
                contestName: quizes[0].name), (a) ->
                    if quizes && quizes.length
                        for q in quizes
                            res.render 'quiz/submit', 
                                title: 'Submiting in ' + q.name
                                username: name
                                quiz: q
                return
        return
    return        
        
getResults = (req, res) ->
    modules.db.find models.result.type, {contest: req.params.id}, (err, submits) ->
        resultsTask = {}
        for i in submits
            if !resultsTask[i.task]
                resultsTask[i.task] = {}
            if (!resultsTask[i.task][i.user]) || (resultsTask[i.task][i.user] < i.result)
                resultsTask[i.task][i.user] = i.result
        resultsUser = {}
        for k, v of resultsTask
            for j, c of v
                if !resultsUser[j]
                    resultsUser[j] = 0
                resultsUser[j] += c
        console.log resultsUser
        if req.headers['user-agent'] == 'API'
            res.json resultsUser
        else
            modules.user.getUsername req.cookies.sessionId, (name) ->
                res.render 'quiz/results', 
                    title: 'Results for ' + 'shte go dobave po-kusno'
                    username: name
                    results: resultsUser
              
exports.getCreate = getCreate
exports.postCreate = postCreate
exports.getEdit = getEdit
exports.postEdit = postEdit
exports.postNewProblem = postNewProblem
exports.getSubmit = getSubmit
exports.postSubmit = postSubmit
exports.getResults = getResults