define-command kit-goto-file %{
    edit -existing -- %sh{
        printf %s "$(git rev-parse --show-toplevel)/$kak_selection"
    }
}


define-command -hidden kit-select %{
    unmap window normal a
    unmap window normal d
    unmap window normal r
    try %{
        # Select paths
        execute-keys '<a-x>s^[ !\?ACDMRTU]{2} <ret><a-:>l<a-l>S → <ret>'
        map window normal -docstring add a ': kit-add<ret>'
        map window normal -docstring diff d ': kit-diff %val{selections}<a-!><ret>'
        map window normal -docstring subtract r ': kit-subtract<ret>'
    } catch %{
        # Select truncated SHA-1
        execute-keys '<a-x>s^[0-9a-f]{7}<ret>'
        map window normal -docstring show d ': git show %val{selections}<a-!><ret>'
    } catch nop
}


define-command -hidden kit-rebuild %{
    set-option buffer readonly false
    execute-keys '%"_cRecent commits:<ret>'
    execute-keys '<a-;>!git log -6 --oneline<ret><ret><esc>'
    execute-keys '|git status -zb<ret>s\0<ret>r<ret>ghj'
    try %{ execute-keys 'sR<ret>LLdjPkxdp<a-J>i →<esc>%' }
    set-option buffer readonly true
    kit-select
}
define-command -hidden kit-refresh %{
    execute-keys '*: kit-rebuild; try %{exec s<lt>ret<gt>}<ret>'
}


define-command kit %{
    edit -scratch *kit*
    set-option buffer filetype kit
    kit-refresh
}


define-command -hidden kit-commit %{
    evaluate-commands %sh{
        GIT_EDITOR='' EDITOR='' git commit > /dev/null 2>&1
        msgfile="$(git rev-parse --git-dir)/COMMIT_EDITMSG"
        printf %s "edit '$msgfile'
                   hook buffer BufWritePost '.*\Q$msgfile\E' %{
                       evaluate-commands %sh{
                           if git commit -F '$msgfile' --cleanup=strip $* > /dev/null; then
                               printf %s 'delete-buffer
                                          kit
                                          evaluate-commands -try-client $kak_client echo -markup %{{Information}Commit succeeded}'
                           else
                               printf 'evaluate-commands -try-client %s fail Commit failed\n' "$kak_client"
                           fi
                       }
                   }"
    }
}


define-command -hidden -params .. kit-diff %{
    evaluate-commands %sh{
        patchfile="$(git rev-parse --git-dir)/ADD_EDIT.patch"
        GIT_EDITOR='' EDITOR='' git add -e $@ > /dev/null 2>&1
        printf %s "try %{
                       edit -existing '$patchfile'
                       hook buffer BufWritePost '.*\Q$patchfile\E' %{
                           evaluate-commands %sh{
                               if git apply --cache --recount '$patchfile' > /dev/null; then
                                   printf %s 'evaluate-commands -try-client $kak_client echo -markup %{{Information}Staged successfully}
                                              delete-buffer
                                              kit'
                               else
                                   printf 'evaluate-commands -try-client %s fail Staging failed\n' "$kak_client"
                               fi
                           }
                       }
                       hook buffer BufClose '.*\Q$patchfile\E' %{
                           nop %sh{ rm -f '$patchfile' }
                       }
                   } catch %{
                       git diff -- "$@"
                   }"
    }
}


define-command -hidden kit-add %{
    evaluate-commands -itersel %{
        nop %sh{ git add -- "$(git rev-parse --show-toplevel)/$kak_selection" }
    }
    kit-refresh
}


define-command -hidden kit-subtract %{
    evaluate-commands -itersel %{
        nop %sh{
            target="$(git rev-parse --show-toplevel)/$kak_selection"
            git reset -- "$target" || git restore --staged -- "$target"
        }
    }
    kit-refresh
}


hook -group kit global WinSetOption filetype=kit %{
    add-highlighter window/kit group
    add-highlighter window/kit/ regex '^Recent commits:$' 0:title
    add-highlighter window/kit/ regex '^[0-9a-f]{7} ' 0:comment
    add-highlighter window/kit/ regex '^(##) (\S+)(( \[[^\n]+\]))?' 1:comment 2:builtin 3:keyword
    add-highlighter window/kit/ regex '^(?:(A)|(C)|([D!?])|([MU])|(R)|(T))[ !\?ACDMRTU] (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^[ !\?ACDMRTU](?:(A)|(C)|([D!?])|([MU])|(R)|(T)) (?:.+?)$' 1:green 2:blue 3:red 4:yellow 5:cyan 6:cyan
    add-highlighter window/kit/ regex '^R[ !\?ACDMRTU] [^\n]+( → )' 1:cyan

    hook -group kit window NormalKey '[JKjkhlHLxX%]' kit-select

    map window goto f '<esc>: kit-goto-file<ret>'
    map window normal c ': kit-commit<ret>'
    map window normal l ': git log<ret>'
    map window normal \; ': kit-select<ret>'
    map window normal <a-x> ': kit-select<ret>'
    map window normal x '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>x: kit-select<ret>'
    map window normal X '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>X: kit-select<ret>'

    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/kit
        remove-hooks window kit
        unmap window goto f '<esc>: kit-goto-file<ret>'
        unmap window normal c ': kit-commit<ret>'
        unmap window normal l ': git log<ret>'
        unmap window normal \; ': kit-select<ret>'
        unmap window normal <a-x> ': kit-select<ret>'
        unmap window normal x '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>x: kit-select<ret>'
        unmap window normal X '<a-:>5L4H<a-;>Zgh3L<a-z>a<a-:>X: kit-select<ret>'
        unmap window normal a
        unmap window normal d
        unmap window normal r
        set-option buffer readonly false
    }
}
