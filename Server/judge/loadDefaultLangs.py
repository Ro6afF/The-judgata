#!/usr/bin/python3

import pymongo
from pymongo import MongoClient

db = MongoClient().judgata

db.langs.drop()
db.langs.insert_one({'lang': 'cpp', 'type': 'compiled', 'command': [ 'clang++', '-O2', '-std=c++14', '-o', '__RESULT__', '__SOURCE__' ], 'active': True})
db.langs.insert_one({'lang': 'hs', 'type': 'compiled', 'command': [ 'ghc', '-O2', '-o', '__RESULT__', '__SOURCE__' ], 'active': True})
db.langs.insert_one({'lang': 'rs', 'type': 'compiled', 'command': [ 'rustc', '-o', '__RESULT__', '__SOURCE__' ], 'active': True})
#db.langs.insert_one({'lang': 'cs', 'type': 'compiled', 'command': [ 'mcs', '-out:__RESULT__', '__SOURCE__' ], 'active': True})
