mongoose = require 'mongoose'

resultSchema = mongoose.Schema
    user: String
    contest: String
    id: String
    task: String
    result: Number
    contestName: String
    
exports.type = mongoose.model 'results', resultSchema
