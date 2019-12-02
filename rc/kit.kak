define-command kit-construct %{
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<ret>'
    execute-keys '<a-;>!git log -6 --oneline<ret><ret><esc>'
    execute-keys '|git status -zb<ret>s\0<ret>r<ret>gh'
    try %{ execute-keys 'sR<ret>LLdjPkxdp<a-J>i -><esc>' }
    execute-keys '<a-a>p'
    set-option buffer readonly true
}


define-command kit-select %{
    try %{ execute-keys '<a-x>s^[ !\?ACDMRT]{2} <ret><a-:>l<a-l>S -> <ret>' }
}


define-command kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    kit-construct
    kit-select
}


define-command kit-add %{
    evaluate-commands -itersel %{
        nop %sh{
            target="$(git rev-parse --show-toplevel)/$kak_selection"
            git add -- "$target"
        }
    }
    kit-construct
    execute-keys '%'
    kit-select
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
    kit-construct
    execute-keys '%'
    kit-select
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^Recent commits:$' 0:title
    add-highlighter window/kit/ regex '^[0-9a-f]{7} ' 0:comment
    add-highlighter window/kit/ regex '^(##) (\S+)(( \[[^\n]+\]))?' 1:comment 2:builtin 3:keyword
    add-highlighter window/kit/ regex '^(?:(M)|(A)|([D!?])|(R)|(C))[ !\?ACDMRT] (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^[ !\?ACDMRT](?:(M)|(A)|([D!?])|(R)|(C)) (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^R[ !\?ACDMRT] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey '[JKjkx%]' kit-select

    map window normal a '*: kit-add; try %{exec s<lt>ret<gt>}<ret>'
    map window normal r '*: kit-subtract; try %{exec s<lt>ret<gt>}<ret>'
    map window normal c ': git commit<ret>'
    map window normal \; ': kit-select<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        unmap window normal a '*: kit-add; try %{exec s<lt>ret<gt>}<ret>'
        unmap window normal r '*: kit-subtract; try %{exec s<lt>ret<gt>}<ret>'
        unmap window normal c ': git commit<ret>'
        unmap window normal \; ': kit-select<ret>'
    }
}
