module RayTracer
  class Scene
    def initialize(width, height, camera)
      @width = width
      @height = height
      @camera = camera
    end

    def render(file="output.ppm")
      File.open(file, "w") do |f|
        f << "P3\n"
        f << "#{@width} #{@height}\n"
        f << "255\n"

        (0...@height).reverse_each do |y|
          (0...@width).each do |x|
            i = x / @width.to_f
            j = y / @height.to_f

            ray = @camera.ray(i, j)
            col = color(ray)

            r = (255.99 * col[0]).truncate
            g = (255.99 * col[1]).truncate
            b = (255.99 * col[2]).truncate

            f << "#{r} #{g} #{b}\n"
          end
        end
      end
    end

    private

    def color(ray)
      sphere = Sphere.new(Vector[0, 0, 0], 0.5)
      if sphere.hit(ray, 0.001, Float::INFINITY)
        Vector[1, 0, 0]
      else
        Vector[1, 1, 1]
      end
    end
  end
end
