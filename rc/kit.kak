define-command kit-select %{
    try %{ execute-keys '<a-x>s^[ !\?ACDMRT]{2} <ret><a-:>l<a-l>S -> <ret>' }
}


define-command kit-refresh %{
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<ret>'
    execute-keys '<a-;>!git log -6 --oneline<ret><ret><esc>'
    execute-keys '|git status -zb<ret>s\0<ret>r<ret>ghj'
    try %{ execute-keys 'sR<ret>LLdjPkxdp<a-J>i -><esc>%' }
    set-option buffer readonly true
    kit-select
}
define-command kit-refresh-restore %{
    execute-keys '*: kit-refresh; try %{exec s<lt>ret<gt>}<ret>'
}


define-command kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    kit-refresh
}


define-command kit-add %{
    evaluate-commands -itersel %{
        nop %sh{
            target="$(git rev-parse --show-toplevel)/$kak_selection"
            git add -- "$target"
        }
    }
    kit-refresh-restore
}


define-command kit-subtract %{
    evaluate-commands -itersel %{
        nop %sh{
            target="$(git rev-parse --show-toplevel)/$kak_selection"
            git reset -- "$target" || {
                git restore --staged -- "$target"
            }
        }
    }
    kit-refresh-restore
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^Recent commits:$' 0:title
    add-highlighter window/kit/ regex '^[0-9a-f]{7} ' 0:comment
    add-highlighter window/kit/ regex '^(##) (\S+)(( \[[^\n]+\]))?' 1:comment 2:builtin 3:keyword
    add-highlighter window/kit/ regex '^(?:(A)|(C)|([D!?])|(M)|(R)|(T))[ !\?ACDMRT] (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^[ !\?ACDMRT](?:(A)|(C)|([D!?])|(M)|(R)|(T)) (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^R[ !\?ACDMRT] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey '[JKjkxX%]' kit-select

    map window normal a ': kit-add<ret>'
    map window normal r ': kit-subtract<ret>'
    map window normal c ': git commit<ret>'
    map window normal \; ': kit-select<ret>'
    map window normal <a-x> ': kit-select<ret>'
    map window normal x '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>x: kit-select<ret>'
    map window normal X '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>X: kit-select<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        unmap window normal a ': kit-add<ret>'
        unmap window normal r ': kit-subtract<ret>'
        unmap window normal c ': git commit<ret>'
        unmap window normal \; ': kit-select<ret>'
        unmap window normal <a-x> ': kit-select<ret>'
        unmap window normal x '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>x: kit-select<ret>'
        unmap window normal X '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>X: kit-select<ret>'
        set-option buffer readonly false
    }
}
