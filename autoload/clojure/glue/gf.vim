function! clojure#glue#gf#includeexpr()
  let path = substitute(v:fname, '\.', '/', 'g') " foo.bar -> foo/bar

  if !isdirectory(b:clojure_project_dir . '/src/' . split(path, '/')[0])
    let path = s:expand_alias(path)
  endif

  let transforms = [
        \   {s -> s->substitute('-', '_', 'g')},
        \ ]

  for [key, value] in items(get(b:, 'clojure_glue_extra_deps', {}))
    if substitute(key, '\.', '/', 'g') == path
      let dir = b:clojure_project_dir . '/' . value . '/src/'
      if isdirectory(dir)
        for s:tx in transforms
          for s:suffix in split(&suffixesadd, ',')
            let new_path = dir . s:tx(path) . s:suffix
            if filereadable(new_path)
              return new_path
            endif
          endfo
        endfor
      end
    endif
  endfor

  for s:tx in transforms
    for s:suffix in split(&suffixesadd, ',')
      let new_path = b:clojure_project_dir . '/src/' . s:tx(path) . s:suffix
      if filereadable(new_path)
        return new_path
      endif
    endfo
  endfor

  return v:fname
endfunction



function! clojure#glue#gf#get_ns_require_lines()
  try
    let save_cursor = getcurpos()
    call cursor(1, 1)

    let begin_line = search('(ns .*\n.\+(:require\zs')
    let end_line   = begin_line > 0 ? search(')$\n$', 'n') : 0
    let lines = getline(begin_line, end_line)
    return lines
  finally
    call setpos('.', save_cursor)
  endtry
endfunction



function! s:expand_alias(path)
  " :require
  "   [a.b.c :as foo]
  "
  " Expand 'foo' to 'a/b/c'
  " To allow [foo/bar] to find a/b/c/foo/bar
  "
  " TODO: support the 'bar' part
  let require_forms = clojure#glue#gf#get_ns_require_lines()

  if empty(require_forms)
    return a:path
  endif

  let alias = split(a:path, '/')[0]
  let idx = match(require_forms, ' :as *' . alias . ']')

  if idx < 0
    return a:path
  endif

  let line = require_forms[idx]
  let expanded = line->matchstr('\v(\w|\.|-)+')->tr('.', '/')

  return expanded
endfunction
