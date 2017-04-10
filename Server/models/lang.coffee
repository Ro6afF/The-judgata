mongoose = require 'mongoose'

langSchema = mongoose.Schema
    lang: String
    display: String
    
exports.type = mongoose.model 'langs', langSchema