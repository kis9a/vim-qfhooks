# vim-qfhooks

Enhance your Quickfix and Location List commands in Vim with custom hooks.

This plugin allows you to define functions or commands to be executed at specific stages of Quickfix or Location List actions, giving you fine-grained control over their behavior.

## Installation

Install the plugin using your preferred plugin manager.

Example with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'kis9a/vim-qfhooks'
```

## Configuration

### Example Mappings

Add the following key mappings to your `.vimrc` to navigate Quickfix and Location Lists efficiently:

```vim
" Quickfix navigation
nnoremap <silent> qj <Plug>(QFHooksCnext)
nnoremap <silent> qk <Plug>(QFHooksCprevious)
nnoremap <silent> qf :QFHooksCfirst<CR>
nnoremap <silent> ql :QFHooksClast<CR>

" Location List navigation
nnoremap <silent> <C-g>j <Plug>(QFHooksLnext)
nnoremap <silent> <C-g>k <Plug>(QFHooksLprevious)
nnoremap <silent> <C-g>f :QFHooksLfirst<CR>
nnoremap <silent> <C-g>l :QFHooksLlast<CR>

" Conditional mapping based on list type
autocmd FileType qf nnoremap <buffer> <silent> <C-M> :execute getwininfo(win_getid())[0].loclist ? 'QFHooksLl' : 'QFHooksCc'<CR>
```

## Commands

### Quickfix Commands

| Command                    | Description                                    |
| -------------------------- | ---------------------------------------------- |
| `[nr]QFHooksCnext[!]`      | Go to the next Quickfix item or wrap to first. |
| `[nr]QFHooksCprevious[!]`  | Go to the previous item or wrap to last.       |
| `QFHooksCc[!][nr]`         | Jump to the specified Quickfix entry.          |
| `QFHooksCfirst[!][nr]`     | Go to the first Quickfix entry.                |
| `QFHooksClast[!][nr]`      | Go to the last Quickfix entry.                 |
| `QFHooksCopen[height]`     | Open the Quickfix window.                      |
| `QFHooksCwindow[height]`   | Open the Quickfix window if items exist.       |
| `QFHooksCclose`            | Close the Quickfix window.                     |

### Location List Commands

| Command                     | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `[nr]QFHooksLnext[!]`       | Go to the next Location List item or wrap to first. |
| `[nr]QFHooksLprevious[!]`   | Go to the previous item or wrap to last.            |
| `QFHooksLl[!][nr]`          | Jump to the specified Location List entry.          |
| `QFHooksLfirst[!][nr]`      | Go to the first Location List entry.                |
| `QFHooksLlast[!][nr]`       | Go to the last Location List entry.                 |
| `QFHooksLopen[height]`      | Open the Location List window.                      |
| `QFHooksLwindow[height]`    | Open the Location List window if items exist.       |
| `QFHooksLclose`             | Close the Location List window.                     |

## Hooks System

- **Context-Based Hooks**: Define hooks based on specific contexts or keys within the Quickfix or Location List.
- **Title-Based Hooks**: Execute hooks based on the titles of Quickfix or Location List windows.
- **Execution Stages**: Trigger hooks **before** and/or **after** specific commands.
- **Priority**: Set priorities to control the order in which multiple hooks are executed.
- **Command-Specific Hooks**: Assign hooks to commands like `cnext`, `cprevious`, `copen`, `cclose`, `lnext`, `lprevious`, etc.
- **Customizable Hooks**: Attach custom functions or commands to Quickfix and Location List events.

### Example Usage

Add the following to your `.vimrc` to define custom hooks:

```vim
let g:qfhooks_context_hooks = {
  \ 'context_smile': [
  \   {
  \     'cmds': ['copen'],
  \     'stage': 'after',
  \     'hook': 'echo "Quickfix window opened!"'
  \   },
  \   {
  \     'cmds': ['cc'],
  \     'hook': 'smile'
  \   }
  \ ],
\ }
```

Then, run the following command and press `<Enter>` or execute `:QFHooksCc`:

```vim
call setqflist([], 'r', { 'context': { 'qfhooks': 'context_smile' }, 'items': [{ 'lnum': 0, 'text': 'smile' }] }) | QFHooksCopen
```

## Example Hooks

### Code Review Automation

Enhance your code review process by automating diff viewing between branches.

<image width="720px" src="https://github.com/user-attachments/assets/981d3cd3-8551-4247-a612-66b21a5a3338"></image>

<details close>
<summary>Add the following hook configuration to your `.vimrc`</summary>
<br/>

When reviewing pull requests, I sought an efficient way to manage the differences between the current branch and the base branch. Previously, I tried methods like using vim-fugitive to display git status and diffs with `:Git` and `:Gvdiffsplit`, opening diffs in tabs with commands like `vim -p 'tabdo Gdiff ...'`, and defining `autocmd QuickFixCmdPre/QuickFixCmdPost` for quickfix commands. However, these approaches had several issues:

- **vim-fugitive**: Navigating between files was cumbersome, requiring a return to the fugitive window and repeating commands for each file. Additionally, `:Gstatus` (now superseded by `:Git` without arguments) doesn't allow specifying arguments to display diffs against the base branch.
- **Using Tabs**: Managing multiple tabs became difficult, and executing `:Gvdiffsplit` for all buffers on startup significantly increased Vim's loading time.
- **Using autocmd**: The configuration became complex and hard to manage, with potential performance degradation due to multiple `autocmd` executions. Limiting the scope of `autocmd` was also challenging, especially when `:Gvdiffsplit` wasn't always desired.

To overcome these problems, I created **vim-qfhooks**. This plugin displays the output of `git diff --name-status $(git merge-base HEAD base-branch)` in the quickfix list and executes predefined custom hooks through wrapped commands provided by the plugin. By defining functions that execute commands like `:Gvdiffsplit` as hooks, you can flexibly set the timing and conditions for their execution. This approach allows you to leverage the powerful features of the quickfix list fully. For example, using the [vim-qf](https://github.com/romainl/vim-qf) plugin, you can further filter diff files with commands like `:Keep` and `:Reject`. Moreover, you can navigate between files using `cnext` and `cprevious` without opening the quickfix window, eliminating the need to switch back to the quickfix window to move to the next diff file, thereby enhancing usability.

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
        call add(l:items, { 'filename': l:filename, 'lnum': 0, 'text': 'S:' . l:status, 'valid': 1 })
      endif
    endif
  endfor
  if empty(l:items)
    echo 'No files found in diff for base: ' . g:review_base
    return
  endif
  call setqflist([], 'r', {
    \ 'context': { g:qfhooks_context_hook_key : 'base_diff_view'},
    \ 'items': l:items,
    \ })
  silent! execute 'QFHooksCopen'
endfunction

function! HandleNextDiff()
  let l:current_bufnr = bufnr('%')
  for l:win in getwininfo()
    if l:win.tabnr == tabpagenr() && l:win.bufnr != l:current_bufnr && l:win.quickfix == 0
      execute 'bdelete' l:win.bufnr
    endif
  endfor
  silent! execute 'Gvdiffsplit ' . g:review_base | wincmd h
endfunction

let g:qfhooks_context_hooks = {
  \ 'base_diff_view': [
  \   {
  \     'hook': function('HandleNextDiff'),
  \     'stage': 'after',
  \     'cmds': ['cprevious', 'cnext', 'cc', 'cfirst', 'clast'],
  \   },
  \   {
  \     'hook': 'QFHooksCc',
  \     'stage': 'after',
  \     'cmds': ['copen'],
  \   }
  \ ]
\ }

command! -nargs=? DiffView call s:openBaseDiffQf(<q-args>)
```

