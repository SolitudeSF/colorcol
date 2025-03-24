declare-option -hidden int colorcol_timestamp 0
declare-option -hidden range-specs colorcol_ranges
declare-option -hidden range-specs colorcol_replace_ranges
declare-option -hidden line-specs colorcol_flags
declare-option -hidden str colorcol_mode append
declare-option -hidden str colorcol_command_file

declare-option bool colorcol_color_full true
declare-option int colorcol_max_flags 3
declare-option str colorcol_flag_str █
declare-option str colorcol_append_str ■

define-command -hidden colorcol-update-highlighter %{ evaluate-commands %sh{
  case "$kak_opt_colorcol_mode" in
    background|foreground) printf '%s' 'add-highlighter -override window/colorcol ranges colorcol_ranges';;
    append) printf '%s' 'add-highlighter -override window/colorcol replace-ranges colorcol_replace_ranges';;
    flag) printf '%s' 'add-highlighter -override window/colorcol flag-lines default colorcol_flags';;
    *) printf '%s' "echo -debug 'Unknown colorcol mode: $kak_opt_colorcol_mode'";;
  esac
}}

define-command colorcol-refresh %{ evaluate-commands %sh{
  [ "$kak_opt_colorcol_timestamp" -eq "$kak_timestamp" ] && exit
	printf %s "evaluate-commands -draft -no-hooks %{
		execute-keys '%'
		echo -to-file '$kak_response_fifo' %val{selection}
	}" >"$kak_command_fifo"
  colorcol "$kak_opt_colorcol_mode" "$kak_opt_colorcol_max_flags" "$kak_opt_colorcol_flag_str" "$kak_opt_colorcol_append_str" "$kak_opt_colorcol_color_full" "$kak_response_fifo"
  }
  set window colorcol_timestamp %val{timestamp}
}

define-command colorcol-mode -params 1 -shell-script-candidates %{
  printf '%s\n%s\n%s\n%s' background foreground append flag
} -docstring "Change colorcol mode (background/foreground/append/flag)" %{
  set window colorcol_mode %arg{1}
  colorcol-refresh
  colorcol-update-highlighter
}

define-command colorcol-enable %{
  colorcol-update-highlighter
  colorcol-refresh
  hook -group colorcol window BufCreate .* colorcol-refresh
}

define-command colorcol-refresh-continuous %{
  hook -group colorcol window NormalIdle .* colorcol-refresh
  hook -group colorcol window InsertIdle .* colorcol-refresh
}

define-command colorcol-refresh-on-save %{
  hook -group colorcol window BufWritePost .* colorcol-refresh
}

define-command colorcol-disable %{
  remove-highlighter window/colorcol
  remove-hooks window colorcol
}
