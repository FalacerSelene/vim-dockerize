"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/vdockerize.vim                                    |
"|                                                                           |
"|  DESCRIPTION:  Main public functions.                                     |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                            PUBLIC FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| vdockerize#DockerTerminal(image_name, use_curwin) {{{                     |
"|                                                                           |
"| Run a given docker image in a new terminal window.                        |
"|                                                                           |
"| PARAMS:                                                                   |
"|   image_name) The image to run.                                           |
"|   use_curwin) Should we run the image in the current window? Otherwise,   |
"|               open and run in a new window.                               |
"|===========================================================================|
function! vdockerize#DockerTerminal(image_name, use_curwin) abort
	let l:cmd = <SID>BuildDockerCommand(a:image_name)

	if a:use_curwin
		exe 'terminal' '++curwin' l:cmd
	else
		exe 'terminal' l:cmd
	endif

	let &l:statusline = a:image_name
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| vdockerize#ImageSelectionDialogue() {{{                                   |
"|                                                                           |
"| Open an image selection dialogue, requesting the user pick one of their   |
"| saved docker images.                                                      |
"|                                                                           |
"| PARAMS: None                                                              |
"|                                                                           |
"| Returns the selected image name, or the empty string.                     |
"|===========================================================================|
function! vdockerize#ImageSelectionDialogue() abort
	let l:images = systemlist('docker images --format ''{{.Repository}}:{{.Tag}}''')
	let l:choices = copy(l:images)
	call map(l:choices, {i, ss -> i . ': ' . ss})
	let l:choices = join(l:choices, "\n")
	let l:selection = input(l:choices . "\n? ", '')
	let l:num = str2nr(l:selection)

	if l:selection ==# ''
		return ''
	elseif match(l:selection, '^\v\s*\d+\s*$') == -1
		echoerr 'Doesn''t look like a number:' l:num
		return ''
	elseif l:num > len(l:images)
		echoerr 'Invalid selection:' l:num
		return ''
	endif

	return l:images[l:num]
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"|                            SCRIPT FUNCTIONS                               |
"|===========================================================================|

"|===========================================================================|
"| s:BuildDockerCommand(image_name) {{{                                      |
"|                                                                           |
"| Build a docker command to run the provided image.                         |
"|                                                                           |
"| PARAMS:                                                                   |
"|   image_name) the docker image to run.                                    |
"|                                                                           |
"| Returns the command, ready for :!, :terminal or system().                 |
"|===========================================================================|
function! s:BuildDockerCommand(image_name)
	let l:builder = vdockerize#builder#New()

	call <SID>SetCommon(l:builder)
	call <SID>SetCwd(l:builder)
	call <SID>SetSsh(l:builder)
	call <SID>SetTmux(l:builder)
	"call <SID>SetUser(l:builder)
	call <SID>SetShell(l:builder)

	return l:builder.build(a:image_name)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetCwd(builder) {{{                                                     |
"|                                                                           |
"| Set the CWD and mount in a builder.                                       |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetCwd(builder)
	let l:dir = getcwd()
	return a:builder.add_arg('--workdir').add_arg(l:dir).add_vol(l:dir, l:dir)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetCommon(builder) {{{                                                  |
"|                                                                           |
"| Set common docker arguments.                                              |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetCommon(builder)
	call a:builder.add_arg('--interactive')
	call a:builder.add_arg('--tty')
	call a:builder.add_arg('--rm')
	call a:builder.add_arg('--net=host')
	return a:builder
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetSsh(builder) {{{                                                     |
"|                                                                           |
"| Set ssh socket forwarding.                                                |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetSsh(builder)
	let l:sock = $SSH_AUTH_SOCK
	if empty(l:sock)
		return
	endif
	let l:d = fnamemodify(l:sock, ':h')

	return a:builder.add_env('SSH_AUTH_SOCK', l:sock).add_vol(l:d, l:d)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetTmux(builder) {{{                                                    |
"|                                                                           |
"| Set tmux socket forwarding.                                               |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetTmux(builder)
	let l:tmuxenv = $TMUX
	if empty(l:tmuxenv)
		return
	endif
	let l:tmux = split(l:tmuxenv, ',')[0]

	let l:dir = fnamemodify(l:tmux, ':h')
	let l:file = fnamemodify(l:tmux, ':t')

	let l:mount = printf('/run/tmux/%s', l:file)

	call a:builder.add_env('TMUX_SOCKET', l:mount)
	call a:builder.add_vol(l:dir, '/run/tmux')
	return a:builder
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetShell(builder) {{{                                                   |
"|                                                                           |
"| Set the users SHELL.                                                      |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetShell(builder)
	return a:builder.add_env('SHELL', '/bin/sh')
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|

"|===========================================================================|
"| s:SetUser(builder) {{{                                                    |
"|                                                                           |
"| Set the internal image user.                                              |
"|                                                                           |
"| PARAMS:                                                                   |
"|   builder) The builder.                                                   |
"|                                                                           |
"| Returns the builder.                                                      |
"|===========================================================================|
function! s:SetUser(builder)
	let l:user = systemlist('id -u')[0]
	let l:group = systemlist('id -g')[0]
	let l:home = expand('~')
	call a:builder.add_arg('--user')
	call a:builder.add_arg(printf('%s:%s', l:user, l:group))
	call a:builder.add_env('USER', l:user)
	call a:builder.add_vol('/etc/passwd', '/etc/passwd')
	call a:builder.add_env('HOME', l:home)
	call a:builder.add_vol(l:home, l:home)
	return a:builder
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
