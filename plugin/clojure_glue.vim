if exists('g:loaded_clojure_glue')
  finish
endif
let g:loaded_clojure_glue = 1
let s:save_cpo = &cpoptions
set cpoptions&vim



" Default Options: {{{

" function! s:set_default(name, value)
"   if !exists(a:name)
"     execute 'let ' . a:name . ' = ' . string(a:value)
"   endif
" endfunction

" }}} Default Options



" Interface: {{{

function! ClojureDetect() abort "{{{
  if exists('b:clojure_project_dir')
    return v:true
  endif

  if exists('*' . get(g:, 'clojure_glue_detector'))
    let custom_detected = call(g:clojure_glue_detector, [])
    if type(custom_detected) == v:t_dict
      let b:clojure_project_dir  = custom_detected.dir  " EFFECT: set project dir
      let b:clojure_project_type = custom_detected.type " EFFECT: set project type
      let b:clojure_glue_project_detected = custom_detected.founds  " EFFECT
      return v:true
    endif
  endif

  let ext = expand('%:e')
  let founds = []
  let detects = {
        \   'clojure_cli': 'deps.edn',
        \   'shadow_cljs': 'shadow-cljs.edn'
        \ }

  if ext == 'clj'
    call filter(detects, 'v:key == "clojure_cli"')
  elseif ext == 'cljs'
    call filter(detects, 'v:key == "shadow_cljs"')
  endif

  for [k, v] in items(detects)
    let path = findfile(v, '.;')
    if !empty(path)
      call add(founds, #{type: k, dir: fnamemodify(path, ':p:h')})
    endif
  endfor

  let b:clojure_glue_project_detected = founds  " EFFECT

  if len(founds) > 1
    let b:clojure_project_type = 'defer'  " EFFECT: set project type
    let b:clojure_project_dir = v:null    " EFFECT: set project dir

    return v:true
  elseif len(founds) == 0
    let b:clojure_project_type = '' " EFFECT: set project type
    return v:false
  endif

  let found = founds[0]
  let b:clojure_project_dir = found.dir  " EFFECT: set project dir
  let b:clojure_project_type = found.type " EFFECT: set project type
  return v:true
endfunction "}}}

" }}} Interface



" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
