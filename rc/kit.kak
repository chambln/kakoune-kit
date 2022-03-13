define-command -hidden kit-status-select %{
    try %{
        execute-keys '<a-:><a-x>1s^(?:[ !\?ACDMRTUacdmrtu]{2}|\t(?:(?:both )?modified:|added:|new file:|deleted(?: by \w+)?:|renamed:|copied:))?\h+(?:[^\n]+ -> )?([^\n]+)<ret>'
    }
}

define-command -hidden kit-log-select %{
    try %{
        execute-keys '<a-x>2s^[\*|\\ /_]*(\w+)?(\b[0-9a-f]{4,40}\b)<ret><a-:>'
    }
}

hook -group kit-status global WinSetOption filetype=git-status %{
    hook -group kit-status window NormalKey '[JKjk%]|<esc>' kit-status-select
    hook -once -always window WinSetOption filetype=.* %{
        remove-hooks window kit-status
    }
}

hook -group kit-log global WinSetOption filetype=git-log %{
    hook -group kit-log window NormalKey '[JKjk%]|<esc>' kit-log-select
    hook -once -always window WinSetOption filetype=.* %{
        remove-hooks window kit-log
    }
}
