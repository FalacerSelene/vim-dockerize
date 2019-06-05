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
endif

let g:loaded_dockerize = 1
let g:dockerize_version = '0.2.0'
lockvar g:dockerize_version

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
			let l:image = <SID>GetVar('dockerize_default_image')
		endif

		" Otherwise, try to use the expr
		if empty(l:image)
			let l:expr = <SID>GetVar('dockerize_default_expr')
			if type(l:expr) = v:t_func
				let l:image = call(l:expr, [])
			else
				if !empty(l:expr)
					let l:image = eval(l:expr)
				endif
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

function s:GetVar(varname)
	for l:scope in [g:, t:, w:, b:]
		if has_key(l:scope, a:var_name)
			return get(l:scope, a:var_name)
		endif
	endfor
	return ''
endfunction
