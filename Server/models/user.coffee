mongoose = require 'mongoose'

userSchema = mongoose.Schema
    username: String
    password: String
    passwordsha1: String
    email: String
    avatar: String

exports.type = mongoose.model 'Users', userSchema
