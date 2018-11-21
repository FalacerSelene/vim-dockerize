Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

[unreleased]
------------

### Added
- Added global parameter `g:dockerize_default_image`. If this is set, then the
  0-arg `:Dockerize` command will use the named image instead of prompting the
  user to select one.

### Changed
- Made `vdockerize#ImageSelectionDialogue()` return the name of the selected
  image rather than running it.

[0.1.0] - 2018-09-21
--------------------

### Added
- Initial project creation

[unreleased]: https://www.github.com/FalacerSelene/vim-dockerize
[0.1.0]: https://www.github.com/FalacerSelene/vim-dockerize/tree/0.1.0
