let s:suite = themis#suite('qfhooks')
let s:assert = themis#helper('assert')

let s:qf_list = [{'filename': 'a'}, {'filename': 'b'}, {'filename': 'c'}]

function! s:reset_vars() abort
  let g:hooked_count = 0
  let g:qfhooks_context_hooks = {}
  let g:qfhooks_title_hooks = {}
endfunction

function! IncrementHookedCount() abort
  let g:hooked_count += 1
endfunction

function! s:get_qf_list_idx() abort
  return getqflist({'all': 0}).idx
endfunction

function! s:set_qf_context_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:suite.test_context_cnext() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_cprevious() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cprevious(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_cfirst() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cfirst(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_clast() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_clast(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_cc() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cc(0, 1)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_copen() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_copen()
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'quickfix', 1)
endfunction

function! s:suite.test_context_copen_with_height() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_copen(5)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'quickfix', 1)
  call s:assert.equal(winheight(bufwinnr(bufnr('$'))), 5)
endfunction

function! s:suite.test_context_cwindow() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cwindow(10)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_cclose() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cclose()
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:set_qf_title_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'title': "title_hook",
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_title_hooks = {
    \ 'title_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:suite.test_title_cnext() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_cprevious() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cprevious(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_cfirst() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cfirst(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_clast() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_clast(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_cc() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cc(0, 1)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_copen() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_copen()
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'quickfix', 1)
endfunction

function! s:suite.test_title_cwindow() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cwindow(10)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_cclose() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cclose()
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_copen_with_height() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_copen(5)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'quickfix', 1)
  call s:assert.equal(winheight(bufwinnr(bufnr('$'))), 5)
endfunction

function! AssertBeforeQfListIdx() abort
  call s:assert.equal(s:get_qf_list_idx(), 1)
endfunction

function! s:set_qf_context_hook__stage_before() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('AssertBeforeQfListIdx'),
    \    'stage': 'before',
    \   }],
    \ }
endfunction

function! s:suite.test_context_hook__stage_before() abort
  call s:set_qf_context_hook__stage_before()
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:set_qf_context_hook__cmds_cnext() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': ['cnext'],
    \   }],
    \ }
endfunction

function! s:suite.test_context_hook__cmds_cnext() abort
  call s:set_qf_context_hook__cmds_cnext()
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_hook__cmds_cfile() abort
  call s:set_qf_context_hook__cmds_cnext()
  call qfhooks#command#qf_hooks_cfirst(0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:suite.test_context_cnext_bang() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cnext(1)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_clast_bang() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_clast(1)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_empty_qf_list() abort
  call s:reset_vars()
  call setqflist([], 'r', {'items': []})
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:set_invalid_context_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'invalid_hook'},
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'invalid_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': ['invalid_command'],
    \   }],
    \ }
endfunction

function! s:suite.test_invalid_command() abort
  call s:set_invalid_context_hook()
  call qfhooks#command#qf_hooks_cnext(0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:set_qf_context_hook__stage_before_bang() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('AssertBeforeQfListIdx'),
    \    'stage': 'before',
    \   }],
    \ }
endfunction

function! s:suite.test_context_hook__stage_before_bang() abort
  call s:set_qf_context_hook__stage_before_bang()
  call qfhooks#command#qf_hooks_cnext(1)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:set_qf_title_hook__multiple_cmds() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'title': "multi_cmd_hook",
    \ 'items': s:qf_list,
    \ })
  let g:qfhooks_title_hooks = {
    \ 'multi_cmd_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': ['cnext', 'cc'],
    \   }],
    \ }
endfunction

function! s:suite.test_title_hook__multiple_cmds() abort
  call s:set_qf_title_hook__multiple_cmds()
  call qfhooks#command#qf_hooks_cc(0, 2)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_hook__cmd_not_matched() abort
  call s:set_qf_title_hook__multiple_cmds()
  call qfhooks#command#qf_hooks_clast(0)
  call s:assert.equal(g:hooked_count, 0)
endfunction
