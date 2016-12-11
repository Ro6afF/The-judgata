mongoose = require 'mongoose'

quizSchema = mongoose.Schema
    id: Number
    name: String
    author: String

exports.type = mongoose.model 'Quizes', quizSchema
