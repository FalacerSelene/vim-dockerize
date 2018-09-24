function! vdockerize#DockerTerminal(image_name, use_curwin) abort
	let l:cmd = <SID>BuildDockerCommand(a:image_name)

	if a:use_curwin
		exe 'terminal' '++curwin' l:cmd
	else
		exe 'terminal' l:cmd
	endif

	let &l:statusline = a:image_name
endfunction

function! vdockerize#ImageSelectionDialogue() abort
	let l:images = systemlist('docker images --format ''{{.Repository}}:{{.Tag}}''')
	let l:choices = copy(l:images)
	call map(l:choices, {i, ss -> i . ': ' . ss})
	let l:choices = join(l:choices, "\n")

	let l:default = ''
	if has_key(g:, 'mydkr')
		let l:idx = index(l:choices, g:mydkr)
		if l:idx != -1
			let l:default = string(l:idx)
		endif
	endif

	let l:selection = input(l:choices . "\n? ", l:default)
	let l:num = str2nr(l:selection)
	if l:selection ==# ''
		return
	elseif match(l:selection, '^\v\s*\d+\s*$') == -1
		echoerr 'Doesn''t look like a number:' l:num
		return
	elseif l:num > len(l:images)
		echoerr 'Invalid selection:' l:num
		return
	endif
	let l:selected = l:images[l:num]
	return l:selected
endfunction

function! s:Builder()
	let l:self = {'args': [], 'env': {}, 'volumes': {}}

	function l:self.add_arg(arg)
		call add(l:self.args, a:arg)
	endfunction

	function l:self.add_env(key, value)
		let l:self.env[a:key] = a:value
	endfunction

	function l:self.add_vol(key, value)
		let l:self.volumes[a:key] = a:value
	endfunction

	function l:self.build(image_name)
		let l:ret = ['docker', 'run']
		call extend(l:ret, l:self.args)

		for [l:k, l:v] in items(l:self.env)
			call add(l:ret, '--env')
			call add(l:ret, printf('%s=%s', l:k, l:v))
		endfor

		for [l:k, l:v] in items(l:self.volumes)
			call add(l:ret, '--volume')
			call add(l:ret, printf('%s:%s', l:k, l:v))
		endfor

		call add(l:ret, a:image_name)
		return join(l:ret)
	endfunction

	return l:self
endfunction

function! s:BuildDockerCommand(image_name)
	let l:builder = <SID>Builder()

	call <SID>SetCommon(l:builder)
	call <SID>SetCwd(l:builder)
	call <SID>SetSsh(l:builder)
	call <SID>SetTmux(l:builder)
	"call <SID>SetUser(l:builder)
	call <SID>SetShell(l:builder)

	return l:builder.build(a:image_name)
endfunction

function! s:SetCwd(builder)
	let l:dir = getcwd()
	call a:builder.add_arg('--workdir')
	call a:builder.add_arg(l:dir)
	call a:builder.add_vol(l:dir, l:dir)
endfunction

function! s:SetCommon(builder)
	call a:builder.add_arg('--interactive')
	call a:builder.add_arg('--tty')
	call a:builder.add_arg('--rm')
	call a:builder.add_arg('--net=host')
endfunction

function! s:SetSsh(builder)
	let l:sock = $SSH_AUTH_SOCK
	if empty(l:sock)
		return
	endif
	let l:sockdir = fnamemodify(l:sock, ':h')
	call a:builder.add_env('SSH_AUTH_SOCK', l:sock)
	call a:builder.add_vol(l:sockdir, l:sockdir)
endfunction

function! s:SetTmux(builder)
	let l:tmuxenv = $TMUX
	if empty(l:tmuxenv)
		return
	endif
	let l:tmux = split(l:tmuxenv, ',')[0]
	let l:tmuxdir = fnamemodify(l:tmux, ':h')
	let l:tmuxfile = fnamemodify(l:tmux, ':t')
	call a:builder.add_env('TMUX_SOCKET', printf('/run/tmux/%s', l:tmuxfile))
	call a:builder.add_vol(l:tmuxdir, '/run/tmux')
endfunction

function! s:SetShell(builder)
	call a:builder.add_env('SHELL', '/bin/sh')
endfunction

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
endfunction
