call clojure#glue#dispatch('filetype')


if !exists('b:clojure_glue_project_detected')
  if ClojureDetect()
    call clojure#glue#dispatch('project')
  else
    call clojure#glue#dispatch('no_project')
  endif
endif
