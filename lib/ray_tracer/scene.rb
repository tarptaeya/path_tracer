module RayTracer
  class Scene
    def initialize(width, height, camera, world)
      @width = width
      @height = height
      @camera = camera
      @world = world
    end

    def render(ns=1, file="output.ppm")
      File.open(file, "w") do |f|
        f << "P3\n"
        f << "#{@width} #{@height}\n"
        f << "255\n"

        (0...@height).reverse_each do |y|
          (0...@width).each do |x|

            col = Vector[0, 0, 0]
            (1..ns).each do
              i = (x + Random.rand) / @width.to_f
              j = (y + Random.rand) / @height.to_f
              ray = @camera.ray(i, j)
              col += color(ray)
            end
            col /= ns.to_f


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
      if @world.hit(ray, 0.001, Float::INFINITY)
        Vector[1, 0, 0]
      else
        Vector[1, 1, 1]
      end
    end
  end
end
