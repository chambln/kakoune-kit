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


define-command -params ..1 kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    execute-keys '%|git status --short<ret>'
    kit-select %arg{1}
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
    add-highlighter window/kit/ regex '^(?:(M)|(A)|([D!?])|(R)|(C))[ !\?ACDMR] (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^[ !\?ACDMR](?:(M)|(A)|([D!?])|(R)|(C)) (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^R[ !\?ACDMR] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey '[JKjk%]' %{ try kit-select }

    map window normal a ': kit-add<ret>'
    map window normal r ': kit-subtract<ret>'
    map window normal c ': git commit<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        unmap window normal a ': kit-add<ret>'
        unmap window normal r ': kit-subtract<ret>'
    }
}
