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

  let type = ''
  let detects = {
        \   'clojure_cli': 'deps.edn',
        \   'shadow_cljs': 'shadow-cljs.edn'
        \ }

  for [k, v] in items(detects)
    let path = findfile(v, '.;')
    if !empty(path)
      let type = k
      break
    endif
  endfor

  if empty(path)
    let b:clojure_project_type = '' " EFFECT: set project type
    return v:false
  endif

  let b:clojure_project_dir = fnamemodify(path, ':p:h') " EFFECT: set project dir
  let b:clojure_project_type = type                     " EFFECT: set project type
  return v:true
endfunction "}}}

" }}} Interface



" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
