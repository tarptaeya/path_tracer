module PathTracer
  class Ray
    attr_reader :origin, :direction

    def initialize(origin, direction)
      @origin = origin
      @direction = direction
    end

    def point(t)
      @origin + t * @direction
    end
  end
end
