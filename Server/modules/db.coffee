mongoose = require 'mongoose'

add = (a, cb) ->
    a.save cb
    return

find = (a, b, cb) ->
    a.find b, cb
    return

remove = (a, b, cb) ->
    a.remove b, cb
    return

update = (a, b, c, opts, cb) ->
    a.update b, c, cb
    return

mongoose.connect 'mongodb://localhost/judgata'

exports.add = add
exports.find = find
exports.remove = remove
exports.update = update
