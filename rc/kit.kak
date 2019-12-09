define-command -hidden kit-select %{
    execute-keys <a-x>
    try %{
        execute-keys 's^[ !\?ACDMRTU]{2} <ret><a-:>l<a-l>S -> <ret>'
        map window normal d ': git diff -- %val{selections}<a-!><ret>'
    } catch %{
        execute-keys 's^[0-9a-f]{4,40} <ret><a-:>H'
        map window normal d ': git show %val{selections}<a-!><ret>'
    } catch %{
        unmap window normal d
    }
}

define-command -hidden kit-rebuild %{
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<ret>'
    execute-keys '<a-;>!git log -6 --oneline<ret><ret><esc>'
    execute-keys '|git status -bs<ret><a-;>J'
    set-option buffer readonly true
}
define-command -hidden kit-refresh %{
    execute-keys '*: kit-rebuild; try %{exec s<lt>ret<gt>}<ret><a-:>'
}


define-command kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    kit-rebuild
    try kit-select
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^Recent commits:$' 0:title
    add-highlighter window/kit/ regex '^[0-9a-f]{4,40} ' 0:comment
    add-highlighter window/kit/ regex '^## ' 0:comment
    add-highlighter window/kit/ regex '^## (\S+)' 1:green
    add-highlighter window/kit/ regex '^## (\S+)(\.\.+)(\S+)' 1:green 2:comment 3:red
    add-highlighter window/kit/ regex '^## \S+ \[[^\n]*ahead (\d+)[^\n]*\]' 1:green
    add-highlighter window/kit/ regex '^## \S+ \[[^\n]*behind (\d+)[^\n]*\]' 1:red
    add-highlighter window/kit/ regex '^(?:(A)|(C)|([D!?])|([MU])|(R)|(T))[ !\?ACDMRTU] (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^[ !\?ACDMRTU](?:(A)|(C)|([D!?])|([MU])|(R)|(T)) (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^R[ !\?ACDMRTU] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey '[JKjkhlHL%]' %{ try kit-select }

    map window normal <semicolon> ': try kit-select<ret>'
    map window normal <esc>       ': try kit-select<ret>'
    map window normal a ': git add   -- %val{selections}<a-!>;kit-refresh<ret>'
    map window normal r ': git reset -- %val{selections}<a-!>;kit-refresh<ret>'
    map window normal c ': git commit<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        set-option buffer readonly false
    }
}
