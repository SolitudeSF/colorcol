# colorcol
[kakoune](https://kakoune.org) plugin, that displays color previews inline/near target string/in gutter.

For now supported formats are `#rgb` and `#rrggbb`.

## Install
Having [Nim](https://nim-lang.org) installed just do `nimble install colorcol`.

Then in your `kakrc` add `evaluate-commands %sh{ colorcol }`.

Now you can use `colorcol-enable` to activate the plugin. Colors are refreshed on buffer write.

## Recommended setup
```
evaluate-commands %sh{ colorcol }

hook global WinCreate .* colorcol-enable
```
