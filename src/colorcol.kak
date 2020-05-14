declare-option -hidden range-specs colorcol_ranges
define-command colorcol-enable %{colorcol-refresh;add-highlighter buffer/colorcol ranges colorcol_ranges}
define-command colorcol-disable %{remove-highlighter buffer/colorcol}
define-command colorcol-refresh %{evaluate-commands %sh{colorcol "$kak_buffile"}}
define-command colorcol-auto-refresh %{hook global BufWritePost .* colorcol-refresh}
