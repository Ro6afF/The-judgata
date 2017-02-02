mongoose = require 'mongoose'

langSchema = mongoose.Schema
    lang: String
    
exports.type = mongoose.model 'langs', langSchema