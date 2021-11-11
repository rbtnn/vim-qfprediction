
# vim-qfprediction

This plugin provides to tell you to which window for jumping  when `:cnext`, `:cprevious` and selecting an error in the quickfix window.

## Usage

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

## License

Distributed under MIT License. See LICENSE.

