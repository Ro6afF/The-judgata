mongoose = require 'mongoose'

problemSchema = mongoose.Schema
    name: String
    admins: [String]
    active: Boolean
    
exports.type = mongoose.model 'problems', problemSchema