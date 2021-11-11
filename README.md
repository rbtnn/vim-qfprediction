
# vim-qfprediction

This plugin provides to tell you to which window for jumping  when `:cnext`, `:cprevious` and selecting an error in the quickfix window.

## Functions

### qfprediction#get()
Returns which window for jumping  when `:cnext`, `:cprevious` and selecting an error in the quickfix window.

```
" Will open a file of the error at the window of the return value.
echo qfprediction#get()
" -> { 'winnr': 1, 'tabnr': 2, }

" Will open a file of the error at new window.
echo qfprediction#get()
" -> { 'split': v:true, }


" Could not predict a window!
echo qfprediction#get()
" -> {}
```

The following is an example of using qfprediction#get().

```
function! TabLine() abort
	let x = qfprediction#get()
	if has_key(x, 'tabnr') && has_key(x, 'winnr')
		return printf('[qfprediction] Will open a file of the error at the window of tabnr:%d and winnr:%d.', x['tabnr'], x['winnr'])
	elseif has_key(x, 'split')
		return '[qfprediction] Will open a file of the error at new window.'
	else
		return '[qfprediction] Could not predict a window!'
	endif
endfunction
set showtabline=2
set tabline=%!TabLine()
augroup qfprediction
	autocmd!
	autocmd WinEnter * :redrawtabline
augroup END
```


## License

Distributed under MIT License. See LICENSE.

