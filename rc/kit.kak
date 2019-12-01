define-command kit-commit %{
    eval -try-client docs %{ git diff --cached }
    eval -try-client jump %{ git commit }
}

define-command kit-select %{
    execute-keys '<esc><a-x>s^[ !\?ACDMR]{2} ([^\n]+ -> )?<ret><a-:>l<a-l>'
    try %{ execute-keys '<a-:><a-;><a-i>"' }
}

define-command kit-add %{
    evaluate-commands %sh{
        x="$(git rev-parse --show-toplevel)/$kak_selection"
        printf %s "try %{
                       execute-keys -draft '<a-h>ls <ret>'
                       nop %sh{
                           git restore --staged '$x' || git rm --cached '$x'
                       }
                   } catch %{
                       nop %sh{ git add '$x' }
                   }
                   eval -try-client docs %{ git diff --cached }
                   kit-status
                   try %{
                       set-register / '^[ !\?ACDMR]{2} ([^\n]+ -> )?$kak_selection'
                       execute-keys n
                   }"
    }
    kit-select
}

define-command kit-status-refresh %{
    edit -scratch *kit*
    set-option buffer filetype kit-status
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<esc><a-!>git log -6 --oneline<ret>'
    execute-keys '6j<a-o>j<a-!>git status --porcelain 2>&1<ret>'
    execute-keys '/^[ !\?ACDMR]{2} ([^\n]+ -> )?<ret>l<a-l>'
    set-option buffer readonly true
}

define-command kit-status %{
    evaluate-commands %sh{
        git rev-parse >/dev/null 2>&1 && printf kit-status-refresh
    }
}

hook -group kit-status-keys global WinSetOption filetype=kit-status %{
    map window normal c ': kit-commit<ret>'
    map window normal j          '/^[ !\?ACDMR]{2} ([^\n]+ -> )?<ret>: kit-select<ret><a-:>'
    map window normal k '<a-h><a-/>^[ !\?ACDMR]{2} ([^\n]+ -> )?<ret>: kit-select<ret><a-:><a-;>'
    map window normal l ': git log<ret>'
    map window normal s ': git status<ret>'
    map window normal <space> ': kit-add<ret>'
    map window normal <ret> ': git diff "%sh{git rev-parse --show-toplevel}/<c-r>."<ret>'
    map window goto f '<esc>: e "%sh{git rev-parse --show-toplevel}/<c-r>."<ret>'
}

hook -group kit-status-highlight global WinSetOption filetype=kit-status %{
    add-highlighter window/kit-status group
    add-highlighter window/kit-status/ regex '^Recent commits:$' 0:magenta
    add-highlighter window/kit-status/ regex '^(?:(M)|(A)|([D!?])|(R)|(C))[ !\?ACDMR] (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit-status/ regex '^[ !\?ACDMR](?:(M)|(A)|([D!?])|(R)|(C)) (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit-status/ regex '^R[ !\?ACDMR] [^\n]+( -> )' 1:cyan
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit-status
    }
}
