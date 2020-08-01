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
