require 'retmx'
require 'retmx/sdl'

abort "#{$0}: <file .tmx> <layer name>" if ARGV.size != 2


SDL.init(SDL::INIT_VIDEO)
$quit = false

tmx = RETMX.load(ARGV[0])
tmxsdl = RETMX::TMXSDL.new(tmx)
$screen = SDL.setVideoMode(640, 480, 0, 0)


#Blit specific layer
#crop for blit
#tmxsdl.blit_layers(0,0,9,8, $screen, 0, 0)
#at once
#tmxsdl.put_layers($screen, 0, 0)
#one layer
#tmxsdl.put_layer(ARGV[1], $screen, 0, 0)
$camera = Struct.new(:x, :y, :w, :h).new(0, 0, 640, 480)

until $quit
  e = SDL::Event.wait
  case e
  when SDL::Event::Quit
    $quit = true
  when SDL::Event::KeyDown
    case e.sym
    when SDL::Key::UP
      $camera.y -= 32
    when SDL::Key::DOWN
      $camera.y += 32
    when SDL::Key::LEFT
        $camera.x -= 32
    when SDL::Key::RIGHT
      $camera.x += 32
    end
    $camera.y = 0 if $camera.y < 0
    $camera.x = 0 if $camera.x < 0
  end

  #unit by tiles
  #tmxsdl.blit_layer('fondo',1,0,20,15, $screen, 0, 0)
  #by pixels !!:)
  tmxsdl.blit_layer_pixel('fondo',$camera.x, $camera.y, $camera.w, $camera.h, $screen, 0, 0)
  $screen.flip
end
