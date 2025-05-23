" Author: w0rp <devw0rp@gmail.com>
" Description: Main entry point for the plugin: sets up prefs and autocommands
"   Preferences can be set in vimrc files and so on to configure ale

" Sanity Checks

if exists('g:loaded_ale_dont_use_this_in_other_plugins_please')
    finish
endif

" Set a special flag used only by this plugin for preventing doubly
" loading the script.
let g:loaded_ale_dont_use_this_in_other_plugins_please = 1

" A flag for detecting if the required features are set.
if has('nvim')
    " We check for Neovim 0.2.0+, but we only officially support NeoVim 0.7.0
    let s:has_features = has('timers') && has('nvim-0.2.0')
else
    " Check if Job and Channel functions are available, instead of the
    " features. This works better on old MacVim versions.
    let s:has_features = has('timers') && exists('*job_start') && exists('*ch_close_in')
endif

if !s:has_features
    " Only output a warning if editing some special files.
    if index(['', 'gitcommit'], &filetype) == -1
        " no-custom-checks
        echoerr 'ALE requires NeoVim >= 0.7.0 or Vim 8 with +timers +job +channel'
        " no-custom-checks
        echoerr 'Please update your editor appropriately.'
    endif

    " Stop here, as it won't work.
    finish
endif

" Set this flag so that other plugins can use it, like airline.
let g:loaded_ale = 1

" This global variable is used internally by ALE for tracking information for
" each buffer which linters are being run against.
let g:ale_buffer_info = {}
" This global Dictionary tracks data for fixing code. Don't mess with it.
let g:ale_fix_buffer_data = {}

" User Configuration

" This option prevents ALE autocmd commands from being run for particular
" filetypes which can cause issues.
let g:ale_filetype_blacklist = [
\   'dirvish',
\   'nerdtree',
\   'qf',
\   'tags',
\   'unite',
\]

" This Dictionary configures which linters are enabled for which languages.
let g:ale_linters = get(g:, 'ale_linters', {})
" This option can be changed to only enable explicitly selected linters.
let g:ale_linters_explicit = get(g:, 'ale_linters_explicit', v:false)
" Ignoring linters, for disabling some, or ignoring LSP diagnostics.
let g:ale_linters_ignore = get(g:, 'ale_linters_ignore', {})
" Disabling all language server functionality.
let g:ale_disable_lsp = get(g:, 'ale_disable_lsp', 'auto')

" This Dictionary configures which functions will be used for fixing problems.
let g:ale_fixers = get(g:, 'ale_fixers', {})

" This Dictionary allows users to set up filetype aliases for new filetypes.
let g:ale_linter_aliases = get(g:, 'ale_linter_aliases', {})

" This flag can be set with a number of milliseconds for delaying the
" execution of a linter when text is changed. The timeout will be set and
" cleared each time text is changed, so repeated edits won't trigger the
" jobs for linting until enough time has passed after editing is done.
let g:ale_lint_delay = get(g:, 'ale_lint_delay', 200)

" This flag can be set to 'never' to disable linting when text is changed.
" This flag can also be set to 'always' or 'insert' to lint when text is
" changed in both normal and insert mode, or only in insert mode respectively.
let g:ale_lint_on_text_changed = get(g:, 'ale_lint_on_text_changed', 'normal')

" This flag can be set to true or 1 to enable linting when leaving insert mode.
let g:ale_lint_on_insert_leave = get(g:, 'ale_lint_on_insert_leave', v:true)

" When true or 1 linting is done when a buffer is entered.
let g:ale_lint_on_enter = get(g:, 'ale_lint_on_enter', v:true)

" When true or 1 linting is done when a buffer is written.
let g:ale_lint_on_save = get(g:, 'ale_lint_on_save', v:true)

" When true or 1 linting is done when the filetype changes.
let g:ale_lint_on_filetype_changed = get(g:, 'ale_lint_on_filetype_changed', v:true)

" If set to true or 1, suggestions from LSP servers and tsserver will be shown.
let g:ale_lsp_suggestions = get(g:, 'ale_lsp_suggestions', v:false)

" When true or 1 files are automatically fixed on save.
let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', v:false)

" When true or 1 ALE linting is enabled.
" Disabling ALE linting does not disable fixing of files.
let g:ale_enabled = get(g:, 'ale_enabled', 1)

