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
function s:reviewPR(base)
  let g:review_base = a:base !=# '' ? a:base : 'origin/main'
  let diff_files = systemlist('git diff --name-status $(git merge-base HEAD ' . g:review_base . ')')
  let items = []
  for file in diff_files
    if !empty(file)
      let parts = split(file, '\t\+', 1)
      if len(parts) == 2
        let [status, filename] = parts
        call add(items, {'filename': filename, 'lnum': 1, 'text': 'S:' . status})
      endif
    endif
  endfor
  if empty(items)
    echo 'No files found in diff for base: ' . g:review_base
    return
  endif
  call setqflist([], 'r', {
        \ 'title': 'review_pr: base' . g:review_base,
        \ 'context': {g:qfhooks_context_hook_key : 'review_pr'},
        \ 'items': items,
        \ })
  silent! execute 'QFHooksCopen'
endfunction

function HandleOpenDiff()
  silent! cc
  silent! execute 'Gvdiffsplit ' . g:review_base
  silent! wincmd h
endfunction

function HandleNextDiff()
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
  \    'hook': function('HandleNextDiff'),
  \    'stage': 'after',
  \    'cmds': ['cprevious', 'cnext', 'cc'],
  \   },
  \   {
  \    'hook': function('HandleOpenDiff'),
  \    'stage': 'after',
  \    'cmds': ['copen'],
  \   }],
  \ }

command! -nargs=? ReviewPR call s:reviewPR(<q-args>)
```

## Hooks System

Hooks are triggered **before** or **after** commands run. You can create both **context-based** and **title-based** hooks:

- **Context Hooks**: Triggered by Quickfix context.
- **Title Hooks**: Triggered by matching the Quickfix list title.

### Examples of hook variables

```vim
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
