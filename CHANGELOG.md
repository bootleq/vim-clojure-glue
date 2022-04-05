CHANGELOG
=========

## 0.2.0 (2022-04-05)

* Change the detection of project type.

  When both `deps.edn` and `shadow-cljs.edn` were found,
  set `b:clojure_project_type` to `defer`, leave `b:clojure_project_dir` not set,
  and saves found info to `clojure_glue_project_detected` variable.

  Also a `clojure#glue#select_project_type()` UI is added to choose project type.

* Add `clojure_glue_detector` option to customize project dir/type detector,
  use this when all default assumptions are not helpful.


## 0.1.0 (2021-07-19)

* First release.
