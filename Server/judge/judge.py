#!/usr/bin/python3

import subprocess, os, signal, pymongo, time, multiprocessing, sys, random
from pymongo import MongoClient
from random import randint

db = MongoClient().judgata

def getLang(lang):
    return db.langs.find_one({'lang': lang})

def getNumberOfFiles(direc):
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

def grade(task, exe):
    result = 0
    tests = getNumberOfFiles('/judge/tests/' + task)
    ppt = 100 / tests
    feedback = []
    for i in range(tests):
        procc = ''
        for j in exe:
            procc += j + ' '
        procc += '< /tests/' + str(i) + '.in > /tests/' + str(i) + '.out'
        process = subprocess.Popen(['docker', 'run', '-m=10M', '-v', '/judge/tests/' + task + ':/tests', '-v', '/judge/temp:/workdir', '-w', '/workdir', '--network', 'none', '--read-only', 'boza', '/bin/bash', '-c', 'timeout 1 ' + procc])
        process.wait()
        rc = process.returncode
        if rc == 137:
            feedback += ['ML']
        elif rc == 124:
            feedback += ['TL']
        elif rc == 0:
            process = subprocess.Popen(['diff', '/judge/tests/' + task + '/' + str(i) + '.out', '/judge/tests/' + task + '/sols/' + str(i) + '.sol'], stdout=subprocess.PIPE)
            out, err = process.communicate()
            if out.decode('utf-8') == '':
                feedback += ['OK']
                result += ppt
            else:
                feedback += ['WA']
        else:
            feedback += ['RE']
    subprocess.run(['find', '/judge/tests/' + task, '-name',  '*.out', '-delete'])
    return result, feedback

def judge(Id, code, user, task, taskName, lang, contest, contestName):
    path = '/judge/submits/' + user + '/' + task
    os.makedirs(path, exist_ok=True)
    path += '/' + str(Id) + '.' + lang
    source = open(path, 'w')
    source.write(code)
    source.close()
    langDb = getLang(lang)
    runCommand = []
    exe = 123
    result = 0
    feedback = []
    if langDb['type'] == 'compiled':
        runCommand = ['./' + str(Id)]
        exe = compileProgram(path, '/judge/temp/' + str(Id), langDb)
        if exe == 0:
            feedback = ['Compilation error']
        elif exe == 1:
            feedback = ['Compilation time limit']
    else:
        File = open('/judge/temp/' + str(Id), 'w')
        File.write(code)
        File.close()
        for i in langDb['exec']:
            if i == '__SOURCE__':
                runCommand += [str(Id)]
            else:
                runCommand += [i]
    if not (feedback == ['Compilation error'] or feedback == ['Compilation time limit']):
        result, feedback = grade(task, runCommand)
    try:
        os.remove('/judge/temp/' + str(Id))
    except:
        feedback = feedback
    db.results.insert_one({'idT': str(Id), 'result': round(result), 'contest': contest, 'user': user, 'task': task, 'taskName': taskName, 'contestName': contestName, 'feedback': feedback, 'lang': lang})

def getTask():
    while True:
        blq = db.tasks.find_one()
        if blq:
            try:
                db.tasks.delete_one(blq)
                judge(blq['_id'], blq['code'], blq['user'], blq['task'], blq['taskName'], blq['lang'], blq['contest'], blq['contestName'])
            except:
                time.sleep(randint(1, 10))
        else:
            time.sleep(10)
        time.sleep(1)

getTask()
