#!/usr/bin/python3

import subprocess, os, signal, pymongo, time, multiprocessing, sys, random
from pymongo import MongoClient
from random import randint

db = MongoClient().judgata

max_threads = multiprocessing.cpu_count()

def getCompileCommand(lang):
	return db.langs.find_one({'lang': lang})

def getNumberOfFiles(direc):
	return len(next(os.walk(direc))[2])

def getFreeBox(boxes):
	for i in range(max_threads):
		if boxes[i]:
			boxes[i] = False
			return i
	return -1

def getBoxPlace(Id):
	return '/var/local/lib/isolate/' + str(Id) + '/box/'

def initBox(boxes):
	curr = getFreeBox(boxes)
	subprocess.call(['isolate', '-b', str(curr), '--init'])
	return curr

def deinitBox(Id, boxes):
	subprocess.call(['isolate', '-b', str(Id), '--cleanup'])
	boxes[int(str(Id))] = True

def compileProgram(path, dest, lang):
	print('Compiling program in language ' + lang)
	lango = getCompileCommand(lang)
	print(lango)
	compileArgs = lango['command']
	for i in range(len(compileArgs)):
		if lango['type'] == 'compiled':
			compileArgs[i] = compileArgs[i].replace('__SOURCE__', path)
			compileArgs[i] = compileArgs[i].replace('__RESULT__', dest)
		elif lango['type'] == 'script':
			print('asd')
		elif lango['type'] == 'both':
			print('asdf')
	try:
		proc = subprocess.Popen(compileArgs, preexec_fn = os.setsid)
		if proc.wait(timeout = 10) != 0:
			return 0
		return 2
	except subprocess.TimeoutExpired:
		os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
		return 1

def grade(task, box):
	print('Starting to stest')
	result = 0
	tests = getNumberOfFiles(getBoxPlace(box) + task)
	ppt = 100 / tests
	feedback = []
	for i in range(getNumberOfFiles(getBoxPlace(box) + task)):
		process = subprocess.Popen(['isolate', '-i', task + '/' + str(i) + '.in', '-o', task + '/' + str(i) + '.res', '-b', str(box), '-t', '1', '-m', str(16*10*1024), '--run', 'solution'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		process.wait()
		out, err = process.communicate()
		res = err.decode('utf-8')
		print(res, 'Time limit exceeded')
		if res[:2] == 'OK':
			process = subprocess.Popen(['diff', '-w' , getBoxPlace(box) + task + '/' + str(i) + '.res', getBoxPlace(box) + task + '/sols/' + str(i) + '.sol'], stdout=subprocess.PIPE)
			out, err = process.communicate()
			if out.decode('utf-8') == '':
				feedback += ['OK']
				result += ppt
			else:
				feedback += ['WA']
		elif res.strip() == 'Time limit exceeded':
			feedback += ['TL']
		elif res == 'Caught fatal signal 11':
			feedback += ['SF']
		else:
			feedback += ['RE']
	print(result)
	return (result, feedback)


def judge(Id, code, user, task, lang, contest, contestName, boxes):
	print('Starting to judge task ' + task + ' submited by ' + user)
	path = '/judge/submits/' + user + '/' + task 
	os.makedirs(path, exist_ok=True)
	path += '/' + str(Id) + '.' + lang
	source = open(path, 'w')
	source.write(code)
	source.close()
	currBox = initBox(boxes)
	exe = compileProgram(path, getBoxPlace(currBox) + 'solution',  lang)
	result = 0
	feedback = []
	if exe == 0 :
		print('Compilation error')
		feedback = ['Compilation error']
	elif exe == 1:
		print('Compilation time limit exeeded')
		feedback = ['Compilation time limit exeeded']
	else:
		subprocess.call(['cp', '/judge/tests/' + task, getBoxPlace(currBox), '-rf'])
		result, feedback = grade(task, currBox)
	deinitBox(currBox, boxes)
	print(result, feedback)
	sys.stdout.flush()
	print('Done judge')
	sys.stdout.flush()
	db.results.insert_one({'idT': str(Id), 'result': round(result), 'contest': contest, 'user': user, 'task': task, 'contestName': contestName, 'feedback': feedback, 'lang': lang})

def getTask():
	jobs = []
	boxes = multiprocessing.Array('i', range(max_threads))
	for i in range(max_threads):
		boxes[i] = True
	while True:
		blq = db.tasks.find_one()
		if blq:
			try:
				db.tasks.delete_one(blq)
				job = multiprocessing.Process(target=judge, args=(blq['_id'], blq['code'], blq['user'], blq['task'], blq['lang'], blq['contest'], blq['contestName'], boxes))
				jobs.append(job)
				job.start()
				if len(jobs) >= max_threads:
					jobs[0].join()
					jobs= jobs[1:]
			except:
				time.sleep(randint(1, 10))
		else:
			print('waiting...')
			sys.stdout.flush()
			time.sleep(10)
		time.sleep(1)

getTask()
