CodeMirror.modeURL = '/codemirror/mode/%N/%N.js'

editor = CodeMirror.fromTextArea(document.getElementById('code'),
    mode: 'text/x-c++src'
    lineNumbers: true
    lineWrapping: true)

modes = 
    cpp: 'text/x-c++src'
    hs: 'text/x-haskell'
    cs: 'text/x-csharp'
    rs: 'text/x-rustsrc'
    py: 'text/x-python'
    
changeLang = ->
    value = $('#lang').find(':selected').val()
    editor.setOption 'mode', modes[value]
    CodeMirror.autoLoadMode editor, modes[value]
    return

changeTask = ->
    name = $('#task').find(':selected').text()
    curr = location.href

    if curr.indexOf('#') != -1
        curr = curr.slice 0, curr.indexOf('#')
    if curr.indexOf('?') != -1
        curr = curr.slice 0, curr.indexOf('?')

    if name == 'Select one'
        $('#description-button').html('<a href="#" disabled="disabled" class="btn btn-raised btn-success">Select task</a>')
    else
        $('#description-button').html('<a class="btn btn-raised btn-success" href="' + curr + '/description/' + $('#task').find(':selected').val() + '" target="_blank"> Get description for task: ' + name + '</a>')
    return

window.onload = ->
    changeTask()
    changeLang()
    return
