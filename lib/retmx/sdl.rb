=begin
#Libreria para leer archivo TMX de mapeditor.org
 (C) 2013 Jovany Leandro G.C <bit4bit@riseup.net>

  This file is part of retmx.

    retmx is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    retmx is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
=end

require 'sdl'


module RETMX

  #Wrapper for RETMX and RubySDL
  class TMXSDL
    attr_reader :tmx

    def initialize(tmx)

      case tmx
      when Map
        @tmx = tmx
      when String
        @tmx = RETMX.load(tmx)
      else
        raise RuntimeError, "Need a RETMX::Map or path to .tmx" unless tmx.kind_of? Map
      end

      @data_dir = File.dirname(@tmx.file)
      @tileset_images = {}
      @tmx.tilesets.each {|k,t|
        fimage = File.join(@data_dir, t.image.source)
        if File.exists? fimage or !@tileset_images.include? t.name
          image = SDL::Surface.load(fimage)
          image.setColorKey(SDL::SRCCOLORKEY, t.image.trans.hex) unless t.image.trans.nil?
          @tileset_images[t.name] = image
        end
      }
    end


    #Blit all layers to +surface+ at (+dx+, +dy+)
    #:dx: on tiles
    #:dy: on tiles
    def put_layers(surface, dx, dy)
      raise RuntimeError, "Need SDL::Surface" unless surface.kind_of? SDL::Surface

      @tmx.layers.each {|name, l|
        put_layer(name, surface, dx, dy)
      }
    end

    #Perfoms a blit from entire layer +name+ to +surface+ at (+dx+, +dy+)
    #:dx: on tiles
    #:dy: on tiles
    def put_layer (name, surface, dx, dy)
      raise NameError, "Can get layer of name #{name}" unless @tmx.layers.include? name
      raise RuntimeError, "Need SDL::Surface" unless surface.kind_of? SDL::Surface

      @tmx.layers[name].render {|layer, bx, by, tileset, rect|
        pos = rect
        alpha_now = @tileset_images[tileset.name].alpha
        image = @tileset_images[tileset.name]
        image.setAlpha(SDL::SRCALPHA, layer.opacity * SDL::ALPHA_OPAQUE)

        x =  tileset.tilewidth * (bx + dx)
        y =  tileset.tileheight * (by + dy)

        SDL::Surface.blit(image, pos.x, pos.y, pos.w, pos.h, surface, x, y)
        image.setAlpha(SDL::SRCALPHA, alpha_now)
      }
    end

    #Draws al layer at once
    def blit_layers(sx, sy, sw, sh, surface, dx, dy)
      @tmx.layers.each {|name, layer|
        blit_layer(name, sx, sy, sw, sh, surface, dx, dy)
      }
    end

    #Perfoms a blit from layer at (+sx+,+sy+,+sw+,+sh+) to +surface+ at (+dx+, +dy)
    #:sx: on tiles
    #:sy: on tiles
    #:sw: on tiles
    #:sh: on tiles
    #:dx: on tiles
    #:dy: on tiles
    def blit_layer(name, sx, sy, sw, sh, surface, dx, dy)
      raise NameError, "Can get layer of name #{name}" unless @tmx.layers.include? name
      raise RuntimeError, "Need SDL::Surface" unless surface.kind_of? SDL::Surface

      @tmx.layers[name].render_partial(sx, sy, sw, sh) { |layer, bx, by, tileset, rect|
        pos = rect
        alpha_now = @tileset_images[tileset.name].alpha
        image = @tileset_images[tileset.name]
        image.setAlpha(SDL::SRCALPHA, layer.opacity * SDL::ALPHA_OPAQUE)

        x =  tileset.tilewidth * (bx + dx)
        y =  tileset.tileheight * (by + dy)

        SDL::Surface.blit(image, pos.x, pos.y, pos.w, pos.h, surface, x, y)
        image.setAlpha(SDL::SRCALPHA, alpha_now)
      }
    end

    #Perfoms a blit from layer at (+sx+,+sy+,+sw+,+sh+) to +surface+ at (+dx+, +dy) on pixels
    #:sx: on pixel
    #:sy: on pixel
    #:sw: on pixel
    #:sh: on pixel
    #:dx: on pixel
    #:dy: on pixel
    def blit_layer_pixel(name, sx, sy, sw, sh, surface, dx, dy)
      raise NameError, "Can get layer of name #{name}" unless @tmx.layers.include? name
      raise RuntimeError, "Need SDL::Surface" unless surface.kind_of? SDL::Surface
      #create surface tmp for crop the rectangle ask
      if sw == surface.w && sh == surface.h
        tsurface = surface
      else
        tsurface = SDL::Surface.new(SDL::HWSURFACE|SDL::SRCALPHA, sw, sh, surface.format)
      end
      
      @tmx.layers[name].render_partial_pixel(sx, sy, sw, sh) { |layer, bx, by, tileset, rect|
        pos = rect
        alpha_now = @tileset_images[tileset.name].alpha
        image = @tileset_images[tileset.name]
        image.setAlpha(SDL::SRCALPHA, layer.opacity * SDL::ALPHA_OPAQUE)

        x =  tileset.tilewidth * bx  - (sx % tileset.tilewidth)
        y =  tileset.tileheight * by - (sy % tileset.tileheight)
        x += dx; y += dy
        SDL::Surface.blit(image, pos.x, pos.y, pos.w, pos.h, tsurface, x, y)
        image.setAlpha(SDL::SRCALPHA, alpha_now)
      }

      SDL::Surface.blit(tsurface, 0, 0, 0, 0, surface, dx, dy) unless sw == surface.w && sh == surface.h
    end
  end
end
