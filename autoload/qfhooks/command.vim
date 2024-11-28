function! qfhooks#command#qf_hooks_cnext(bang, count) abort
  call qfhooks#cnext(a:bang, a:count)
endfunction

function! qfhooks#command#qf_hooks_cprevious(bang, count) abort
  call qfhooks#cprevious(a:bang, a:count)
endfunction

function! qfhooks#command#qf_hooks_cfirst(bang, ...) abort
  call qfhooks#cfirst(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_clast(bang, ...) abort
  call qfhooks#clast(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_cc(bang, ...) abort
  call qfhooks#cc(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_copen(...) abort
  call qfhooks#copen(join(a:000))
endfunction

function! qfhooks#command#qf_hooks_cwindow(...) abort
  call qfhooks#cwindow(join(a:000))
endfunction

function! qfhooks#command#qf_hooks_cclose() abort
  call qfhooks#cclose()
endfunction

function! qfhooks#command#qf_hooks_lnext(bang, count) abort
  call qfhooks#lnext(a:bang, a:count)
endfunction

function! qfhooks#command#qf_hooks_lprevious(bang, count) abort
  call qfhooks#lprevious(a:bang, a:count)
endfunction

function! qfhooks#command#qf_hooks_lfirst(bang, ...) abort
  call qfhooks#lfirst(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_llast(bang, ...) abort
  call qfhooks#llast(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_ll(bang, ...) abort
  call qfhooks#ll(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_lopen(...) abort
  call qfhooks#lopen(join(a:000))
endfunction

function! qfhooks#command#qf_hooks_lwindow(...) abort
  call qfhooks#lwindow(join(a:000))
endfunction

function! qfhooks#command#qf_hooks_lclose() abort
  call qfhooks#lclose()
endfunction