" A Dictionary mapping linter or fixer names to Arrays of two-item Arrays
" mapping filename paths from one system to another.
let g:ale_filename_mappings = get(g:, 'ale_filename_mappings', {})

" This Dictionary configures the default project roots for various linters.
let g:ale_root = get(g:, 'ale_root', {})

" These flags dictates if ale uses the quickfix or the loclist (loclist is the
" default, quickfix overrides loclist).
let g:ale_set_loclist = get(g:, 'ale_set_loclist', v:true)
let g:ale_set_quickfix = get(g:, 'ale_set_quickfix', v:false)

" This flag can be set to 0 to disable setting signs.
" This is enabled by default only if the 'signs' feature exists.
let g:ale_set_signs = get(g:, 'ale_set_signs', has('signs') ? v:true : v:false)

" This flag can be set to 0 to disable setting error highlights.
let g:ale_set_highlights = get(g:, 'ale_set_highlights', has('syntax') ? v:true : v:false)

" This List can be configured to exclude particular highlights.
let g:ale_exclude_highlights = get(g:, 'ale_exclude_highlights', [])

" When set to true or 1 problems on lines are echoed when the cursor moves.
let g:ale_echo_cursor = get(g:, 'ale_echo_cursor', v:true)

" If set to true or 1 automatically show errors in the preview window.
let g:ale_cursor_detail = get(g:, 'ale_cursor_detail', v:false)

" This flag can be changed to disable/enable virtual text.
let g:ale_virtualtext_cursor = get(g:, 'ale_virtualtext_cursor', (has('nvim-0.3.2') || has('patch-9.0.0297') && has('textprop') && has('popupwin')) ? 'all' : 'disabled')

" When set to true or 1 LSP hover messages are shown at the cursor.
let g:ale_hover_cursor = get(g:, 'ale_hover_cursor', v:true)

" When true or 1 to close the preview window on entering Insert Mode.
let g:ale_close_preview_on_insert = get(g:, 'ale_close_preview_on_insert', v:false)

" When set to true or 1 balloon support is enabled.
let g:ale_set_balloons = get(g:, 'ale_set_balloons', (has('balloon_eval') && has('gui_running')) ? v:true : v:false)

" When set to true or 1 use the preview window for showing hover messages.
let g:ale_hover_to_preview = get(g:, 'ale_hover_to_preview', v:false)

" When set to true or 1 use floating preview windows in Neovim.
let g:ale_floating_preview = get(g:, 'ale_floating_preview', v:false)

" When set to true or 1 show hove messages in floating windows in Neovim.
let g:ale_hover_to_floating_preview = get(g:, 'ale_hover_to_floating_preview', v:false)

" When set to true or 1 details are shown in floating windows in Neovim.
let g:ale_detail_to_floating_preview = get(g:, 'ale_detail_to_floating_preview', v:false)

" Border setting for floating preview windows
"
" The elements in the list set the characters for the left, top, top-left,
" top-right, bottom-right, bottom-left, right, and bottom of the border
" respectively
let g:ale_floating_window_border = get(g:, 'ale_floating_window_border', ['|', '-', '+', '+', '+', '+', '|', '-'])

" When set to true or 1 warnings for trailing whitespace are shown.
let g:ale_warn_about_trailing_whitespace = get(g:, 'ale_warn_about_trailing_whitespace', v:true)
" When set to true or 1 warnings for trailing blank lines are shown.
let g:ale_warn_about_trailing_blank_lines = get(g:, 'ale_warn_about_trailing_blank_lines', v:true)

" When set to true or 1 the command history is logged.
let g:ale_history_enabled = get(g:, 'ale_history_enabled', v:true)

" When set to true or 1 the full output of commands is logged.
let g:ale_history_log_output = get(g:, 'ale_history_log_output', v:true)

" When set to true or 1 enable ALE's built-in autocompletion functionality.
let g:ale_completion_enabled = get(g:, 'ale_completion_enabled', v:false)

" When set to true or 1 enable automatic detection of pipenv for Python.
let g:ale_python_auto_pipenv = get(g:, 'ale_python_auto_pipenv', v:false)

" When set to true or 1 enable automatic detection of poetry for Python.
let g:ale_python_auto_poetry = get(g:, 'ale_python_auto_poetry', v:false)

" When set to true or 1 enable automatic detection of uv for Python.
let g:ale_python_auto_uv = get(g:, 'ale_python_auto_uv', v:false)

