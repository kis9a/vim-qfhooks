let s:suite = themis#suite('qfhooks')
let s:assert = themis#helper('assert')

let s:list_items = [{'filename': 'a'}, {'filename': 'b'}, {'filename': 'c'}, {'filename': 'd'}, {'filename': 'e'}]

function! s:reset_vars() abort
  let g:hooked_count = 0
  let g:hooked_list = []
  let g:qfhooks_context_hooks = {}
  let g:qfhooks_title_hooks = {}
endfunction

function! IncrementHookedCount() abort
  let g:hooked_count += 1
endfunction

function! s:get_qf_list_idx() abort
  return getqflist({'all': 0}).idx
endfunction

function! s:get_loc_list_idx() abort
  return getloclist(0, {'all': 0}).idx
endfunction

function! s:set_qf_context_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_cprevious() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cprevious(0, 0)
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
    \ 'title': 'title_hook',
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_title_cprevious() abort
  call s:set_qf_title_hook()
  call qfhooks#command#qf_hooks_cprevious(0, 0)
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
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:set_qf_context_hook__cmds_cnext() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_hook__cmds_cfile() abort
  call s:set_qf_context_hook__cmds_cnext()
  call qfhooks#command#qf_hooks_cfirst(0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:suite.test_context_cnext_bang() abort
  call s:set_qf_context_hook()
  call qfhooks#command#qf_hooks_cnext(1, 0)
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:set_invalid_context_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'invalid_hook'},
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 0)
endfunction

function! s:set_qf_context_hook__stage_before_bang() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(1, 0)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:set_qf_title_hook__multiple_cmds() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'title': 'multi_cmd_hook',
    \ 'items': s:list_items,
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

function! s:set_qf_multiple_title_hooks() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'title': 'multi_hook_test',
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_title_hooks = {
    \ 'multi_hook_test': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ 'multi_hook_.*': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:set_qf_context_and_title_hooks() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'multi_hook_test'},
    \ 'title': 'multi_hook_test',
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_title_hooks = {
    \ 'multi_hook_test': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ 'multi_hook_.*': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
 let g:qfhooks_context_hooks = {
    \ 'multi_hook_test': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:suite.test_multiple_title_hooks() abort
  call s:set_qf_multiple_title_hooks()
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 2)
endfunction

function!s:suite.test_context_and_title_hooks() abort
  call s:set_qf_context_and_title_hooks()
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 3)
endfunction

function! s:set_loc_context_hook() abort
  call s:reset_vars()
  call setloclist(0, [], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
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
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_lnext() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_lprevious() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lprevious(0, 0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_lfirst() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lfirst(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_llast() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_llast(0)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_ll() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_ll(0, 1)
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_lopen() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lopen()
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'loclist', 1)
endfunction

function! s:suite.test_context_lclose() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lclose()
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:set_qf_context_hook_with_idx(idx) abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
    \ })
  call setqflist([], 'a', {
    \ 'idx': a:idx,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:set_loc_context_hook_with_idx(idx) abort
  call s:reset_vars()
  call setloclist(0, [], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
    \ })
  call setloclist(0, [], 'a', {
    \ 'idx': a:idx,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': function('IncrementHookedCount'),
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:suite.test_qf_cnext_wrap_around() abort
  call s:set_qf_context_hook_with_idx(len(s:list_items))
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 1)
endfunction

function! s:suite.test_qf_cnext_wrap_around_with_count() abort
  call s:set_qf_context_hook_with_idx(len(s:list_items))
  call qfhooks#command#qf_hooks_cnext(0, 3)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 3)
endfunction

function! s:suite.test_qf_cnext_wrap_around_with_count_over_size() abort
  call s:set_qf_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_cnext(0, len(s:list_items) * 2 + 1)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:suite.test_qf_cprevious_wrap_around() abort
  call s:set_qf_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_cprevious(0, 0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), len(s:list_items))
endfunction

function! s:suite.test_qf_cprevious_wrap_around_with_count_over_size() abort
  call s:set_qf_context_hook_with_idx(2)
  call qfhooks#command#qf_hooks_cprevious(0, len(s:list_items) * 2 + 1)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 1)
endfunction

function! s:suite.test_qf_cnext_with_zero_count() abort
  call s:set_qf_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 2)
