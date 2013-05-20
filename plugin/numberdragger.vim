" Author: Yee Cheng Chin

if ( exists("g:loaded_numberdragger") && g:loaded_numberdragger ) || &cp || v:version < 700
  finish
endif
let g:loaded_numberdragger = 1

" Old code that uses Start/End/OnDrag mechanism that didn't seem to work too
" wel especially with how getchar() is used. New code just has a while loop
" that redraws itself and queries the updated mouse position
let g:dragger_started = 0
let g:dragger_last_pos = 0
let g:dragger_has_change = 0
function! StartDrag()
    let g:dragger_started = 1
    let l:last_char = getchar(0)
    let g:dragger_last_pos = v:mouse_col
endfunction

function! EndDrag()
    let g:dragger_started = 0
endfunction

function! Dragged()
    let l:last_char = getchar(0)
    let g:dragger_last_pos = v:mouse_col
    let l:diff = v:mouse_col - g:dragger_last_pos
    echo v:mouse_col
    if l:diff > 0
        exe "normal \<c-a>"
        if g:dragger_has_change == 0
            let g:dragger_has_change = 1
        else
            undojoin
        endif
    elseif l:diff < 0
        exe "normal \<c-x>"
        if g:dragger_has_change == 0
            let g:dragger_has_change = 1
        else
            undojoin
        endif
    endif
endfunc

" TODOs:
" - Use word under cursor to early out if not hovering over numbers
" - Auto calculate multiplier based on number
" - Remember last multiplier?
" - Decimal?
" - Hover highlight. If can't do that at least when number is clicked need to
"   highlight / underline it
" - When mouse is off window figure how how to make it work
" - Mouse wheel support? Could do ctrl-wheel or something like that
" - Autosave for interactive editing
" - Make this work for multi-window using win_pos
" - Make this work with speeddate plugin or other plugins that use <C-A>/<C-X>
function! s:Dragger()
  let l:first_drag = 1
  let l:has_change = 0
  let l:last_col = 0

  let l:multiplier = 1
  redraw
  echo "x" . l:multiplier

  while 1
    let l:last_char = getchar()
    if l:last_char != "\<LeftDrag>"
      if l:last_char == char2nr("=")
        let l:multiplier = l:multiplier * 10
        redraw
        echo "x" . l:multiplier
      elseif l:last_char == char2nr("-")
        let l:multiplier = l:multiplier / 10
        if l:multiplier < 1
          let l:multiplier = 1
        endif
        redraw
        echo "x" . l:multiplier
      else
        break
      endif
    else
      if l:first_drag
        let l:last_col = v:mouse_col
        let l:first_drag = 0
      endif
      let l:diff = v:mouse_col - l:last_col
      let l:last_col = v:mouse_col
      let l:cmd = ""
      if l:diff > 0
        let l:cmd = "\<c-a>"
      elseif l:diff < 0
        let l:cmd = "\<c-x>"
      endif

      if l:diff != 0
        let l:normal_cmd = "normal! " . l:multiplier . l:cmd

        if l:has_change
          exec "undojoin | " . l:normal_cmd
        else
          exec l:normal_cmd
          let l:has_change = 1
        endif
        redraw
      endif
    endif
  endwhile
endfunction

"noremap <silent> <LeftMouse> <LeftMouse>:call StartDrag()<CR>
"noremap <silent> <LeftRelease> :call EndDrag()<CR>
"noremap <silent> <LeftDrag> :call Dragged()<CR>
"noremap <silent> <LeftMouse> <LeftMouse>:call Dragger()<CR>

" vim:set ft=vim sw=2 sts=2 et:
