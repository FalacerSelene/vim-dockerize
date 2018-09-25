"|===========================================================================|
"|                                                                           |
"|         FILE:  autoload/vdockerize/builder.vim                            |
"|                                                                           |
"|  DESCRIPTION:  Command building class.                                    |
"|                                                                           |
"|===========================================================================|

"|===========================================================================|
"|                                  CLASS                                    |
"|===========================================================================|

"|===========================================================================|
"| vdockerize#builder#New() {{{                                              |
"|                                                                           |
"| Create a new docker command builder.                                      |
"|                                                                           |
"| PARAMS: None                                                              |
"|                                                                           |
"| Returns the new object.                                                   |
"|===========================================================================|
function! vdockerize#builder#New()
	let l:self = {'args': [], 'env': {}, 'volumes': {}}

	"|===============================================|
	"| self.add_arg(arg) {{{                         |
	"|                                               |
	"| Add a new argument to the builder.            |
	"|                                               |
	"| PARAMS:                                       |
	"|   arg) The arg to add.                        |
	"|                                               |
	"| Returns itself.                               |
	"|===============================================|
	function l:self.add_arg(arg)
		call add(l:self.args, a:arg)
		return l:self
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.add_env(key, value) {{{                  |
	"|                                               |
	"| Add a new environmental var to the built      |
	"| image.                                        |
	"|                                               |
	"| PARAMS:                                       |
	"|   key) The name of the env.                   |
	"|   value) The value of the env.                |
	"|                                               |
	"| Returns itself.                               |
	"|===============================================|
	function l:self.add_env(key, value)
		let l:self.env[a:key] = a:value
		return l:self
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.add_vol(key, value) {{{                  |
	"|                                               |
	"| Add a new volume to the built image.          |
	"|                                               |
	"| PARAMS:                                       |
	"|   key) The name of the volume.                |
	"|   value) The mount dir of the volume.         |
	"|                                               |
	"| Returns itself.                               |
	"|===============================================|
	function l:self.add_vol(key, value)
		let l:self.volumes[a:key] = a:value
		return l:self
	endfunction
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	"|===============================================|
	"| self.build(image_name) {{{                    |
	"|                                               |
	"| Build the command line.                       |
	"|                                               |
	"| PARAMS:                                       |
	"|   image_name) The final image name for the    |
	"|               command.                        |
	"|                                               |
	"| Returns the command.                          |
	"|===============================================|
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
	"|===============================================|
	"| }}}                                           |
	"|===============================================|

	return l:self
endfunction
"|===========================================================================|
"| }}}                                                                       |
"|===========================================================================|
