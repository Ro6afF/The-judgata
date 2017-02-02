mongoose = require 'mongoose'

problemSchema = mongoose.Schema
    name: String
    admins: [String]
    
exports.type = mongoose.model 'problems', problemSchema