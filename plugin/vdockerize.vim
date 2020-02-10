"|===========================================================================|
"|                                                                           |
"|         FILE:  plugin/vdockerize.vim                                      |
"|                                                                           |
"|  DESCRIPTION:  Main entrance for vdockerize.                              |
"|                                                                           |
"|       AUTHOR:  @FalacerSelene                                             |
"|      CONTACT:  < git at falacer-selene dot net >                          |
"|      LICENCE:  See LICENCE.md                                             |
"|      VERSION:  0.2.1                                                      |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                                  SETUP                                    |
"|===========================================================================|
scriptencoding utf-8

if &compatible || exists('g:loaded_dockerize')
	finish
endif

let g:loaded_dockerize = 1
let g:DockerizeVersion = '0.2.1'

"|===========================================================================|
"|                             USER INTERFACE                                |
"|===========================================================================|

command -nargs=? -bang Dockerize call <SID>Dockerize(<q-args>, <q-bang>, 1)
command -nargs=? -bang DockerizeNew call <SID>Dockerize(<q-args>, <q-bang>, 0)

"|===========================================================================|
"|                            SCRIPT FUNCTIONS                               |
"|===========================================================================|

function s:Dockerize(image, bang, curwin)
	if !exists('s:dockerizeready')
		let s:dockerizeready = vdockerize#IsReady()
	endif

	if !s:dockerizeready
		return
	endif

	let l:image = a:image

	" If bang is given then skip attempts to default.
	if a:bang !=# '!'

		" If the vim var is set, then use that.
		if empty(l:image)
			let l:image = vdockerize#GetVar('DockerizeDefaultImage', '')
		endif

		" Otherwise, try to use the expr
		if empty(l:image)
			let l:Expr = vdockerize#GetVar('DockerizeDefaultExpr', '')
			if type(l:Expr) == v:t_func
				let l:image = call(l:Expr, [])
			elseif !empty(l:Expr)
				let l:image = eval(l:Expr)
			endif
		endif
	endif

	if empty(l:image)
		let l:image = vdockerize#ImageSelectionDialogue()
	endif

	if !empty(l:image)
		call vdockerize#DockerTerminal(l:image, a:curwin)
	endif
endfunction
