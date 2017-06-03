#!/usr/bin/python3

import pymongo
from pymongo import MongoClient

db = MongoClient().judgata

db.langs.drop()

db.langs.insert_one({'display': 'C/C++', 'lang': 'cpp', 'type': 'compiled', 'compile': [ 'g++', '-O2', '-std=c++17', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'display': 'Haskell', 'lang': 'hs', 'type': 'compiled', 'compile': [ 'ghc', '-O2', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'display': 'Rust', 'lang': 'rs', 'type': 'compiled', 'compile': [ 'rustc', '-o', '__RESULT__', '__SOURCE__' ]})

db.langs.insert_one({'display': 'Python', 'lang': 'py', 'type': 'script', 'exec': ['python', '__SOURCE__']})