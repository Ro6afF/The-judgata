mongoose = require 'mongoose'

taskSchema = mongoose.Schema
    code: String
    user: String
    task: String
    taskName: String
    lang: String
    contest: String
    contestName: String
    
exports.type = mongoose.model 'tasks', taskSchema
