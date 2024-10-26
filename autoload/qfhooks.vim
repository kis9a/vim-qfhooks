function! qfhooks#execute_cmd(cmd) abort
  call qfhooks#execute_hook(a:cmd, g:qfhooks_stages_enum['before'])
  execute a:cmd
  call qfhooks#execute_hook(a:cmd, g:qfhooks_stages_enum['after'])
endfunction

function! qfhooks#wrap_around_cmd(cmd, wrap_cmd) abort
  try
    call qfhooks#execute_cmd(a:cmd)
  catch /^Vim\%((\a\+)\)\=:E553/
    call qfhooks#execute_cmd(a:wrap_cmd)
  catch /^Vim\%((\a\+)\)\=:E42/
    call function(g:qfhooks_no_items_error_func)
  endtry
endfunction

function! qfhooks#wrap_cmd_bang(cmd, bang) abort
  let cmd = a:cmd
  if a:bang
    let cmd .= '!'
  endif
  return cmd
endfunction

function! qfhooks#cnext(bang) abort
  let cmd = qfhooks#wrap_cmd_bang('cnext', a:bang)
  call qfhooks#wrap_around_cmd(cmd, 'cfirst')
endfunction

function! qfhooks#cprevious(bang) abort
  let cmd = qfhooks#wrap_cmd_bang('cprevious', a:bang)
  call qfhooks#wrap_around_cmd(cmd, 'clast')
endfunction

function! qfhooks#cc(bang, nr) abort
  let cmd = qfhooks#wrap_cmd_bang('cc', a:bang) . (a:nr ? ' ' . a:nr : line('.'))
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#cfirst(bang, nr) abort
  let cmd = qfhooks#wrap_cmd_bang('cfirst', a:bang) . (a:nr ? ' ' . a:nr : '')
  call qfhooks#execute_cmd(cmd)
endfunction

function! qfhooks#clast(bang, nr) abort
  let cmd = qfhooks#wrap_cmd_bang('clast', a:bang) . (a:nr ? ' ' . a:nr : '')
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

function! s:getPureCommandStr(cmd) abort
  return substitute(matchstr(a:cmd, '^\S\+'), '!\s*$', '', '')
endfunction

function! qfhooks#execute_hook(cmd, stage) abort
  let qf_list = getqflist({'all': 0})
  if empty(qf_list)
    return
  endif

  let context = qf_list.context
  let title = qf_list.title
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
        if g:qfhooks_stages_enum[stage] ==# a:stage && index(cmds, s:getPureCommandStr(a:cmd)) != -1
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
        if g:qfhooks_stages_enum[stage] ==# a:stage && index(cmds, s:getPureCommandStr(a:cmd)) != -1
          call hook_info.hook()
          break
        endif
      endfor
    endif
  endfor
endfunction
