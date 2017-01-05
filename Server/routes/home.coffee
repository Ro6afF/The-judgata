modules = 
        user: require('../modules/user')

getIndex = (req, res) ->
    modules.user.getUsername req.cookies.sessionId, (name) ->
        res.render 'index',
            title: 'Home'
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