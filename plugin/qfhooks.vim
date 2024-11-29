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
  let g:qfhooks_default_cmds = ['cnext', 'cprevious', 'cc', 'cfirst', 'clast', 'lnext', 'lprevious', 'll', 'lfirst', 'llast']
endif

if !exists('g:qfhooks_default_priority')
  let g:qfhooks_default_priority = 10
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

let g:qfhooks_cmds = ['cnext', 'cprevious', 'cc', 'cfirst', 'clast', 'copen', 'cwindow', 'cclose', 'lnext', 'lprevious', 'll', 'lfirst', 'llast', 'lopen', 'lwindow', 'lclose']
let g:qfhooks_cmds_enum = s:qfhooks_enum(g:qfhooks_cmds)
let g:qfhooks_stages = ['before', 'after']
let g:qfhooks_stages_enum = s:qfhooks_enum(g:qfhooks_stages)
let g:qfhooks_default_stage = 'after'

command! -count=1 -bang QFHooksCnext call qfhooks#command#qf_hooks_cnext(<bang>0, <count>)
command! -count=1 -bang QFHooksCprevious call qfhooks#command#qf_hooks_cprevious(<bang>0, <count>)
command! -bang -nargs=? QFHooksCfirst call qfhooks#command#qf_hooks_cfirst(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksClast call qfhooks#command#qf_hooks_clast(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksCc call qfhooks#command#qf_hooks_cc(<bang>0, <q-args>)
command! -nargs=? QFHooksCopen call qfhooks#command#qf_hooks_copen(<q-args>)
command! -nargs=? QFHooksCwindow call qfhooks#command#qf_hooks_cwindow(<q-args>)
command! QFHooksCclose call qfhooks#command#qf_hooks_cclose()

nnoremap <silent> <Plug>(QFHooksCnext) :<C-U>execute v:count1 . 'QFHooksCnext'<CR>
nnoremap <silent> <Plug>(QFHooksCprevious) :<C-U>execute v:count1 . 'QFHooksCprevious'<CR>

command! -count=1 -bang QFHooksLnext call qfhooks#command#qf_hooks_lnext(<bang>0, <count>)
command! -count=1 -bang QFHooksLprevious call qfhooks#command#qf_hooks_lprevious(<bang>0, <count>)
command! -bang -nargs=? QFHooksLfirst call qfhooks#command#qf_hooks_lfirst(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksLlast call qfhooks#command#qf_hooks_llast(<bang>0, <q-args>)
command! -bang -nargs=? QFHooksLl call qfhooks#command#qf_hooks_ll(<bang>0, <q-args>)
command! -nargs=? QFHooksLopen call qfhooks#command#qf_hooks_lopen(<q-args>)
command! -nargs=? QFHooksLwindow call qfhooks#command#qf_hooks_lwindow(<q-args>)
command! QFHooksLclose call qfhooks#command#qf_hooks_lclose()

nnoremap <silent> <Plug>(QFHooksLnext) :<C-U>execute v:count1 . 'QFHooksLnext'<CR>
nnoremap <silent> <Plug>(QFHooksLprevious) :<C-U>execute v:count1 . 'QFHooksLprevious'<CR>