" When set to true or 1 enable automatically updating environment variables
" for running Python linters from virtualenv directories.
"
" The variables are set based on ALE's virtualenv detection.
let g:ale_python_auto_virtualenv = get(g:, 'ale_python_auto_virtualenv', v:false)

" This variable can be overridden to set the GO111MODULE environment variable.
let g:ale_go_go111module = get(g:, 'ale_go_go111module', '')

" The default executable for deno. Must be set before ALE lints any buffers.
let g:ale_deno_executable = get(g:, 'ale_deno_executable', 'deno')

" If true or 1, enable a popup menu for commands.
let g:ale_popup_menu_enabled = get(g:, 'ale_popup_menu_enabled', has('gui_running') ? v:true : v:false)

" If true or 1, save hidden files when code actions are applied.
let g:ale_save_hidden = get(g:, 'ale_save_hidden', v:false)

" If true or 1, disables ALE's built in error display.
"
" Instead, all errors are piped to the Neovim diagnostics API.
let g:ale_use_neovim_diagnostics_api = get(g:, 'ale_use_neovim_diagnostics_api', has('nvim-0.7') ? v:true : v:false)

if g:ale_use_neovim_diagnostics_api && !has('nvim-0.7')
    " no-custom-checks
    echoerr('Setting g:ale_use_neovim_diagnostics_api to true or 1 requires Neovim 0.7+.')
endif

" If true or 1, uses Neovim's built-in LSP client to integrate with LSP, which
" improves ALE's integration with built-in Neovim tools and other plugins.
let g:ale_use_neovim_lsp_api = get(g:, 'ale_use_neovim_lsp_api', has('nvim-0.8') ? v:true : v:false)

" If 1, replaces ALE's use of jobs and channels to connect to language
" servers, plus the custom code, and instead hooks ALE into Neovim's built-in
" language server tools.
if g:ale_use_neovim_lsp_api && !has('nvim-0.8')
    " no-custom-checks
    echoerr('Setting g:ale_use_neovim_lsp_api to true or 1 requires Neovim 0.8+.')
endif

if g:ale_set_balloons || g:ale_set_balloons is# 'hover'
    call ale#balloon#Enable()
endif

if g:ale_completion_enabled
    call ale#completion#Enable()
endif

if g:ale_popup_menu_enabled
    call ale#code_action#EnablePopUpMenu()
endif

" Define commands for moving through warnings and errors.
command! -bar -nargs=* ALEPrevious
\    :call ale#loclist_jumping#WrapJump('before', <q-args>)
command! -bar -nargs=* ALENext
\    :call ale#loclist_jumping#WrapJump('after', <q-args>)

command! -bar ALEPreviousWrap :call ale#loclist_jumping#Jump('before', 1)
command! -bar ALENextWrap :call ale#loclist_jumping#Jump('after', 1)
command! -bar ALEFirst :call ale#loclist_jumping#JumpToIndex(0)
command! -bar ALELast :call ale#loclist_jumping#JumpToIndex(-1)

" A command for showing error details.
command! -bar ALEDetail :call ale#cursor#ShowCursorDetail()

" Define commands for turning ALE on or off.
command! -bar ALEToggle :call ale#toggle#Toggle()
command! -bar ALEEnable :call ale#toggle#Enable()
command! -bar ALEDisable :call ale#toggle#Disable()
command! -bar ALEReset :call ale#toggle#Reset()
" Commands for turning ALE on or off for a buffer.
command! -bar ALEToggleBuffer :call ale#toggle#ToggleBuffer(bufnr(''))
command! -bar ALEEnableBuffer :call ale#toggle#EnableBuffer(bufnr(''))
command! -bar ALEDisableBuffer :call ale#toggle#DisableBuffer(bufnr(''))
command! -bar ALEResetBuffer :call ale#toggle#ResetBuffer(bufnr(''))
" A command to stop all LSP-like clients, including tsserver.
command! -bar ALEStopAllLSPs :call ale#lsp#reset#StopAllLSPs()
" A command to stop a specific language server, or tsseserver.
command! -bar -bang -nargs=1 -complete=customlist,ale#lsp#reset#Complete ALEStopLSP :call ale#lsp#reset#StopLSP(<f-args>, '<bang>')

