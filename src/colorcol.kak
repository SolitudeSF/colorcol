declare-option -hidden range-specs colorcol_ranges
declare-option -hidden range-specs colorcol_replace_ranges
declare-option -hidden line-specs colorcol_flags
declare-option str colorcol_mode range
declare-option bool colorcol_color_full true
declare-option bool colorcol_background true
declare-option str colorcol_max_flags 3
declare-option str colorcol_flag_str █
declare-option str colorcol_replace_str ■
define-command -hidden colorcol-update-highlighter %{evaluate-commands %sh{
case "$kak_opt_colorcol_mode" in
range) printf '%s' 'add-highlighter -override buffer/colorcol ranges colorcol_ranges';;
replace) printf '%s' 'add-highlighter -override buffer/colorcol replace-ranges colorcol_replace_ranges';;
flag) printf '%s' 'add-highlighter -override buffer/colorcol flag-lines default colorcol_flags';;
*) printf '%s' "echo -debug 'Unknown colorcol mode: $kak_opt_colorcol_mode'";;
esac
}}
define-command colorcol-refresh %{evaluate-commands %sh{
colorcol "$kak_buffile" "$kak_opt_colorcol_mode" "$kak_opt_colorcol_max_flags" "$kak_opt_colorcol_flag_str" "$kak_opt_colorcol_replace_str" "$kak_opt_colorcol_color_full" "$kak_opt_colorcol_background"
}}
define-command colorcol-mode -params 1 -shell-script-candidates %{printf '%s\n%s\n%s' range replace flag} -docstring "Change colorcol mode (flag/range/replace)" %{set buffer colorcol_mode %arg{1};colorcol-refresh;colorcol-update-highlighter}
define-command colorcol-enable %{colorcol-refresh;colorcol-update-highlighter;hook -group colorcol global BufWritePost .* colorcol-refresh}
define-command colorcol-disable %{remove-highlighter buffer/colorcol;remove-hooks global colorcol}
