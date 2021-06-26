call clojure#glue#dispatch('filetype')

if ClojureDetect()
  call clojure#glue#dispatch('project')
else
  call clojure#glue#dispatch('no_project')
endif