" A command for linting manually.
command! -bar ALELint :call ale#Queue(0, 'lint_file')
" Stop current jobs when linting.
command! -bar ALELintStop :call ale#engine#Stop(bufnr(''))

" Commands to manually populate the quickfixes.
command! -bar ALEPopulateQuickfix :call ale#list#ForcePopulateErrorList(1)
command! -bar ALEPopulateLocList  :call ale#list#ForcePopulateErrorList(0)

" Define a command to get information about current filetype.
command! -bar -nargs=* ALEInfo :call ale#debugging#InfoCommand(<f-args>)
" Deprecated and scheduled for removal in 4.0.0.
command! -bar ALEInfoToClipboard :call ale#debugging#InfoToClipboardDeprecatedCommand()
" Copy ALE information to a file.
command! -bar -nargs=1 ALEInfoToFile :call ale#debugging#InfoToFile(<f-args>)

" Fix problems in files.
command! -bar -bang -nargs=* -complete=customlist,ale#fix#registry#CompleteFixers ALEFix :call ale#fix#Fix(bufnr(''), '<bang>', <f-args>)
" Suggest registered functions to use for fixing problems.
command! -bar ALEFixSuggest :call ale#fix#registry#Suggest(&filetype)

" Go to definition for tsserver and LSP
command! -bar -nargs=* ALEGoToDefinition :call ale#definition#GoToCommandHandler('', <f-args>)

" Go to type definition for tsserver and LSP
command! -bar -nargs=* ALEGoToTypeDefinition :call ale#definition#GoToCommandHandler('type', <f-args>)

" Go to implementation for tsserver and LSP
command! -bar -nargs=* ALEGoToImplementation :call ale#definition#GoToCommandHandler('implementation', <f-args>)

" Repeat a previous selection in the preview window
command! -bar ALERepeatSelection :call ale#preview#RepeatSelection()

" Find references for tsserver and LSP
command! -bar -nargs=* ALEFindReferences :call ale#references#Find(<f-args>)

" Show summary information for the cursor.
command! -bar ALEHover :call ale#hover#ShowAtCursor()

" Show documentation for the cursor.
command! -bar ALEDocumentation :call ale#hover#ShowDocumentationAtCursor()

" Search for appearances of a symbol, such as a type name or function name.
command! -nargs=1 ALESymbolSearch :call ale#symbol#Search(<q-args>)

" Complete text with tsserver and LSP
command! -bar ALEComplete :call ale#completion#GetCompletions('ale-manual')

" Try to find completions for the current symbol that add additional text.
command! -bar ALEImport :call ale#completion#Import()

" Rename symbols using tsserver and LSP
command! -bar -bang ALERename :call ale#rename#Execute()

" Rename file using tsserver
command! -bar -bang ALEFileRename :call ale#filerename#Execute()

" Apply code actions to a range.
command! -bar -range ALECodeAction :call ale#codefix#Execute(<range>)

" Organize import statements using tsserver
command! -bar ALEOrganizeImports :call ale#organize_imports#Execute()

