mongoose = require 'mongoose'

langSchema = mongoose.Schema
    lang: String
    active: Boolean
    
exports.type = mongoose.model 'langs', langSchema