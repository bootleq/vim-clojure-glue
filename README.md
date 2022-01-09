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


- Custom project detector, assume we have `~/parent/x-clj`, `~/parent/x-cljs`
  with **single** `~/parent/.shadow-cljs/nrepl.port` to serve a clj + cljs REPLs.

  ```vim
  function! s:glue_custom_detector() abort
    let dir = fnamemodify(expand('%'), ':~')
    let found = v:null

    if dir =~ '.\+/parent'
      let root    = finddir('parent', ';') ->fnamemodify(':~')
      let sub_dir = dir ->strpart(len(root)) ->split('/') ->{x -> len(x) ? x[0] : ''}()

      " root port: mixed clj + cljs repl
      let port_file = expand(root) . '/.shadow-cljs/nrepl.port'
      if filereadable(port_file)
        let port = readfile(port_file)[0]
        let b:clojure_mixed_nrepl_port_file = port_file " your might want to record this, to be used for connection later
        let found = #{
              \   dir: sub_dir,
              \   type: sub_dir == 'x-cljs' ? 'shadow_cljs' : 'clojure_cli',
              \   founds: []
              \ }
      endif

      return found
    endif
  endfunction
  let g:clojure_glue_detector = matchstr(expand('<sfile>'), '<SNR>\d\+_') . 'glue_custom_detector'
  ```


## Features

- `ClojureDetect()`, detect project root and set as variable `b:clojure_project_dir`

  Currently support:

  - clojure cli project, by finding `deps.edn` file
  - shadow-cljs, by finding `shadow-cljs.edn` file
  - when both found, pick the type matches current file extension (clj or cljs), if neither (i.e., cljc), currently it goes to an *uncertain* state, `b:clojure_project_dir` is not set.
  - If above behavior still not suitable, set `g:clojure_glue_detector` to do customized detection (detailed later).

  This also set `b:clojure_project_type` to `'clojure_cli'`, `'shadow_cljs'`, or `''` if detected no project, `'defer'` if both found.

  Currently this is done without opt-out option, see `after/ftplugin/clojure/clojure_glue.vim`.

  Once tried detection, found info is saved to `clojure_glue_project_detected` as an List of Dictionary with `type` and `dir` keys.

  `g:clojure_glue_detector`: can be set to a function returns Dictionary with `dir` `type` and `founds` keys, each will be taken to
  `b:clojure_project_dir`, `b:clojure_project_type` and `b:clojure_glue_project_detected`, or returns `null` to fallback to default detector.

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


  - `first_connected`: after first time repl connected. (have to implement "connected" on your own currently)

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
        if !clojure#glue#try('connected?')
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


- Prompt for choosing one of detected project_types, `clojure#glue#select_project_type()`

  When `ClojureDetect()` finds multiple candidates, `b:clojure_project_type` is set to `'defer'`.

  You can call `clojure#glue#select_project_type()` to show an confirm dialog,
  select a wanted type and that will be set to `b:clojure_project_dir` and `_type`.



[vim-iced]: https://github.com/liquidz/vim-iced
[conjure]: https://github.com/Olical/conjure