endfunction

function! s:suite.test_qf_clast_from_first() abort
  call s:set_qf_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_clast(0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), len(s:list_items))
endfunction

function! s:suite.test_loc_lnext_wrap_around() abort
  call s:set_loc_context_hook_with_idx(len(s:list_items))
  call qfhooks#command#qf_hooks_lnext(0, 0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_loc_list_idx(), 1)
endfunction

function! s:suite.test_loc_lprevious_wrap_around() abort
  call s:set_loc_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_lprevious(0, 0)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_loc_list_idx(), len(s:list_items))
endfunction

function! s:suite.test_loc_lnext_wrap_around_with_count() abort
  call s:set_loc_context_hook_with_idx(len(s:list_items)-1)
  call qfhooks#command#qf_hooks_lnext(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_loc_list_idx(), 1)
endfunction

function! s:suite.test_loc_lprevious_wrap_around_with_count() abort
  call s:set_loc_context_hook_with_idx(2)
  call qfhooks#command#qf_hooks_lprevious(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_loc_list_idx(), len(s:list_items))
endfunction

function! s:suite.test_context_lwindow() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lwindow()
  call s:assert.equal(g:hooked_count, 1)
endfunction

function! s:suite.test_context_lopen_with_height() abort
  call s:set_loc_context_hook()
  call qfhooks#command#qf_hooks_lopen(5)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(win_gettype() ==# 'loclist', 1)
  call s:assert.equal(winheight(bufwinnr(bufnr('$'))), 5)
endfunction

function! s:suite.test_qf_cnext_with_count() abort
  call s:set_qf_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_cnext(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 3)
endfunction

function! s:suite.test_loc_lnext_with_count() abort
  call s:set_loc_context_hook_with_idx(1)
  call qfhooks#command#qf_hooks_lnext(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_loc_list_idx(), 3)
endfunction

function! s:suite.test_qf_cnext_wrap_around_with_count() abort
  call s:set_qf_context_hook_with_idx(len(s:list_items)-1)
  call qfhooks#command#qf_hooks_cnext(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), 1)
endfunction

function! s:suite.test_qf_cprevious_wrap_around_with_count() abort
  call s:set_qf_context_hook_with_idx(2)
  call qfhooks#command#qf_hooks_cprevious(0, 2)
  call s:assert.equal(g:hooked_count, 1)
  call s:assert.equal(s:get_qf_list_idx(), len(s:list_items))
endfunction

function! s:set_qf_context_hook_invalid_hook_function() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \    'hook': 'NonExistentHook',
    \    'cmds': g:qfhooks_cmds,
    \   }],
    \ }
endfunction

function! s:suite.test_context_hook_invalid_hook() abort
  call s:set_qf_context_hook_invalid_hook_function()
  try
    call qfhooks#command#qf_hooks_cnext(0, 0)
  catch /^Vim\%((\a\+)\)\=:E492/
    call s:assert.true(1)
  endtry
endfunction

function! s:set_qf_command_hook() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'command_hook'},
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'command_hook': [{
    \   'hook': 'call AppendA()',
    \   'cmds': g:qfhooks_cmds,
    \ }],
    \ }
endfunction

function! s:suite.test_command_hook_cnext() abort
  call s:set_qf_command_hook()
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_list, ['A'])
endfunction

function! AppendA() abort
  call add(g:hooked_list, 'A')
endfunction

function! AppendB() abort
  call add(g:hooked_list, 'B')
endfunction

function! AppendC() abort
  call add(g:hooked_list, 'C')
endfunction

function! AppendD() abort
  call add(g:hooked_list, 'D')
endfunction

function! s:set_qf_hook_with_priority() abort
  call s:reset_vars()
  call setqflist([], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'title': 'title_pattern_test',
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \   'priority': 2,
    \   'hook': function('AppendA')
    \ },
    \ {
    \   'priority': 4,
    \   'hook': function('AppendD')
    \ }
    \ ]}
  let g:qfhooks_title_hooks = {
    \ '^title_pattern.*': [{
    \   'priority': 1,
    \   'hook': function('AppendB')
    \ },
    \ {
    \   'priority': 3,
    \   'hook': function('AppendC')
    \ }
    \ ]}
