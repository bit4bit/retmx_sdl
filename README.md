retmx_sdl
=========
Renderiza TMX usando libreria *rubysdl*
<code>
...
tmx = RETMX.load("test.tmx")
tmxsdl = RETMX::TMXSDL.new(tmx)
...
tmxsdl.put_layer('background', $screen, 0, 0)
</code>

.

Render TMX Map Form with rubysdl
