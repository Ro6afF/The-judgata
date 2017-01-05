mongoose = require 'mongoose'

sessionSchema = mongoose.Schema
    id: String
    username: String

exports.type = mongoose.model 'sessions', sessionSchema
