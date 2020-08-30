Vim Clojure Glue (unstable)
================

I am new to clojure, make glue to help myself.

Currently mainly tested with [vim-iced][] installed.



## Features

- iskeyword: remove `.` and `-`


- `ClojureDetect()`, detect project root and set as variable `b:clojure_project_dir`

  Currently support:

  - shadow-cljs, by finding `shadow-cljs.edn` file


- Wrapper functions wait-to-be-defined, an layer to make script work with different plugins (e.g., [vim-iced][] or [conjure][]).

  For example `clojure#glue#def('connected?')` can define an `connected?` function, delegate to vim-iced's `iced#nrepl#is_connected()`,  
  then our script will call it with `clojure#glue#call('connected?')`,  
  or call it only when defined with `clojure#glue#try('connected?')`.

  Functions:

  - `connected?`: tell if repl has been connected.

    vim-iced example:

        call clojure#glue#def('connected?', 'iced#repl#is_connected')


- Some event dispatching, can do register by `call clojure#glue#register()`

  Events:

  - `bare-setup`: after project dir detected, but without repl connected

    useful to setup stuff don't need repl server.

        call clojure#glue#register('bare-setup', function('s:my_bare_setup'))

  - `repl-connected`: during setup, found repl connected


- `gf` helper function: `clojure#glue#gf#includeexpr()`

  Currently only support static (no server involved) file finding in project `src` directory.

  Example config:

    function! s:glue_bare_setup()
      execute 'setlocal path+=' . b:clojure_project_dir . '/src'
      setlocal suffixesadd=.clj,.cljs
      setlocal includeexpr=clojure#glue#gf#includeexpr()
    endfunction

    call clojure#glue#register('bare-setup', function('s:glue_bare_setup'))



[vim-iced]: https://github.com/liquidz/vim-iced
[conjure]: https://github.com/Olical/conjure
