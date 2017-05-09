mongoose = require 'mongoose'

resultSchema = mongoose.Schema
    user: String
    contest: String
    idT: String
    lang: String
    task: String
    taskName: String
    result: Number
    contestName: String
    feedback: []
    
exports.type = mongoose.model 'results', resultSchema
