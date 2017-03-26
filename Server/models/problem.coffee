mongoose = require 'mongoose'

problemSchema = mongoose.Schema
    name: String
    type: String
    author: String
    description: String
    options: [String]
    ans: Number

exports.type = mongoose.model 'problems', problemSchema