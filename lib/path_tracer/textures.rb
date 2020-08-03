require 'rmagick'

module PathTracer
  class Texture
    def value(u, v, p)
    end
  end
end

module PathTracer
  class ConstTexture < Texture
    def initialize(color)
      @color = color
    end

    def value(u, v, p)
      @color
    end
  end
end

module PathTracer
  class GroundCheckerTexture < Texture
    def initialize(even, odd, k)
      @even = even
      @odd = odd
      @k = k
    end

    def value(u, v, p)
      val = Math.sin(@k * p[0]) * Math.sin(@k * p[2])
      if val > 0
        @even
      else
        @odd
      end
    end
  end
end

module PathTracer
  class ImageTexture < Texture
    def initialize(file)
      @image = Magick::ImageList.new(file).first
      @width = @image.columns
      @height = @image.rows
    end

    def value(u, v, p)
      x = u * @width
      y = (1 - v) * @height
      pixel = @image.pixel_color(x, y)
      r = pixel.red >> 8
      g = pixel.green >> 8
      b = pixel.blue >> 8
      Vector[r, g, b] / 255.0
    end
  end
end
