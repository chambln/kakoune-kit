define-command kit-select %{
    set-register / '^[ !\?ACDMR]{2} ([^\n]+ -> )?'
    execute-keys <a-x>s<ret><a-:>l<a-l>
}


define-command kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    execute-keys '%|git status --short<ret>'
    kit-select
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^(?:(M)|(A)|([D!?])|(R)|(C))[ !\?ACDMR] (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^[ !\?ACDMR](?:(M)|(A)|([D!?])|(R)|(C)) (?:.+?)$' 1:yellow 2:green 3:red 4:cyan 5:blue
    add-highlighter window/kit/ regex '^R[ !\?ACDMR] [^\n]+( -> )' 1:cyan

    hook -group kit window NormalKey [JKjk] %{ try kit-select }

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
    }
}
