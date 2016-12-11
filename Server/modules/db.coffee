mongoose = require 'mongoose'

add = (a, cb) ->
    a.save (err, b) ->
        if err
            console.error err
        else
            cb b
        return
    return

find = (a, b, cb) ->
    a.find b, cb
    return

remove = (a, b, cb) ->
    a.remove b, cb
    return

mongoose.connect 'mongodb://localhost/The-judgata'

exports.add = add
exports.find = find
exports.remove = remove