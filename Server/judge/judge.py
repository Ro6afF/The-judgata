#!/usr/bin/python3

import subprocess, os, signal, pymongo, time, multiprocessing, sys, random
from pymongo import MongoClient
from random import randint

db = MongoClient().judgata

max_threads = multiprocessing.cpu_count()

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

def getLang(lang):
    return db.langs.find_one({'lang': lang})

def getNumberOfFiles(direc):
    sys.stderr.flush()
    return len(next(os.walk(direc))[2])

def compileProgram(path, dest, lang):
    compileArgs = lang['compile']
    for i in range(len(compileArgs)):
        compileArgs[i] = compileArgs[i].replace('__SOURCE__', path)
        compileArgs[i] = compileArgs[i].replace('__RESULT__', dest)
    try:
        proc = subprocess.Popen(compileArgs, preexec_fn = os.setsid)
        if proc.wait(timeout = 10) != 0:
            return 0
        return 2
    except subprocess.TimeoutExpired:
        os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        return 1

def grade(task, box, exe):
    result = 0
    tests = getNumberOfFiles(getBoxPlace(box) + task)
    ppt = 100 / tests
    feedback = []
    for i in range(tests):
        process = subprocess.Popen(['isolate', '-i', task + '/' + str(i) + '.in', '-o', task + '/' + str(i) + '.res', '-b', str(box), '-t', '1', '-m', str(16*10*1024), '--run'] + exe, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        process.wait()
        out, err = process.communicate()
        print(out)
        print(err)
        res = err.decode('utf-8')
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
    return (result, feedback)

def judge(Id, code, user, task, lang, contest, contestName, boxes):
    path = '/judge/submits/' + user + '/' + task
    os.makedirs(path, exist_ok=True)
    path += '/' + str(Id) + '.' + lang
    source = open(path, 'w')
    source.write(code)
    source.close()
    currBox = initBox(boxes)
    langDb = getLang(lang)
    runCommand = []
    exe = 123
    result = 0
    feedback = []
    if langDb['type'] == 'compiled':
        runCommand = ['solution']
        exe = compileProgram(path, getBoxPlace(currBox) + 'solution', langDb)
        if exe == 0:
            feedback = ['Compilation error']
        elif exe == 1:
            feedback = ['Compilation time limit']
    else:
        File = open(getBoxPlace(currBox) + 'solution', 'w')
        File.write(code)
        File.close()
        for i in langDb['exec']:
            if i == '__SOURCE__':
                runCommand += ['solution']
            else:
                runCommand += [i]
    print(runCommand)
    subprocess.call(['cp', '/judge/tests/' + task, getBoxPlace(currBox), '-rf'])
    if not (feedback == ['Compilation error'] or feedback == ['Compilation time limit']):
        result, feedback = grade(task, currBox, runCommand)
    db.results.insert_one({'idT': str(Id), 'result': round(result), 'contest': contest, 'user': user, 'task': task, 'contestName': contestName, 'feedback': feedback, 'lang': lang})
    deinitBox(currBox, boxes)

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
            sys.stdout.flush()
            time.sleep(10)
        time.sleep(1)

getTask()
