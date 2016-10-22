retmx_sdl
=========
Renderiza TMX usando libreria *rubysdl*
Render TileMap XML file with *rubysdl*

Actualmente solo orientación *orthogonal*.
Now only works *orthogona*

```ruby
 require 'retmx'
 require 'retmx/sdl'

 tmx = RETMX.load("test.tmx")
 tmxsdl = RETMX::TMXSDL.new(tmx)

 #draw layer to surface
 tmxsdl.put_layer('background', $screen, 0, 0)

 #draw with source tiles
 tmxsdl.blit_layer('layername', 0, 0, 100, 100, $screen, 0,0)

 #draw with source on pixel
 tmxsdl.blit_layer_pixel('layername', 0, 0, 640, 300, $screen, 0, 0)
```
