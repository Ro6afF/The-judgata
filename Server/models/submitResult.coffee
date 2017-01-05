mongoose = require 'mongoose'

submitSchema = mongoose.Schema
    id: Number
    result: Number

exports.type = mongoose.model 'results', submitSchema
