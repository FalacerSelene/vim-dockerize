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

command -nargs=? -bang Dockerize
	\ if empty(<q-args>) | call mydkrterm#DockerTerminalSelect('!') | else | call mydkrterm#DockerTerminal(<q-args>, 1) | endif
