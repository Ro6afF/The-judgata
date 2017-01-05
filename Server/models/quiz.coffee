mongoose = require 'mongoose'

quizSchema = mongoose.Schema
    name: String
    author: String
    problems: [String]

exports.type = mongoose.model 'quizes', quizSchema
