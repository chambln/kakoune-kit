define-command -hidden kit-status-select %{
    try %{
        execute-keys '<a-:><a-x>1s^(?:[ !\?ACDMRTUacdmrtu]{2}|\t(?:(?:both )?modified:|added:|new file:|deleted(?: by \w+)?:|renamed:|copied:))?\h+(?:[^\n]+ -> )?([^\n]+)<ret>'
    }
}

define-command -hidden kit-log-select %{
    try %{
        execute-keys '<a-x>2s^[\*|\\ /]*(commit )?(\b[0-9a-f]{4,40}\b)<ret><a-:>'
    }
}

hook -group kit-status global WinSetOption filetype=git-status %{
    add-highlighter window/kit-status group
    add-highlighter window/kit-status/ regex '^## ' 0:comment
    add-highlighter window/kit-status/ regex '^## (\S*[^\s\.@])' 1:green
    add-highlighter window/kit-status/ regex '^## (\S*[^\s\.@])(\.\.+)(\S*[^\s\.@])' 1:green 2:comment 3:red
    add-highlighter window/kit-status/ regex '^(##) (No commits yet on) (\S*[^\s\.@])' 1:comment 2:Default 3:green
    add-highlighter window/kit-status/ regex '^## \S+ \[[^\n]*ahead (\d+)[^\n]*\]' 1:green
    add-highlighter window/kit-status/ regex '^## \S+ \[[^\n]*behind (\d+)[^\n]*\]' 1:red
    add-highlighter window/kit-status/ regex '^(?:([Aa])|([Cc])|([Dd!?])|([MUmu])|([Rr])|([Tt]))[ !\?ACDMRTUacdmrtu]\h' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit-status/ regex '^[ !\?ACDMRTUacdmrtu](?:([Aa])|([Cc])|([Dd!?])|([MUmu])|([Rr])|([Tt]))\h' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit-status/ regex '^R[ !\?ACDMRTUacdmrtu] [^\n]+( -> )' 1:cyan
    add-highlighter window/kit-status/ regex '^\h+(?:((?:both )?modified:)|(added:|new file:)|(deleted(?: by \w+)?:)|(renamed:)|(copied:))(?:.*?)$' 1:yellow 2:green 3:red 4:cyan 5:blue 6:magenta
    hook -group kit-status window NormalKey '[JKjk%]|<esc>' kit-status-select
    map window normal <semicolon> ': kit-status-select<ret>'
    map window normal c ': git commit '
    map window normal d ': -- %val{selections}<a-!><home>git diff '
    map window normal a ': -- %val{selections}<a-!><home>git add '
    map window normal r ': -- %val{selections}<a-!><home>git reset '
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit-status
        remove-hooks window kit-status
        unmap window normal <semicolon> ': kit-status-select<ret>'
        unmap window normal c
        unmap window normal d
        unmap window normal a
        unmap window normal r
    }
}

hook -group kit-log global WinSetOption filetype=git-log %{
    add-highlighter window/kit-log group
    add-highlighter window/kit-log/ regex '^([\*|\\ /])*' 0:keyword
    add-highlighter window/kit-log/ regex '^( ?[\*|\\/])*\h{,3}(commit )?(\b[0-9a-f]{4,40}\b)' 2:keyword 3:comment
    add-highlighter window/kit-log/ regex '^( ?[\*|\\/])*\h{,3}([a-zA-Z_-]+:) (.*?)$' 2:variable 3:value
    hook -group kit-log window NormalKey '[JKjk%]|<esc>' kit-log-select
    map window normal <semicolon> ': kit-log-select<ret>'
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit-log
        remove-hooks window kit-log
        unmap window normal <semicolon>
    }
}
