Vim Clojure Glue (unstable)
================

I am new to clojure, make glue to help myself.


Currently only works with [vim-iced][] installed.



## Features

- iskeyword: remove `.` and `-`


- `ClojureDetect()`, detect project root and set as variable `b:clojure_project_dir`

  Currently support:

  - shadow-cljs, by finding `shadow-cljs.edn` file


- Some event dispatching, can do register by `call clojure#glue#register()`

  Events:

  - `bare-setup`: after project dir detected, but without repl connected

    useful to setup stuff don't need repl server.

        call clojure#glue#register('bare-setup', function('s:my_bare_setup'))

  - `repl-connected`: during setup, found repl connected



[vim-iced]: https://github.com/liquidz/vim-iced
