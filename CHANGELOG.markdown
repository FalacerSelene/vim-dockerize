Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

[unreleased]
------------

### Added

- Added `DockerizeNew` command, which opens the dockerized terminal in a new
  window rather than the current one.

- Added `dockerize_default_expr` variable, which will be evaluated to get the
  default image if the `dockerize_default_image` is not present.

### Changed

- Now attempts to look up variables in the `g:`, `t:`, `w:` and `b:` scopes in
  that order, rather than only in the `g:` scope.

### Fixed

- Now does not complain when cancelling image selection dialogue with ESC
  instead of selecting an image.

[0.2.0] - 2019-03-02
--------------------

### Added

- Added global parameter `g:dockerize_default_image`. If this is set, then the
  0-arg `:Dockerize` command will use the named image instead of prompting the
  user to select one.

### Changed

- Made `vdockerize#ImageSelectionDialogue()` return the name of the selected
  image rather than running it.

- Changed some load variable names:
  - `g:loaded_vim_dockerize` -> `g:loaded_dockerize`
  - `g:vim_dockerize_version` -> `g:dockerize_version`

### Fixed

- Now yells at you if you try to run without `docker`.

[0.1.0] - 2018-09-21
--------------------

Initial project creation

[unreleased]: https://www.github.com/FalacerSelene/vim-dockerize
[0.2.0]: https://www.github.com/FalacerSelene/vim-dockerize/tree/0.2.0
[0.1.0]: https://www.github.com/FalacerSelene/vim-dockerize/tree/0.1.0
