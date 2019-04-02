# colorcol
[kakoune](https://kakoune.org) plugin, that displays color previews in gutter.

## Install
Having [Nim](https://nim-lang.org) installed just do `nimble install https://github.com/SolitudeSF/colorcol`.

Then in your `kakrc` add `evaluate-commands %sh{ colorcol }`.

Now you can use `colorcol-enable` to activate the plugin. You can refresh color display with `colorcol-refresh` or you can use `colorcol-auto-refresh` to automatically refresh on buffer write.

## Recommended setup
```
evaluate-commands %sh{ colorcol }

hook global WinCreate .* %{
    colorcol-enable
    colorcol-auto-refresh
}
```
