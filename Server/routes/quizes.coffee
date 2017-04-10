modules = 
        db: require '../modules/db'
        user: require '../modules/user'
    
models =
        quiz: require '../models/quiz' 
        problem: require '../models/problem'
        task: require '../models/task'
        result: require '../models/result'
        problem: require '../models/problem'
        lang: require '../models/lang'
        test: require '../models/test'
    
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
                    modules.db.find models.problem.type, {}, (err, problems) ->
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
        modules.db.update models.quiz.type, {_id: req.params.id, author: name}, {problems: tasks, start: (new Date(req.body.start)).toISOString(), end: (new Date(req.body.end)).toISOString()}, (err, raw) ->
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
                    modules.db.update models.quiz.type, q, {problems: tasks}, (err, raw) ->
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
        if name
            modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
                    if quizes && quizes.length
                        for q in quizes
                            modules.db.find models.problem.type, {type: 'code'}, (err, problems) ->
                                start = new Date q.start
                                now = new Date Date.now()
                                end = new Date q.end
                                if now > start && now < end
                                    modules.db.find models.lang.type, {}, (err, langs) ->
                                        modules.db.find models.result.type, {user: name, contest: req.params.id}, (err, submits) ->
                                            res.render 'quiz/submit', 
                                                title: 'Submiting in ' + q.name
                                                username: name
                                                langs: langs
                                                quiz: q
                                                submits: submits
                                                problems: problems
                                else
                                    res.render 'error', 
                                        title: 'Not perimted',
                                        username: name,
                                        text: 'Contest is not running'
        else
            res.render 'error', 
                    title: 'Not perimted',
                    username: name,
                    text: 'Login to submit in quiz!'

getTest = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if name
            modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
                if quizes && quizes.length
                    for q in quizes
                        start = new Date q.start
                        now = new Date Date.now()
                        end = new Date q.end
                        if now > start && now < end
                            modules.db.find models.problem.type, {type: 'test'}, (err, problems) ->
                                modules.db.find models.test.type, {user: name, quiz: req.params.id}, (err, tests) ->
                                    res.render 'quiz/test', 
                                        title: 'Submiting in ' + q.name
                                        username: name
                                        quiz: q
                                        problems: problems
                                        answers: tests
                        else
                            res.render 'error', 
                                title: 'Not perimted',
                                username: name,
                                text: 'Contest is not running'
        else
            res.render 'error', 
                    title: 'Not perimted',
                    username: name,
                    text: 'Login to test in quiz!'
                    
getSubmitDetails = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.result.type, {user: name, idT: req.params.id}, (err, source) ->
            if source && source.length
                for s in source
                    res.render 'quiz/submitDetails', 
                        title: 'Solution ' + req.params.id + ' for problem ' + s.task,
                        username: name,
                        result: s
            else
                res.render 'error', 
                    title: 'Not perimted',
                    username: name,
                    text: 'Not your submit!'
                    
downloadSource = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.result.type, {user: name, idT: req.params.id}, (err, source) ->
            if source && source.length
                for s in source
                    res.download '/judge/submits/' + name + '/' + s.task + '/' + req.params.id + '.' + s.lang
            else
                res.render 'error', 
                    title: 'Not perimted',
                    username: name,
                    text: 'This is not your source!'
                    
postSubmit = (req, res) ->
    console.log req.body
    modules.user.getUsername req.cookies.sessionId, (name) ->
        modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
            modules.db.add new (models.task.type)(
                code: req.body.code
                user: name
                task: req.body.task
                lang: req.body.lang
                contest: req.params.id
                contestName: quizes[0].name), (a) ->
                    if quizes && quizes.length
                        for q in quizes
                            res.redirect '/quiz/submit/' + req.params.id
                return
        return
    return        
        
getResults = (req, res) ->
    modules.db.find models.result.type, {contest: req.params.id}, (err, submits) ->
        modules.db.find models.test.type, {quiz: req.params.id}, (err, tests) ->
            resultsTask = {}
            for i in submits
                if !resultsTask[i.task]
                    resultsTask[i.task] = {}
                if (!resultsTask[i.task][i.user]) || (resultsTask[i.task][i.user] < i.result)
                    resultsTask[i.task][i.user] = i.result
            for i in tests
                if !resultsTask[i.task]
                    resultsTask[i.task] = {}
                if i.correct
                    resultsTask[i.task][i.user] = 100
                else
                    resultsTask[i.task][i.user] = 0
            resultsUser = {}
            for k, v of resultsTask
                for j, c of v
                    if !resultsUser[j]
                        resultsUser[j] = 0
                    resultsUser[j] += c
            if req.headers['user-agent'] == 'API'
                res.json resultsUser
            else
                results = []
                for k, v of resultsUser
                    results.push {name: k, points: v}
                results.sort (x, y) ->
                    y.points - x.points
                modules.db.find models.quiz.type, {_id: req.params.id}, (err, quizes) ->
                    if quizes && quizes.length
                        for q in quizes
                            modules.user.getUsername req.cookies.sessionId, (name) ->
                                res.render 'quiz/results',
                                    title: 'Results for ' + q.name
                                    username: name
                                    results: results
                                
postTest = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        if name
            modules.db.find models.problem.type, {_id: req.params.tid, type: 'test'}, (err, problems) ->
                if problems && problems.length
                    modules.db.remove models.test.type, {quiz: req.params.qid, problem: req.params.tid, user: name}, () ->
                    modules.db.add (new models.test.type {quiz: req.params.qid, problem: req.params.tid, user: name, answer: req.body.ans, correct: parseInt(req.body.ans) == problems[0].ans, task: problems[0].name}), () ->
                    res.redirect '/quiz/test/' + req.params.qid
        else
            res.render 'error', 
                title: 'Not perimted',
                username: name,
                text: 'Login to test in quiz!'


exports.getCreate = getCreate
exports.postCreate = postCreate
exports.getEdit = getEdit
exports.postEdit = postEdit
exports.postNewProblem = postNewProblem
exports.getSubmit = getSubmit
exports.postSubmit = postSubmit
exports.getResults = getResults
exports.downloadSource = downloadSource
exports.getSubmitDetails = getSubmitDetails
exports.getTest = getTest
exports.postTest = postTest