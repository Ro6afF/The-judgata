$(document).ready ->
    $('#new').click ->
        xhttp = new  XMLHttpRequest()
        xhttp.onreadystatechange = ->
            if @readyState == 4 && @status == 200
                location.reload()
            return
        xhttp.open 'POST', (location.href.replace 'edit', 'newOption'), true
        xhttp.send()
    return
