mongoose = require 'mongoose'

userSchema = mongoose.Schema
    username: String
    password: String
    passwordsha256: String
    email: String
    avatar: String

exports.type = mongoose.model 'users', userSchema
