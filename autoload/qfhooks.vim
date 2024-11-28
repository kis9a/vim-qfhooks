function! s:prepare_wrap(cmd, up, count, list) abort
  let Noop = function('execute', [''])
  let idx = a:list.idx
  let size = a:list.size
  if size == 0
    return Noop
  endif
  if a:up
    if idx + a:count > size
      return function('execute', [a:cmd])
    endif
  else
    if idx - a:count < 1
      return function('execute', [a:cmd])
    endif
  endif
  return Noop
endfunction

function! s:callback_wrap(cmd, up, count, list) abort
  let Noop = function('execute', [''])
  let idx = a:list.idx
  let size = a:list.size
  if size == 0
    return Noop
  endif
  let next_idx = a:up ? (idx + a:count) % size : (size - (a:count - idx) % size)
  return function('qfhooks#execute_cmd', [a:cmd . ' ' . (next_idx > 0 ? next_idx : '')])
endfunction

function! s:get_list(cmd, list_type) abort
  if a:list_type ==# 'qf'
    return getqflist({'all': 0})
  elseif a:list_type ==# 'loc'
    return getloclist(0, {'all': 0})
  else
    return {}
  endif
endfunction

function! s:get_cmd_name(cmd) abort
  return substitute(substitute(matchstr(a:cmd, '^\S\+'), '!\s*$', '', ''), '^\d\+\s*', '', '')
endfunction

function! s:get_list_type(cmd_name) abort
  if a:cmd_name =~ '^c'
    return 'qf'
  elseif a:cmd_name =~ '^l'
    return 'loc'
  else
    return ''
  endif
endfunction

function! s:wrap_cmd_bang(cmd, bang) abort
  let cmd = a:cmd
  if a:bang
    let cmd .= '!'
  endif
  return cmd
endfunction

function! qfhooks#execute_cmd(cmd) abort
  let list = s:get_list(a:cmd, s:get_list_type(s:get_cmd_name(a:cmd)))
  call qfhooks#hook_cmd(a:cmd, list)
endfunction

function! qfhooks#execute_wrap_around_cmd(cmd, bang, callback, preparer) abort
  let list = s:get_list(a:cmd, s:get_list_type(s:get_cmd_name(a:cmd)))
  if exists('a:preparer') | call a:preparer(list)() | endif
  try
    call qfhooks#hook_cmd(a:cmd, list)
  catch /^Vim\%((\a\+)\)\=:E553/
    if exists('a:callback') | call a:callback(list)() | endif
  endtry
endfunction

function! qfhooks#hook_cmd(cmd, list) abort
  try
    call qfhooks#execute_hook(a:cmd, g:qfhooks_stages_enum['before'], a:list)
    call execute(a:cmd)
    call qfhooks#execute_hook(a:cmd, g:qfhooks_stages_enum['after'], a:list)
  catch /^Vim\%((\a\+)\)\=:E42/
    call function(g:qfhooks_no_items_error_func)
  endtry
endfunction

function! qfhooks#execute_hook(cmd, stage, list) abort
  if empty(a:list)
    return
  endif

  let context = a:list.context
  let title = a:list.title
  let context_hook_key = get(g:, 'qfhooks_context_hook_key', 'qfhooks')
  let context_dict = {}

  if type(context) == type('')
    try
      let context_dict = json_decode(context)
    catch
    endtry
  elseif type(context) == type({})
    let context_dict = context
  endif

  if type(context_dict) == type({}) && has_key(context_dict, context_hook_key)
    let context_key = context_dict[context_hook_key]

    if has_key(g:qfhooks_context_hooks, context_key)
      for hook_info in g:qfhooks_context_hooks[context_key]
        let stage = get(hook_info, 'stage', g:qfhooks_default_stage)
        let cmds = get(hook_info, 'cmds', g:qfhooks_default_cmds)
        if g:qfhooks_stages_enum[stage] ==# a:stage && index(cmds, s:get_cmd_name(a:cmd)) != -1
          call hook_info.hook()
        endif
      endfor
    endif
  endif

  for pattern in keys(g:qfhooks_title_hooks)
    if match(title, pattern) != -1
      for hook_info in g:qfhooks_title_hooks[pattern]
        let stage = get(hook_info, 'stage', g:qfhooks_default_stage)
        let cmds = get(hook_info, 'cmds', g:qfhooks_default_cmds)
        if g:qfhooks_stages_enum[stage] ==# a:stage && index(cmds, s:get_cmd_name(a:cmd)) != -1
          call hook_info.hook()
          break
        endif
      endfor
    endif
  endfor
