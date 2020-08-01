module RayTracer
  class Texture
    def value(u, v, p)
    end
  end
end

module RayTracer
  class ConstTexture < Texture
    def initialize(color)
      @color = color
    end

    def value(u, v, p)
      @color
    end
  end
end

module RayTracer
  class CheckerTexture < Texture
    def initialize(even, odd, k)
      @even = even
      @odd = odd
      @k = k
    end

    def value(u, v, p)
      val = Math.sin(@k * u) * Math.sin(@k * v)
      if val > 0
        @even
      else
        @odd
      end
    end
  end
end
