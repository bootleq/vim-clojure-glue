setlocal iskeyword-=.
setlocal iskeyword-=/

if ClojureDetect()
  call clojure#glue#setup()
endif
