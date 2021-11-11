
" This is base on the qf_jump_open_window function in vim repo src/quickfix.c.

function! qfprediction#get() abort
	return s:qf_jump_open_window()
endfunction



function! s:qf_jump_open_window() abort
	if s:is_helpgrep() && !s:bt_help()
		return s:jump_to_help_window()
	endif
	return s:qf_jump_to_usable_window()
endfunction

function! s:qf_jump_to_usable_window() abort
	let x = s:qf_find_win_with_normal_buf()
	if !empty(x)
		return x
	endif
	if &switchbuf =~# 'usetab'
		let x = s:qf_goto_tabwin_with_file()
		if !empty(x)
			return x
		endif
	endif
	if winnr('$') == 1
		return s:qf_open_new_file_win()
	endif
	return {}
endfunction

function! s:qf_open_new_file_win() abort
	return { 'split': v:true, }
endfunction

function! s:qf_goto_tabwin_with_file() abort
	let wins = getwininfo()
	let curr = s:qf_curr()
	let xs = filter(deepcopy(wins), { i,x -> x['bufnr'] == curr['bufnr'] })
	if !empty(xs)
		return { 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }
	else
		return {}
endfunction

function! s:qf_find_win_with_normal_buf() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	let xs = filter(deepcopy(wins), { i,x -> empty(getbufvar(x['bufnr'], '&buftype')) })
	if !empty(xs)
		return { 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }
	else
		return {}
	end
endfunction

function! s:is_helpgrep() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	return !empty(filter(deepcopy(wins), { i,x -> get(x['variables'], 'quickfix_title') =~# '^\s*:\+helpg\%[rep\]' }))
endfunction

function! s:jump_to_help_window() abort
	let wins = filter(getwininfo(), { i,x -> x['tabnr'] == tabpagenr() })
	let xs = filter(deepcopy(wins), { i,x -> getbufvar(x['bufnr'], '&buftype') == 'help' })
	if !empty(xs)
		return { 'tabnr': xs[0]['tabnr'], 'winnr': xs[0]['winnr'] }
	else
		return {}
	end
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

