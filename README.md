# vim-qfhooks

## Features

- **Extendable Commands**: Adds custom logic around common Quickfix commands (`cnext`, `cprevious`, `cc`, `clast`, etc.).
- **Hooks System**: Execute custom functions **before** or **after** command execution.
- **Context and Title Hooks**: Trigger actions based on the Quickfix context or title patterns.

## Installation

Use your favorite plugin manager.

- Example: [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'kis9a/vim-qfhooks'
```

## Usage

The plugin wraps around native Quickfix commands. Use the enhanced commands the same way, with optional **bang** (`!`) to modify behavior:

| Command                   | Description                                    |
| ------------------------  | ---------------------------------------------- |
| `:QFHooksCnext[!]`        | Go to the next Quickfix item or wrap to first. |
| `:QFHooksCprevious[!]`    | Go to the previous item or wrap to last.       |
| `:QFHooksCc[!][nr]`       | Jump to the given Quickfix entry.              |
| `:QFHooksCfirst[!][nr]`   | Go to the first Quickfix entry.                |
| `:QFHooksClast[!][nr]`    | Go to the last Quickfix entry.                 |
| `:QFHooksCopen[height]`   | Open the Quickfix window.                      |
| `:QFHooksCwindow[height]` | Open Quickfix window if items exist.           |
| `:QFHooksCclose`          | Close the Quickfix window.                     |

## Configuration

### Example mappings

```vim
nnoremap <silent> qj :QFHooksCnext<CR>
nnoremap <silent> qk :QFHooksCprevious<CR>
nnoremap <silent> qf :QFHooksCfirst<CR>
nnoremap <silent> ql :QFHooksClast<CR>
autocmd FileType qf nnoremap <silent> <C-M> :QFHooksCc <C-R>=line('.')<CR><CR>
```

### Example hooks

#### Review PR

When reviewing pull requests, I sought an efficient way to manage the differences between the current branch and the base branch. Previously, I tried methods like using vim-fugitive to display git status and diffs with `:Git` and `:Gvdiffsplit`, opening diffs in tabs with commands like `vim -p 'tabdo Gdiff ...'`, and defining `autocmd QuickFixCmdPre/QuickFixCmdPost` for quickfix commands. However, these approaches had several issues:

- **vim-fugitive**: Navigating between files was cumbersome, requiring a return to the fugitive window and repeating commands for each file. Additionally, `:Gstatus` (now superseded by `:Git` without arguments) doesn't allow specifying arguments to display diffs against the base branch.
- **Using Tabs**: Managing multiple tabs became difficult, and executing `:Gvdiffsplit` for all buffers on startup significantly increased Vim's loading time. [Code Review from the Command Line](https://blog.jez.io/cli-code-review/)
- **Using autocmd**: The configuration became complex and hard to manage, with potential performance degradation due to multiple `autocmd` executions. Limiting the scope of `autocmd` was also challenging, especially when `:Gvdiffsplit` wasn't always desired.

To overcome these problems, I created **vim-qfhooks**. This plugin displays the output of `git diff --name-status $(git merge-base HEAD base-branch)` in the quickfix list and executes predefined custom hooks through wrapped commands provided by the plugin. By defining functions that execute commands like `:Gvdiffsplit` as hooks, you can flexibly set the timing and conditions for their execution. This approach allows you to leverage the powerful features of the quickfix list fully. For example, using the [vim-qf](https://github.com/romainl/vim-qf) plugin, you can further filter diff files with commands like `:Keep` and `:Reject`. Moreover, you can navigate between files using `cnext` and `cprevious` without opening the quickfix window, eliminating the need to switch back to the quickfix window to move to the next diff file, thereby enhancing usability.

Add the following hook configuration to your `.vimrc`:

```vim
function! s:openBaseDiffQf(base)
  let g:review_base = a:base !=# '' ? a:base : 'origin/main'
  let l:diff_files = systemlist('git diff --name-status $(git merge-base HEAD ' . g:review_base . ')')
  let l:items = []
  for l:file in l:diff_files
    if !empty(l:file)
      let parts = split(l:file, '\t\+', 1)
      if len(parts) == 2
        let [l:status, l:filename] = parts
        call add(l:items, {'filename': l:filename, 'lnum': 1, 'text': 'S:' . l:status})
      endif
    endif
  endfor
  if empty(l:items) | echo 'No files found in diff for base: ' . g:review_base | return | endif
  call setqflist([], 'r', {
    \ 'title': 'review_pr: base' . g:review_base,
    \ 'context': {g:qfhooks_context_hook_key : 'review_pr'},
    \ 'items': l:items,
    \ })
  silent! execute 'QFHooksCopen'
endfunction

function! HandleOpenBaseDiff()
  silent! cc
  silent! execute 'Gvdiffsplit ' . g:review_base
  silent! wincmd h
endfunction

function! HandleNextBaseDiff()
  let l:current_bufnr = bufnr('%')
  for l:win in getwininfo()
    if l:win.tabnr == tabpagenr() && l:win.bufnr != l:current_bufnr && l:win.quickfix == 0
      execute 'bdelete' l:win.bufnr
    endif
  endfor
  silent! execute 'Gvdiffsplit ' . g:review_base
  silent! wincmd h
endfunction

let g:qfhooks_context_hooks = {
  \ 'review_pr': [{
  \    'hook': function('HandleNextBaseDiff'),
  \    'stage': 'after',
  \    'cmds': ['cprevious', 'cnext', 'cc'],
  \   },
  \   {
  \    'hook': function('HandleOpenBaseDiff'),
  \    'stage': 'after',
  \    'cmds': ['copen'],
  \   }],
  \ }

command! -nargs=? ReviewPR call s:openBaseDiffQf(<q-args>)
```

### Yank history

By integrating with plugins like vim-yoink, you can display your yank history in the Quickfix list and use custom hooks to select and reuse previous yanks effortlessly.

```vim
" Plug 'kis9a/vim-yoink'

function! s:yankHistoryQf(open = v:false)
  let l:qf_list = getqflist()
  let l:qf_info = getqflist({'all': 0})
  let l:context = type(l:qf_info['context']) == type({}) ? l:qf_info['context'] : {}
  if !a:open && (!empty(l:qf_list) && (empty(l:context) || get(l:context, g:qfhooks_context_hook_key, '') !=# 'yank_history'))
    return
  endif

  let l:items = []
  let l:idx = 1
  for l:yank in yoink#getYankHistory()
    call add(l:items, {'lnum': l:idx, 'text': l:yank['text']})
    let l:idx += 1
  endfor
  if empty(items) | echo 'No yanks in history' | return | endif

  if a:open
    if empty(l:context) || get(l:context, g:qfhooks_context_hook_key, '') !=# 'yank_history'
      call setqflist([])
    endif
  endif

  call setqflist([], 'r', {
    \ 'title': 'yank_history',
    \ 'context': {g:qfhooks_context_hook_key : 'yank_history'},
    \ 'items': l:items,
    \ })

  if a:open | silent! execute 'QFHooksCopen' | endif
endfunction

function! s:yankPrevious()
  let l:yanks = yoink#getYankHistory()
  if empty(l:yanks) | echo 'No yanks in history' | return | endif
  if len(l:yanks) < 1 | return | endif
  let l:yanked = l:yanks[1]['text']
  call yoink#manualYank(l:yanked)
  let l:line = substitute(l:yanked, '\n', '\\n', 'g')
  if len(l:line) > 60 | let l:line = line[: 60] . '...' | endif
  echo l:line
endfunction

function! HandleBeforeOpenYank()
  if &filetype ==# 'qf'
    if exists('g:pos_before_yanekd_qf_open')
      unlet g:pos_before_yanekd_qf_open
    endif
  else
    let g:pos_before_yanekd_qf_open = getpos('.')
  endif
endfunction

function! HandleAfterOpenYank()
  let l:qf_info = getqflist({'idx': 0, 'items': 1})
  let l:idx = l:qf_info['idx']
  let l:qflist = l:qf_info['items']
  if empty(l:qflist) | echo "Quickfix list is empty" | return | endif

  let l:yanked = l:qflist[l:idx-1]['text']
  let @+ = l:yanked
  if &filetype ==# 'qf' |
    cclose
  else
    if exists('g:pos_before_yanekd_qf_open')
      let [_, l:lnum, l:col, _] = g:pos_before_yanekd_qf_open
      call cursor(l:lnum, l:col)
    endif
  endif
endfunction

let g:qfhooks_context_hooks = {
  \ 'yank_history': [{
  \    'hook': function('HandleBeforeOpenYank'),
  \    'stage': 'before',
  \   },
  \   {
  \    'hook': function('HandleAfterOpenYank'),
  \    'stage': 'after',
  \   }],
  \ }

command! YankHistoryQf call s:yankHistoryQf(v:true)
command! YankPrevious call s:yankPrevious()

nnoremap <silent> sy :YankHistoryQf<CR>
nnoremap <silent> yp :YankPrevious<CR>

augroup yoink
  au!
  autocmd TextYankPost * call yoink#onYank(copy(v:event)) | call s:yankHistoryQf()
  autocmd VimEnter * call yoink#onVimEnter()
augroup END
```

## Hooks System

Hooks are triggered **before** or **after** commands run. You can create both **context-based** and **title-based** hooks:

- **Context Hooks**: Triggered by Quickfix context.
- **Title Hooks**: Triggered by matching the Quickfix list title.

### Examples of hook variables

```vim
let g:qfhooks_default_cmds = ['cnext', 'cprevious', 'cc', 'cfirst', 'clast']

let g:qfhooks_context_hooks = {
\ 'context': [{
\   'stage': 'after',
\   'cmds': ['cc', 'cnext', 'cprevious'],
\   'hook': function('HandleFunc')
\ }]}

let g:qfhooks_title_hooks = {
\ '^title_pattern.*': [{
\   'stage': 'before',
\   'cmds': ['cnext', 'cprevious', 'cc', 'cfirst', 'clast', 'copen', 'cwindow', 'cclose'],
\   'hook': function('HandleFunc')
\ }]}
```

## Error Handling

The plugin captures common errors like:
- **E553**: Wraps to fallback commands (`cfirst` or `clast`).
- **E42**: Calls the user-defined error function when no items are present.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
