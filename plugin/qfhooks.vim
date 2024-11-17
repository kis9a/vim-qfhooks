if exists('g:loaded_qfhooks')
  finish
endif
let g:loaded_qfhooks = 1

if !exists('g:qfhooks_context_hook_key')
  let g:qfhooks_context_hook_key = 'qfhooks'
endif

if !exists('g:qfhooks_context_hooks')
  let g:qfhooks_context_hooks = {}
endif

if !exists('g:qfhooks_title_hooks')
  let g:qfhooks_title_hooks = {}
endif

function! QfHooksNoItemsErrorFunc()
endfunction

if !exists('g:qfhooks_no_items_error_func')
  let g:qfhooks_no_items_error_func = 'QfHooksNoItemsErrorFunc'
endif

if !exists('g:qfhooks_default_cmds')
  let g:qfhooks_default_cmds = ['cnext', 'cprevious', 'cc', 'cfirst', 'clast']
endif

function! s:qfhooks_enum(items) abort
  let dict = {}
  let index = 0
  for item in a:items
    let dict[item] = index
    let index += 1
  endfor
  return dict
endfunction

let g:qfhooks_cmds = ['cnext', 'cprevious', 'cc', 'cfirst', 'clast', 'copen', 'cwindow', 'cclose']
let g:qfhooks_cmds_enum = s:qfhooks_enum(g:qfhooks_cmds)
let g:qfhooks_stages = ['before', 'after']
let g:qfhooks_stages_enum = s:qfhooks_enum(g:qfhooks_stages)
let g:qfhooks_default_stage = 'after'

command! -bang QFHooksCnext call qfhooks#command#qf_hooks_cnext(<bang>0)
command! -bang QFHooksCprevious call qfhooks#command#qf_hooks_cprevious(<bang>0)
command! -bang -nargs=? QFHooksCfirst call qfhooks#command#qf_hooks_cfirst(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksClast call qfhooks#command#qf_hooks_clast(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksCc call qfhooks#command#qf_hooks_cc(<bang>0, <q-args>)
command! -nargs=? QFHooksCopen call qfhooks#command#qf_hooks_copen(<q-args>)
command! -nargs=? QFHooksCwindow call qfhooks#command#qf_hooks_cwindow(<q-args>)
command! QFHooksCclose call qfhooks#command#qf_hooks_cclose()