endfunction

function! qfhooks#cnext(bang, count) abort
  let c = a:count > 1 ? a:count : 1
  let cmd = s:wrap_cmd_bang(c . 'cnext', a:bang)
  let args = ['clast', v:true, c]
  call qfhooks#execute_wrap_around_cmd(
      \ cmd,
      \ a:bang,
      \ function('s:callback_wrap', args),
      \ function('s:prepare_wrap', args)
      \ )
endfunction

function! qfhooks#cprevious(bang, count) abort
  let c = a:count > 1 ? a:count : 1
  let cmd = s:wrap_cmd_bang(c . 'cprevious', a:bang)
  let args = ['cfirst', v:false, c]
  call qfhooks#execute_wrap_around_cmd(
      \ cmd,
      \ a:bang,
      \ function('s:callback_wrap', args),
      \ function('s:prepare_wrap', args)
      \ )
endfunction

function! qfhooks#cc(bang, nr) abort
  let cmd = s:wrap_cmd_bang('cc', a:bang) . (a:nr ? ' ' . a:nr : line('.'))
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#cfirst(bang, nr) abort
  let cmd = s:wrap_cmd_bang('cfirst', a:bang) . (a:nr ? ' ' . a:nr : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#clast(bang, nr) abort
  let cmd = s:wrap_cmd_bang('clast', a:bang) . (a:nr ? ' ' . a:nr : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#copen(height) abort
  let cmd = 'copen' . (a:height ? ' ' . a:height : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#cwindow(height) abort
  let cmd = 'cwindow' . (a:height ? ' ' . a:height : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#cclose() abort
  let cmd = 'cclose'
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#lnext(bang, count) abort
  let c = a:count > 1 ? a:count : 1
  let cmd = s:wrap_cmd_bang(c . 'lnext', a:bang)
  let args = ['llast', v:true, c]
  call qfhooks#execute_wrap_around_cmd(
      \ cmd,
      \ a:bang,
      \ function('s:callback_wrap', args),
      \ function('s:prepare_wrap', args)
      \ )
endfunction

function! qfhooks#lprevious(bang, count) abort
  let c = a:count > 1 ? a:count : 1
  let cmd = s:wrap_cmd_bang(c . 'lprevious', a:bang)
  let args = ['lfirst', v:false, c]
  call qfhooks#execute_wrap_around_cmd(
      \ cmd,
      \ a:bang,
      \ function('s:callback_wrap', args),
      \ function('s:prepare_wrap', args)
      \ )
endfunction

function! qfhooks#ll(bang, nr) abort
  let cmd = s:wrap_cmd_bang('ll', a:bang) . (a:nr ? ' ' . a:nr : line('.'))
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#lfirst(bang, nr) abort
  let cmd = s:wrap_cmd_bang('lfirst', a:bang) . (a:nr ? ' ' . a:nr : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#llast(bang, nr) abort
  let cmd = s:wrap_cmd_bang('llast', a:bang) . (a:nr ? ' ' . a:nr : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#lopen(height) abort
  let cmd = 'lopen' . (a:height ? ' ' . a:height : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#lwindow(height) abort
  let cmd = 'lwindow' . (a:height ? ' ' . a:height : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#lclose() abort
  let cmd = 'lclose'
  call qfhooks#execute_cmd(cmd)
endfunction
