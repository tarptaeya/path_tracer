module RayTracer
  MAX_DEPTH = 10

  class Scene
    def initialize(width, height, camera, world)
      @width = width
      @height = height
      @camera = camera
      @world = world
    end

    def render(ns=1, file="output.ppm")
      puts "writing #{file}"
      data = []
      (0...@height).each do |y|
        (0...@width).each do |x|

          col = Vector[0, 0, 0]
          (1..ns).each do
            i = (x + Random.rand) / @width.to_f
            j = (y + Random.rand) / @height.to_f
            ray = @camera.ray(i, j)
            col += color(ray)
          end
          col /= ns.to_f
          data << col

          percentage = (y * @width + x) * 100 / (@width * @height - 1)
          printf("\r[%-20s] %d%%", "=" * (percentage / 5), percentage)
        end
      end
      puts

      File.open(file, "w") do |f|
        f << "P3\n"
        f << "#{@width} #{@height}\n"
        f << "255\n"
        (0...@height).reverse_each do |y|
          (0...@width).each do |x|
            col = data[y * @width + x]
            r = (255.99 * col[0] ** 0.5).truncate
            g = (255.99 * col[1] ** 0.5).truncate
            b = (255.99 * col[2] ** 0.5).truncate
            f << "#{r} #{g} #{b}\n"
          end
        end
      end
    end

    private

    def color(ray, depth=0)
      if rec = @world.hit(ray, 0.001, Float::INFINITY)
        material = rec.material
        if depth < MAX_DEPTH and scatter = material.scatter(ray, rec)
          attenuation, scattered = scatter
          attenuation * color(scattered, depth + 1)
        else
          Vector[0, 0, 0]
        end
      else
        # skybox
        d = ray.direction.normalize
        t = 0.5 * (d[1] + 1)
        (1 - t) * Vector[1, 1, 1] + t * Vector[0.5, 0.7, 1.0]
      end
    end
  end
end
