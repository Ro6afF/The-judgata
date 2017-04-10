mongoose = require 'mongoose'

testSchema = mongoose.Schema
    user: String
    answer: Number
    problem: String
    task: String
    quiz: String
    correct: Boolean
    
exports.type = mongoose.model 'tests', testSchema