endfunction

function! s:suite.set_qf_hooks_with_priority() abort
  call s:reset_vars()
  call s:set_qf_hook_with_priority()
  call qfhooks#command#qf_hooks_cnext(0, 0)
  call s:assert.equal(g:hooked_list, ['B', 'A', 'C', 'D'])
endfunction

function! s:set_loc_hook_with_priority() abort
  call s:reset_vars()
  call setloclist(0, [], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'title': 'title_pattern_test',
    \ 'items': s:list_items,
    \ })
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \   'priority': 2,
    \   'hook': function('AppendA')
    \ },
    \ {
    \   'priority': 4,
    \   'hook': function('AppendD')
    \ }
    \ ]}
  let g:qfhooks_title_hooks = {
    \ '^title_pattern.*': [{
    \   'priority': 1,
    \   'hook': function('AppendB')
    \ },
    \ {
    \   'priority': 3,
    \   'hook': function('AppendC')
    \ }
    \ ]}
endfunction

function! s:suite.test_loc_priority_hook_order() abort
  call s:reset_vars()
  call s:set_loc_hook_with_priority()
  call qfhooks#command#qf_hooks_ll(0, 1)
  call s:assert.equal(g:hooked_list, ['B', 'A', 'C', 'D'])
endfunction


function! s:set_loc_hook_with_default_priority() abort
  call s:reset_vars()
  call setloclist(0, [], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'title': 'title_pattern_test',
    \ 'items': s:list_items,
    \ })

  let g:default_priority = 10
  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \   'hook': function('AppendA')
    \ },
    \ {
    \   'priority': 4,
    \   'hook': function('AppendD')
    \ }
    \ ]}
  let g:qfhooks_title_hooks = {
    \ '^title_pattern.*': [{
    \   'priority': 1,
    \   'hook': function('AppendB')
    \ },
    \ {
    \   'priority': 3,
    \   'hook': function('AppendC')
    \ }
    \ ]}
endfunction

function! s:suite.test_loc_with_default_priority() abort
  call s:reset_vars()
  call s:set_loc_hook_with_default_priority()
  call qfhooks#command#qf_hooks_ll(0, 1)
  call s:assert.equal(g:hooked_list, ['B', 'C', 'D', 'A'])
endfunction

function! s:set_loc_hook_with_same_priority() abort
  call s:reset_vars()
  call setloclist(0, [], 'r', {
    \ 'context': {g:qfhooks_context_hook_key : 'context_hook'},
    \ 'title': 'title_pattern_test',
    \ 'items': s:list_items,
    \ })

  let g:qfhooks_context_hooks = {
    \ 'context_hook': [{
    \   'priority': 2,
    \   'hook': function('AppendA')
    \ },
    \ {
    \   'priority': 2,
    \   'hook': function('AppendD')
    \ }
    \ ]}
  let g:qfhooks_title_hooks = {
    \ '^title_pattern.*': [{
    \   'priority': 1,
    \   'hook': function('AppendB')
    \ },
    \ {
    \   'priority': 1,
    \   'hook': function('AppendC')
    \ }
    \ ]}
endfunction

function! s:suite.test_loc_with_same_priority() abort
  call s:reset_vars()
  call s:set_loc_hook_with_same_priority()
  call qfhooks#command#qf_hooks_ll(0, 1)
  call s:assert.equal(g:hooked_list, ['B', 'C', 'A', 'D'])
endfunction

function! s:suite.test_get_cmd_name() abort
  let test_cases = [
    \ ['cc 2', 'cc'],
    \ ['cc!', 'cc'],
    \ ['3cc', 'cc'],
    \ ['cc1', 'cc'],
    \ ['cc', 'cc'],
    \ ['cc! 4', 'cc'],
    \ ['5cc!', 'cc'],
    \ ['cnext1', 'cnext'],
    \ ['2cnext', 'cnext'],
    \ ['cnext!', 'cnext'],
    \ ['cnext 3', 'cnext'],
    \ ]
  for [input_cmd, expected_output] in test_cases
    let actual_output = qfhooks#get_cmd_name(input_cmd)
    call s:assert.equal(actual_output, expected_output, 'Failed' . input_cmd)
  endfor
endfunction
