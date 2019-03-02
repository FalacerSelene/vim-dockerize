"|===========================================================================|
"|                                                                           |
"|         FILE:  plugin/vdockerize.vim                                      |
"|                                                                           |
"|  DESCRIPTION:  Main entrance for vdockerize.                              |
"|                                                                           |
"|       AUTHOR:  @FalacerSelene                                             |
"|      CONTACT:  < git at falacer-selene dot net >                          |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  0.2.0 <alpha>                                              |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                                  SETUP                                    |
"|===========================================================================|
scriptencoding utf-8

if &compatible || exists('g:loaded_dockerize')
	finish
elseif v:version < 800
	echoerr 'Vim-Dockerize requires vim 8.0 or later!'
elseif !(has('terminal') && has('lambda'))
	echoerr 'Vim-Dockerize must be compiled with "terminal" and "lambda"!'
endif

let g:loaded_dockerize = 1
let g:dockerize_version = '0.2.0'
lockvar g:dockerize_version

"|===========================================================================|
"|                             USER INTERFACE                                |
"|===========================================================================|

command -nargs=? -bang Dockerize call <SID>DockerizeCommand(<q-args>)

"|===========================================================================|
"|                            SCRIPT FUNCTIONS                               |
"|===========================================================================|

function s:DockerizeCommand(image)
	if !vdockerize#HasDocker()
		echoerr 'Vim-Dockerize requires "docker" to be installed!'
	endif
	let l:image = a:image

	if empty(l:image)
		let l:image = get(g:, 'dockerize_default_image', '')
	endif

	if empty(l:image)
		let l:image = vdockerize#ImageSelectionDialogue()
	endif

	call vdockerize#DockerTerminal(l:image, 1)
endfunction
