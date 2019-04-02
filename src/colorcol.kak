declare-option -hidden line-specs colorcol_marks
declare-option str colorcol_char █

define-command colorcol-enable %{
    colorcol-refresh
    add-highlighter buffer/colorcol flag-lines default colorcol_marks
}
define-command colorcol-disable %{
    remove-highlighter buffer/colorcol
}
define-command colorcol-refresh %{evaluate-commands %sh{
    colorcol "$kak_timestamp" "$kak_buffile" "$kak_opt_colorcol_char"
} }
define-command colorcol-auto-refresh %{
    hook global BufWritePost .* colorcol-refresh
}
