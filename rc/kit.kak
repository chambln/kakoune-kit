define-command -params .. kit-select %{
    set-register / '^[ !\?ACDMR]{2} '
    try %{ execute-keys '<a-x>s<ret><a-:>l<a-l>S -> <ret>' }
    set-register / %sh{
        eval set -- "$@"
        while [ $# -gt 0 ]; do
            printf '%s|' $1
            shift
        done
    }
    execute-keys s<up><backspace><ret>
}


define-command -params .. kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<ret>'
    execute-keys '<a-;>!git log -6 --oneline<ret><ret>'
    execute-keys '<esc>|git status --short<ret>'
    set-option buffer readonly true
    kit-select %arg{@}
}


define-command kit-add %{
    evaluate-commands -itersel %{
        nop %sh{ git add -- "$kak_selection" }
    }
    kit %val{selections}
}


define-command kit-subtract %{
    evaluate-commands -itersel %{
        nop %sh{
            git reset -- "$kak_selection" || {
                git restore --staged -- "$kak_selection"
            }
        }
    }
    kit %val{selections}
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^Recent commits:$' 0:title
    add-highlighter window/kit/ regex '^[0-9a-f]{7} ' 0:comment
    add-highlighter window/kit/ regex '^(?:(M)|(A)|([D!?])|(R)|(C))[ !\?ACDMR] (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^[ !\?ACDMR](?:(M)|(A)|([D!?])|(R)|(C)) (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^R[ !\?ACDMR] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey '[JKjk%]' %{ try kit-select }

    map window normal a ': kit-add<ret>'
    map window normal r ': kit-subtract<ret>'
    map window normal c ': git commit<ret>'
    map window normal \; ': kit-select<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        unmap window normal a ': kit-add<ret>'
        unmap window normal r ': kit-subtract<ret>'
        unmap window normal c ': git commit<ret>'
        unmap window normal \; ': kit-select<ret>'
    }
}
