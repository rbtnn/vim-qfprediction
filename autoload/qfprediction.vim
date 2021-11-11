
" This is base on the qf_jump_open_window function in {vim-repo}/src/quickfix.c.

function! qfprediction#get() abort
	let x = s:qf_jump_open_window()
	if !empty(x)
		return x
	endif
	return s:qf_jump_to_buffer()
endfunction



function! s:qf_jump_to_buffer() abort
	let curr = s:qf_curr()
	if !empty(curr)
		return s:debug({ 'tabnr': tabpagenr(), 'winnr': winnr() }, 'qf_jump_to_buffer')
	else
		return {}
	endif
endfunction

function! s:qf_jump_open_window() abort
	if s:is_helpgrep() && !s:bt_help()
		return s:jump_to_help_window()
	endif
	if s:bt_quickfix()
		return s:qf_jump_to_usable_window()
	endif
	return {}
endfunction

function! s:qf_jump_to_usable_window() abort
	let usable_win = v:false
	let x = s:qf_find_win_with_normal_buf()
	if !empty(x)
		let usable_win = v:true
	endif
	if !usable_win && (&switchbuf =~# 'usetab')
		let x = s:qf_goto_tabwin_with_file()
		if !empty(x)
			return x
		endif
	endif
	if ((winnr('$') == 1) && s:bt_quickfix()) || !usable_win
		return s:qf_open_new_file_win()
	endif
	return s:qf_goto_win_with_qfl_file()
endfunction

function! s:qf_goto_win_with_qfl_file() abort
	let wnr = winnr()
	let altwin = -1
	let curr = s:qf_curr()
	while 1
		if winbufnr(wnr) == curr['bufnr']
			break
		endif
		if wnr == 1
			let wnr == winnr('$')
		else
			let wnr -= 1
		endif
		if getbufvar(winbufnr(wnr), '&buftype') == 'quickfix'
			if &switchbuf =~ 'uselast' && (0 != winnr('#'))
				let wnr = winnr('#')
			elseif altwin != -1
				let wnr = altwin
			elseif 0 < winnr() - 1
				let wnr = winnr() - 1
			else
				let wnr = winnr() + 1
			endif
		endif
		if (altwin == -1) && !getbufvar(winbufnr(wnr), '&previewwindow') && empty(getbufvar(winbufnr(wnr), '&buftype'))
			let altwin = wnr
		endif
	endwhile
	return s:debug({ 'tabnr': tabpagenr(), 'winnr': wnr }, 'qf_goto_win_with_qfl_file')
endfunction

function! s:qf_open_new_file_win() abort
	return s:debug({ 'split': v:true, }, 'qf_open_new_file_win')
endfunction

function! s:qf_goto_tabwin_with_file() abort
	let wins = getwininfo()
	let curr = s:qf_curr()
	let xs = filter(deepcopy(wins), { i,x -> x['bufnr'] == curr['bufnr'] })
	if !empty(xs)
		return s:debug({ 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }, 'qf_goto_tabwin_with_file')
	else
		return {}
	endif
endfunction

function! s:qf_find_win_with_normal_buf() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	let xs = filter(deepcopy(wins), { i,x -> empty(getbufvar(x['bufnr'], '&buftype')) })
	if !empty(xs)
		return s:debug({ 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }, 'qf_find_win_with_normal_buf')
	else
		return {}
	endif
endfunction

function! s:is_helpgrep() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	return !empty(filter(deepcopy(wins), { i,x -> get(x['variables'], 'quickfix_title') =~# '^\s*:\+helpg\%[rep\]' }))
endfunction

function! s:jump_to_help_window() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	let xs = filter(deepcopy(wins), { i,x -> getbufvar(x['bufnr'], '&buftype') == 'help' })
	if !empty(xs)
		return s:debug({ 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }, 'jump_to_help_window')
	else
		return {}
	endif
endfunction

function! s:bt_quickfix() abort
	return &buftype == 'quickfix'
endfunction

function! s:bt_help() abort
	return &buftype == 'help'
endfunction

function! s:qf_curr() abort
	let i = get(getqflist({ 'idx': 0 }), 'idx', 0)
	if 0 < i
		return getqflist()[i - 1]
	else
		return {}
	endif
endfunction

function! s:debug(d, msg) abort
	if get(g:, 'qfprediction_debug', v:false)
		return extend(a:d, { 'debug': a:msg })
	else
		return a:d
	endif
endfunction

