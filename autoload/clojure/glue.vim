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
