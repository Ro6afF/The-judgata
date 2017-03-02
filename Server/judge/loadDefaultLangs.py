#!/usr/bin/python3

import pymongo
from pymongo import MongoClient

db = MongoClient().judgata

db.langs.drop()
db.langs.insert_one({'lang': 'cpp', 'type': 'compiled', 'compile': [ 'g++', '-O2', '-std=c++17', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'lang': 'hs', 'type': 'compiled', 'compile': [ 'ghc', '-O2', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'lang': 'rs', 'type': 'compiled', 'compile': [ 'rustc', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'lang': 'py', 'type': 'script', 'exec': ['/usr/bin/python', '__SOURCE__']})