" <Plug> mappings for commands
nnoremap <silent> <Plug>(ale_previous) :ALEPrevious<Return>
nnoremap <silent> <Plug>(ale_previous_wrap) :ALEPreviousWrap<Return>
nnoremap <silent> <Plug>(ale_previous_error) :ALEPrevious -error<Return>
nnoremap <silent> <Plug>(ale_previous_wrap_error) :ALEPrevious -wrap -error<Return>
nnoremap <silent> <Plug>(ale_previous_warning) :ALEPrevious -warning<Return>
nnoremap <silent> <Plug>(ale_previous_wrap_warning) :ALEPrevious -wrap -warning<Return>
nnoremap <silent> <Plug>(ale_next) :ALENext<Return>
nnoremap <silent> <Plug>(ale_next_wrap) :ALENextWrap<Return>
nnoremap <silent> <Plug>(ale_next_error) :ALENext -error<Return>
nnoremap <silent> <Plug>(ale_next_wrap_error) :ALENext -wrap -error<Return>
nnoremap <silent> <Plug>(ale_next_warning) :ALENext -warning<Return>
nnoremap <silent> <Plug>(ale_next_wrap_warning) :ALENext -wrap -warning<Return>
nnoremap <silent> <Plug>(ale_first) :ALEFirst<Return>
nnoremap <silent> <Plug>(ale_last) :ALELast<Return>
nnoremap <silent> <Plug>(ale_toggle) :ALEToggle<Return>
nnoremap <silent> <Plug>(ale_enable) :ALEEnable<Return>
nnoremap <silent> <Plug>(ale_disable) :ALEDisable<Return>
nnoremap <silent> <Plug>(ale_reset) :ALEReset<Return>
nnoremap <silent> <Plug>(ale_toggle_buffer) :ALEToggleBuffer<Return>
nnoremap <silent> <Plug>(ale_enable_buffer) :ALEEnableBuffer<Return>
nnoremap <silent> <Plug>(ale_disable_buffer) :ALEDisableBuffer<Return>
nnoremap <silent> <Plug>(ale_reset_buffer) :ALEResetBuffer<Return>
nnoremap <silent> <Plug>(ale_lint) :ALELint<Return>
nnoremap <silent> <Plug>(ale_detail) :ALEDetail<Return>
nnoremap <silent> <Plug>(ale_fix) :ALEFix<Return>
nnoremap <silent> <Plug>(ale_go_to_definition) :ALEGoToDefinition<Return>
nnoremap <silent> <Plug>(ale_go_to_definition_in_tab) :ALEGoToDefinition -tab<Return>
nnoremap <silent> <Plug>(ale_go_to_definition_in_split) :ALEGoToDefinition -split<Return>
nnoremap <silent> <Plug>(ale_go_to_definition_in_vsplit) :ALEGoToDefinition -vsplit<Return>
nnoremap <silent> <Plug>(ale_go_to_type_definition) :ALEGoToTypeDefinition<Return>
nnoremap <silent> <Plug>(ale_go_to_type_definition_in_tab) :ALEGoToTypeDefinition -tab<Return>
nnoremap <silent> <Plug>(ale_go_to_type_definition_in_split) :ALEGoToTypeDefinition -split<Return>
nnoremap <silent> <Plug>(ale_go_to_type_definition_in_vsplit) :ALEGoToTypeDefinition -vsplit<Return>
nnoremap <silent> <Plug>(ale_go_to_implementation) :ALEGoToImplementation<Return>
nnoremap <silent> <Plug>(ale_go_to_implementation_in_tab) :ALEGoToImplementation -tab<Return>
nnoremap <silent> <Plug>(ale_go_to_implementation_in_split) :ALEGoToImplementation -split<Return>
nnoremap <silent> <Plug>(ale_go_to_implementation_in_vsplit) :ALEGoToImplementation -vsplit<Return>
nnoremap <silent> <Plug>(ale_find_references) :ALEFindReferences<Return>
nnoremap <silent> <Plug>(ale_hover) :ALEHover<Return>
nnoremap <silent> <Plug>(ale_documentation) :ALEDocumentation<Return>
inoremap <silent> <Plug>(ale_complete) <C-\><C-O>:ALEComplete<Return>
nnoremap <silent> <Plug>(ale_import) :ALEImport<Return>
nnoremap <silent> <Plug>(ale_rename) :ALERename<Return>
nnoremap <silent> <Plug>(ale_filerename) :ALEFileRename<Return>
nnoremap <silent> <Plug>(ale_code_action) :ALECodeAction<Return>
nnoremap <silent> <Plug>(ale_repeat_selection) :ALERepeatSelection<Return>
nnoremap <silent> <Plug>(ale_info) :ALEInfo<Return>
nnoremap <silent> <Plug>(ale_info_echo) :ALEInfo -echo<Return>
nnoremap <silent> <Plug>(ale_info_clipboard) :ALEInfo -clipboard<Return>
nnoremap <silent> <Plug>(ale_info_preview) :ALEInfo -preview<Return>

" Set up autocmd groups now.
call ale#events#Init()

" Housekeeping

augroup ALECleanupGroup
    autocmd!
    " Clean up buffers automatically when they are unloaded.
    autocmd BufDelete * if exists('*ale#engine#Cleanup') | call ale#engine#Cleanup(str2nr(expand('<abuf>'))) | endif
    autocmd QuitPre * call ale#events#QuitEvent(str2nr(expand('<abuf>')))

    if exists('##VimSuspend')
        autocmd VimSuspend * if exists('*ale#engine#CleanupEveryBuffer') | call ale#engine#CleanupEveryBuffer() | endif
    endif
augroup END
