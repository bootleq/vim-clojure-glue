Vim Clojure Glue (unstable)
================

I am new to clojure, make glue to help myself.

Currently mainly tested with [vim-iced][] installed.



## Status

Unstable.


## Recipes

- Change `'iskeyword'` for clojure files.

  Do setup in `filetype` event:

      function! s:glue_filetype()
        for kw in ['.', '/', ':']
          execute printf('setlocal iskeyword-=%s', kw)
        endfor
      endfunction

      call clojure#glue#register('filetype', function('s:glue_filetype'))


## Features

- `ClojureDetect()`, detect project root and set as variable `b:clojure_project_dir`

  Currently support:

  - clojure cli project, by finding `deps.edn` file
  - shadow-cljs, by finding `shadow-cljs.edn` file

  This also set `b:clojure_project_type` to `'clojure_cli'`, `'shadow_cljs'`, or `''` if detected no project.

  Currently this is done without opt-out option, see `after/ftplugin/clojure/clojure_glue.vim`.


- Some wrapper functions wait-to-be-defined, an layer to make script work with different plugins (e.g., [vim-iced][] or [conjure][]).

  For example `clojure#glue#def('connected?')` can define an `connected?` function, delegate to vim-iced's `iced#nrepl#is_connected()`,  
  then our script can call it with `clojure#glue#call('connected?')`,  
  or call it only when defined with `clojure#glue#try('connected?')`.

  Functions:

  - `connected?`: tell if repl has been connected.

    vim-iced example:

        call clojure#glue#def('connected?', 'iced#repl#is_connected')


- Some event dispatching, can do register by `call clojure#glue#register()`

  Events:

  - `filetype`: after filetype "clojure" applied (this use Vim's `*after-directory*` so can overwrite built-in filetype setting).


  - `project`: after project dir detected.


  - `no_project`: after above detection, but no project found. For example when read source code in .m2/repository zipfile.


  - `first_connected`: after first time repl connected.

    vim-iced example:

        function! s:glue_project()
          " set some key mappings
        endfunction
        call iced#hook#add('connected', {
              \   'type': 'command',
              \   'exec': 'call clojure#glue#dispatch("first_connected")'})
        call clojure#glue#register('first_connected', function('s:glue_project'))


- `gf` helper function: `clojure#glue#gf#includeexpr()`

  Basic usage, only support static (no server involved) file finding in project `src` directory.

  Example config:

      function! s:glue_project_detected()
        if clojure#glue#try('connected?')
          execute 'setlocal path+=' . b:clojure_project_dir . '/src'
          setlocal suffixesadd+=.clj,.cljs
          setlocal includeexpr=clojure#glue#gf#includeexpr()
        else
          " do something requires repl connected
        endif
      endfunction

      call clojure#glue#register('project', function('s:glue_project_detected'))

  There is a helper function `clojure#glue#iced#gf()` to rebind `gf` to
  vim-iced's `IcedDefJump`, and fallback to normal `gf` if no tag to jump, example:

      " add below to 'project' event
      nmap <buffer> <silent> gf :call clojure#glue#iced#gf()<CR>


[vim-iced]: https://github.com/liquidz/vim-iced
[conjure]: https://github.com/Olical/conjure
