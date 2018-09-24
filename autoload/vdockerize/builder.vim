function! vdockerize#builder#New()
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
