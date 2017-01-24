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

names = 
    cpp: 'C/C++'
    hs: 'Haskell'
    cs: 'C#'
    rs: 'Rust'
    
change = ->
    e = document.getElementById 'lang' 
    value = e.options[e.selectedIndex].value
    text = e.options[e.selectedIndex].text
    console.log value
    editor.setOption 'mode', modes[value]
    CodeMirror.autoLoadMode editor, modes[value]
    return
