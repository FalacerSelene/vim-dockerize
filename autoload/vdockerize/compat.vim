"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/vdockerize/compat.vim                             |
"|                                                                           |
"|  DESCRIPTION:  Public functions for compatibility with similar systems.   |
"|                Functions in this file can be provided by the user as a    |
"|                DockerizeDefaultExpr in order to piggy-back on a different |
"|                system.                                                    |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            PUBLIC FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| vdockerize#compat#Floki() {{{                                             |
"|                                                                           |
"| Compatibility with https://github.com/Metaswitch/floki                    |
"|===========================================================================|
function! vdockerize#compat#Floki() abort
	let l:flokis = findfile('floki.yaml', g:hereup, -1)
	if empty(l:flokis)
		return ''
	endif
	let l:floki = l:flokis[0]

	if executable('rq')
		let l:cmd = printf(
			\ 'rq -yJ ''get "image"'' < ''%s''',
			\ l:floki)
		return json_decode(trim(system(l:cmd)))
	else
		let l:cmd = printf(
			\ 'sed --quiet ''/^image:\s*/{s///;p;q}'' %s',
			\ l:floki)
		return trim(system(l:cmd))
	endif
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
