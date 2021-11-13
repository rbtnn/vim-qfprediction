
" This bases on the functions in {vim-repo}/src/quickfix.c.

let s:TEST_LOG = expand('<sfile>:h:h:gs?\?/?') . '/test.log'
let s:TEST_TXT = expand('<sfile>:h:h:gs?\?/?') . '/test.txt'

function! qfprediction#get(...) abort
	let n = 0 < a:0 ? a:1 : 0
	if 1 < n
		let n = 1
	elseif n < -1
		let n = -1
	endif
	let i = get(getqflist({'idx': 0}), 'idx', 0) + n - 1
	let xs = getqflist()
	if (0 <= i) && (i < len(xs))
		let x = s:qf_jump_open_window(xs[i])
		if !empty(x)
			return x
		endif
		return s:qf_jump_to_buffer(xs[i])
	else
		return {}
	endif
endfunction

function! qfprediction#run_tests() abort
	try
		set nomore

		if filereadable(s:TEST_LOG)
			call delete(s:TEST_LOG)
		endif

		let v:errors = []

		call writefile(['aaa', 'bbb', 'ccc', 'aaa', 'bbb', 'ccc', 'aaa', 'bbb', 'ccc'], s:TEST_TXT)

		" +-----------------+
		" |                 |
		" |                 |
		" |                 |
		" +-----------------+
		call assert_equal(
			\ [1, 0, {'idx': 0}, {}, {}, {}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])

		" +--------+
		" |        |
		" +--------+
		" |quickfix|
		" +--------+
		copen
		call assert_equal(
			\ [2, 1, {'idx': 0}, {}, {}, {}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])

		" +--------+
		" |test.txt|
		" +--------+
		" |quickfix|
		" +--------+
		cclose
		execute 'vimgrep /bbb/j ' .. s:TEST_TXT
		copen
		call feedkeys("j\<cr>", 'nx')
		call assert_equal(
			\ ['test.txt', 5, 1],
			\ [fnamemodify(bufname(), ':t'), line('.'), col('.')])
		call assert_equal(
			\ [2, 2, {'idx': 2}, {'winnr': 1, 'tabnr': 1}, {'winnr': 1, 'tabnr': 1}, {'winnr': 1, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call assert_equal(
			\ [1],
			\ [winnr()])

		" +--------+--------+
		" |test.txt|test.txt|
		" +--------+--------+
		" |quickfix         |
		" +-----------------+
		cclose
		vsplit
		copen
		call assert_equal(
			\ [3, 1, {'idx': 2}, {'winnr': 2, 'tabnr': 1}, {'winnr': 2, 'tabnr': 1}, {'winnr': 2, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call feedkeys("\<cr>", 'nx')
		call assert_equal(
			\ [2],
			\ [winnr()])

		" +-----------------+
		" |                 |
		" |                 |
		" |                 |
		" +-----------------+
		cclose
		enew
		only
		call assert_equal(
			\ [1, 0, {'idx': 2}, {'winnr': 1, 'tabnr': 1}, {'winnr': 1, 'tabnr': 1}, {'winnr': 1, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])

		" +-----------------+
		" |help             |
		" +-----------------+
		" |                 |
		" +-----------------+
		" |quickfix         |
		" +-----------------+
		helpgrep tabline
		copen
		call assert_equal(
			\ [3, 1, {'idx': 1}, {}, {'winnr': 1, 'tabnr': 1}, {'winnr': 1, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call feedkeys("\<cr>", 'nx')
		call assert_equal(
			\ [1],
			\ [winnr()])

		" +-----------------+
		" |                 |
		" +-----------------+
		" |help             |
		" +-----------------+
		" |quickfix         |
		" +-----------------+
		cclose
		wincmd x
		copen
		call assert_equal(
			\ [3, 1, {'idx': 1}, {}, {'winnr': 2, 'tabnr': 1}, {'winnr': 2, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call feedkeys("\<cr>", 'nx')
		call assert_equal(
			\ [2],
			\ [winnr()])

		" +-----------------+
		" |                 |
		" +-----------------+
		" |                 |
		" +-----------------+
		" |help             |
		" +-----------------+
		" |quickfix         |
		" +-----------------+
		cclose
		new
		copen
		call assert_equal(
			\ [4, 2, {'idx': 1}, {}, {'winnr': 3, 'tabnr': 1}, {'winnr': 3, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call feedkeys("\<cr>", 'nx')
		call assert_equal(
			\ [3],
			\ [winnr()])

		" +-----------------+
		" |                 |
		" +-----------------+
		" |quickfix         |
		" +-----------------+
		enew
		only
		copen
		wincmd w
		call assert_equal(
			\ [2, 2, {'idx': 1}, {}, {'split': v:true}, {'split': v:true}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])

		" +-----------------+
		" |                 |
		" +-----------------+
		" |                 |
		" +-----------------+
		" |                 |
		" +-----------------+
		set switchbuf=uselast
		cclose
		only
		enew
		execute 'vimgrep /bbb/j ' .. s:TEST_TXT
		new
		new
		wincmd w
		wincmd w
		call assert_equal(
			\ [3, 2, {'idx': 1}, {}, {'winnr': 3, 'tabnr': 1}, {'winnr': 3, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])

		" +-----------------+
		" |                 |
		" +-----------------+
		" |                 |
		" +-----------------+
		" |                 |
		" +-----------------+
		" |quickfix         |
		" +-----------------+
		wincmd w
		wincmd w
		call assert_equal(
			\ [1],
			\ [winnr('#')])
		copen
		call assert_equal(
			\ [4, 2, {'idx': 1}, {}, {'winnr': 2, 'tabnr': 1}, {'winnr': 2, 'tabnr': 1}],
			\ [winnr('$'), winnr('#'), getqflist({'idx': 0}), qfprediction#get(-1), qfprediction#get(), qfprediction#get(1)])
		call feedkeys("\<cr>", 'nx')
		call assert_equal(
			\ [2],
			\ [winnr()])

		if !empty(v:errors)
			let lines = []
			for err in v:errors
				let xs = split(err, '\(Expected\|but got\)')
				echohl ErrorMsg
				if 3 == len(xs)
					let lines += [
						\ xs[0],
						\ '  Expected ' .. xs[1],
						\ '  but got  ' .. xs[2],
						\ ]
					echo xs[0]
					echo '  Expected ' .. xs[1]
					echo '  but got  ' .. xs[2]
				else
					let lines += [err]
					echo err
				endif
				echohl None
			endfor
			call writefile(lines, s:TEST_LOG)
		endif
	catch 
		call writefile([v:exception, v:throwpoint], s:TEST_LOG)
	finally
		call delete(s:TEST_TXT)
	endtry
endfunction



function! s:qf_jump_to_buffer(curr_qfinfo) abort
	if !empty(a:curr_qfinfo)
		return s:debug({ 'tabnr': tabpagenr(), 'winnr': winnr() }, 'qf_jump_to_buffer')
	else
		return {}
	endif
endfunction

function! s:qf_jump_open_window(curr_qfinfo) abort
	if s:is_helpgrep() && !s:bt_help()
		let x = s:jump_to_help_window()
		if !empty(x)
			return x
		else
			return s:qf_open_new_file_win()
		endif
	endif
	if s:bt_quickfix()
		return s:qf_jump_to_usable_window(a:curr_qfinfo)
	endif
	return {}
endfunction

function! s:qf_jump_to_usable_window(curr_qfinfo) abort
	let usable_win = v:false
	let x = s:qf_find_win_with_normal_buf()
	if !empty(x)
		let usable_win = v:true
	endif
	if !usable_win && (&switchbuf =~# 'usetab')
		let x = s:qf_goto_tabwin_with_file(a:curr_qfinfo)
		if !empty(x)
			return x
		endif
	endif
	if ((winnr('$') == 1) && s:bt_quickfix()) || !usable_win
		return s:qf_open_new_file_win()
	endif
	return s:qf_goto_win_with_qfl_file(a:curr_qfinfo)
endfunction

function! s:qf_goto_win_with_qfl_file(curr_qfinfo) abort
	let wnr = winnr()
	let altwin = -1
	while 1
		if winbufnr(wnr) == get(a:curr_qfinfo, 'bufnr')
			break
		endif
		if wnr == 1
			let wnr = winnr('$')
		else
			let wnr -= 1
		endif
		if getbufvar(winbufnr(wnr), '&buftype') == 'quickfix'
			if &switchbuf =~# 'uselast' && (0 != winnr('#'))
				let wnr = winnr('#')
			elseif altwin != -1
				let wnr = altwin
			elseif 0 < winnr() - 1
				let wnr = winnr() - 1
			else
				let wnr = winnr() + 1
			endif
			break
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

function! s:qf_goto_tabwin_with_file(curr_qfinfo) abort
	let wins = getwininfo()
	let xs = filter(deepcopy(wins), { i,x -> x['bufnr'] == get(a:curr_qfinfo, 'bufnr') })
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
	return get(getqflist({ 'title': '' }), 'title') =~# '^\s*\(:\s*\)\+helpg\%[rep\]'
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

function! s:debug(d, msg) abort
	if get(g:, 'qfprediction_debug', v:false)
		return extend(a:d, { 'debug': a:msg })
	else
		return a:d
	endif
endfunction

