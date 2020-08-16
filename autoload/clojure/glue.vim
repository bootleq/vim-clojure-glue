let s:events = {}


function! clojure#glue#setup()
  if iced#repl#is_connected()
    call clojure#glue#dispatch('repl-connected')
  else
    call clojure#glue#dispatch('bare-setup')
  end
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
