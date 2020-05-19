# colorcol
[kakoune](https://kakoune.org) plugin, that displays color previews inline/after target string/in gutter.

For now supported formats are `#rgb`,`#rgba`, `#rrggbb` and `#rrggbbaa`.

## Install
Having [Nim](https://nim-lang.org) installed just do `nimble install colorcol`.

Then in your `kakrc` add `evaluate-commands %sh{ colorcol }`.

Now you can use `colorcol-enable` to activate the plugin and `colorcol-refresh`/`colorcol-refresh-on-save`/`colorcol-refresh-continuous` to recolor buffer manually/on save/as you type.

## Recommended setup
```
evaluate-commands %sh{ colorcol }

hook global WinCreate .* %{
  colorcol-enable
  colorcol-refresh-continuous
}
```
