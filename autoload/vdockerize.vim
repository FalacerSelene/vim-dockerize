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

	let l:default = ''
	if has_key(g:, 'vdockerize')
		let l:idx = index(l:choices, g:vdockerize)
		if l:idx != -1
			let l:default = string(l:idx)
		endif
	endif

	let l:selection = input(l:choices . "\n? ", l:default)
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
"|===========================================================================|
function! s:SetCwd(builder)
	let l:dir = getcwd()
	call a:builder.add_arg('--workdir')
	 \            .add_arg(l:dir)
	 \            .add_vol(l:dir, l:dir)
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
"|===========================================================================|
function! s:SetCommon(builder)
	call a:builder.add_arg('--interactive')
	 \            .add_arg('--tty')
	 \            .add_arg('--rm')
	 \            .add_arg('--net=host')
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
"|===========================================================================|
function! s:SetSsh(builder)
	let l:sock = $SSH_AUTH_SOCK
	if empty(l:sock)
		return
	endif
	let l:sockdir = fnamemodify(l:sock, ':h')
	call a:builder.add_env('SSH_AUTH_SOCK', l:sock)
	 \            .add_vol(l:sockdir, l:sockdir)
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
"|===========================================================================|
function! s:SetTmux(builder)
	let l:tmuxenv = $TMUX
	if empty(l:tmuxenv)
		return
	endif
	let l:tmux = split(l:tmuxenv, ',')[0]
	let l:tmuxdir = fnamemodify(l:tmux, ':h')
	let l:tmuxfile = fnamemodify(l:tmux, ':t')
	call a:builder.add_env('TMUX_SOCKET', printf('/run/tmux/%s', l:tmuxfile))
	 \            .add_vol(l:tmuxdir, '/run/tmux')
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
"|===========================================================================|
function! s:SetShell(builder)
	call a:builder.add_env('SHELL', '/bin/sh')
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
"|===========================================================================|
function! s:SetUser(builder)
	let l:user = systemlist('id -u')[0]
	let l:group = systemlist('id -g')[0]
	let l:home = expand('~')
	call a:builder.add_arg('--user')
	 \            .add_arg(printf('%s:%s', l:user, l:group))
	 \            .add_env('USER', l:user)
	 \            .add_vol('/etc/passwd', '/etc/passwd')
	 \            .add_env('HOME', l:home)
	 \            .add_vol(l:home, l:home)
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
