let s:implements = {}
let s:events = {}


" #def(func)              => test if implements[func] exist
" #def(func, implement)   => set implements[func] to arg 2
function! clojure#glue#def(...)
  if a:0 == 1
    return has_key(s:implements, a:1)
  elseif a:0 == 2
    let s:implements[a:1] = a:2
  endif
endfunction


function! clojure#glue#call(func, ...)
  let s:handler = get(s:implements, a:func)
  let type = type(s:handler)

  if type == v:t_func || type == v:t_string
    return call(s:handler, a:000)
  else
    echohl WarningMsg | echoerr 'No implementation set for ' . a:func | echohl None
  endif
endfunction


function! clojure#glue#try(func, ...)
  if clojure#glue#def(a:func)
    return call(function('clojure#glue#call'), [a:func] + a:000)
  endif
endfunction


function! clojure#glue#register(event, handler)
  let s:events[a:event] = a:handler
endfunction


function! clojure#glue#dispatch(event, ...)
  let s:handler = get(s:events, a:event)
  if type(s:handler) == v:t_func
    call call(s:handler, a:000)
  else
    echohl WarningMsg | echoerr 'No event handler for ' . a:event | echohl None
  endif
endfunction


function! clojure#glue#select_project_type() "{{{
  if !exists('b:clojure_glue_project_detected')
    echohl WarningMsg | echoerr 'b:clojure_glue_project_detected not exists.' | echohl None
  endif

  let items = b:clojure_glue_project_detected

  let index = 0
  let candidates = []
  let captions = []
  for item in items
    let caption = nr2char(char2nr('a') + index)
    call add(candidates, printf(' %s) %s (%s)', caption, item.type, item.dir))
    call add(captions, '&' . caption)
    let index += 1
  endfor

  let choice = confirm("Select REPL type:\n" . join(candidates, "\n"), join(captions, "\n"), 0)
  if choice
    let found = items[choice - 1]
    let b:clojure_project_dir = found.dir
    let b:clojure_project_type = found.type
    return v:true
  endif

  return v:null
endfunction "}}}
