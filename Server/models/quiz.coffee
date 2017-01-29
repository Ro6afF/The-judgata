mongoose = require 'mongoose'

quizSchema = mongoose.Schema
    name: String
    author: String
    start: String
    end: String
    problems: [String]

exports.type = mongoose.model 'quizes', quizSchema
