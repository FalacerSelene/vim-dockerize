"|===========================================================================|
"|                                                                           |
"|         FILE:  plugin/vdockerize.vim                                      |
"|                                                                           |
"|  DESCRIPTION:  Main entrance for vdockerize.                              |
"|                                                                           |
"|       AUTHOR:  @FalacerSelene                                             |
"|      CONTACT:  < git at falacer-selene dot net >                          |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  0.1.0 <alpha>                                              |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                                  SETUP                                    |
"|===========================================================================|
scriptencoding utf-8

if &compatible || exists('g:loaded_vim_dockerize')
	finish
elseif v:version < 800
	echoerr 'Vim-Dockerize requires vim 8.0 or later!'
elseif !(has('terminal') && has('lambda'))
	echoerr 'Vim-Dockerize must be compiled with "terminal" and "lambda"'
endif

let g:loaded_vim_dockerize = 1
let g:vim_dockerize_version = '0.1.0'
lockvar g:vim_dockerize_version

"|===========================================================================|
"|                             USER INTERFACE                                |
"|===========================================================================|

command -nargs=? -bang Dockerize call <SID>DockerizeCommand(<q-args>)

"|===========================================================================|
"|                            SCRIPT FUNCTIONS                               |
"|===========================================================================|

function s:DockerizeCommand(image)
	let l:image = empty(a:image) ? vdockerize#ImageSelectionDialogue() : a:image
	call vdockerize#DockerTerminal(l:image, 1)
endfunction