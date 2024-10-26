function! qfhooks#command#qf_hooks_cnext(bang) abort
  call qfhooks#cnext(a:bang)
endfunction

function! qfhooks#command#qf_hooks_cprevious(bang) abort
  call qfhooks#cprevious(a:bang)
endfunction

function! qfhooks#command#qf_hooks_cc(bang, ...) abort
  call qfhooks#cc(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_cfirst(bang, ...) abort
  call qfhooks#cfirst(a:bang, join(a:000))
endfunction

function! qfhooks#command#qf_hooks_clast(bang, ...) abort
  call qfhooks#clast(a:bang, join(a:000))
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