</details>

### Yank History

Display and manage your yank history using the Quickfix list, allowing you to reuse previous yanks effortlessly.

<details>
<summary>Add the following hook configuration to your `.vimrc`</summary>

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
    call add(l:items, { 'lnum': l:idx, 'text': l:yank['text'] })
    let l:idx += 1
  endfor
  if empty(l:items)
    echo 'No yanks in history'
    return
  endif

  if a:open
    if empty(l:context) || get(l:context, g:qfhooks_context_hook_key, '') !=# 'yank_history'
      call setqflist([])
    endif
  endif

  call setqflist([], 'r', {
    \ 'title': 'yank_history',
    \ 'context': { g:qfhooks_context_hook_key: 'yank_history' },
    \ 'items': l:items,
    \ })

  if a:open
    silent! execute 'QFHooksCopen'
  endif
endfunction

function! s:yankPrevious()
  let l:yanks = yoink#getYankHistory()
  if empty(l:yanks)
    echo 'No yanks in history'
    return
  endif
  let l:yanked = l:yanks[1]['text']
  call yoink#manualYank(l:yanked)
  let l:line = substitute(l:yanked, '\n', '\\n', 'g')
  if len(l:line) > 60
    let l:line = l:line[:60] . '...'
  endif
  echo l:line
endfunction

function! HandleBeforeOpenYank()
  if &filetype ==# 'qf'
    if exists('g:pos_before_yank_qf_open')
      unlet g:pos_before_yank_qf_open
    endif
  else
    let g:pos_before_yank_qf_open = getpos('.')
  endif
endfunction

function! HandleAfterOpenYank()
  let l:qf_info = getqflist({'idx': 0, 'items': 1})
  let l:idx = l:qf_info['idx']
  let l:qflist = l:qf_info['items']
  if empty(l:qflist)
    echo 'Quickfix list is empty'
    return
  endif

  let l:yanked = l:qflist[l:idx - 1]['text']
  let @+ = l:yanked
  if &filetype ==# 'qf'
    cclose
  else
    if exists('g:pos_before_yank_qf_open')
      let [_, l:lnum, l:col, _] = g:pos_before_yank_qf_open
      call cursor(l:lnum, l:col)
    endif
  endif
endfunction

let g:qfhooks_context_hooks = {
  \ 'yank_history': [
  \   {
  \     'hook': function('HandleBeforeOpenYank'),
  \     'stage': 'before',
  \   },
  \   {
  \     'hook': function('HandleAfterOpenYank'),
  \     'stage': 'after',
  \   }
  \ ]
\ }

command! YankHistoryQf call s:yankHistoryQf(v:true)
command! YankPrevious call s:yankPrevious()

nnoremap <silent> sy :YankHistoryQf<CR>
nnoremap <silent> yp :YankPrevious<CR>

augroup yoink
  autocmd!
  autocmd TextYankPost * call yoink#onYank(copy(v:event)) | call s:yankHistoryQf()
  autocmd VimEnter * call yoink#onVimEnter()
augroup END
```

</details>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
