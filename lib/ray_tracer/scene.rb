module RayTracer
  class Scene
    def initialize(width, height)
      @width = width
      @height = height
    end

    def render(file="output.ppm")
      File.open(file, "w") do |f|
        f << "P3\n"
        f << "#{@width} #{@height}\n"
        f << "255\n"

        (0...@height).reverse_each do |y|
          (0...@width).each do |x|
            r = x / @width.to_f
            g = y / @height.to_f
            b = 0.2

            r = (255.99 * r).truncate
            g = (255.99 * g).truncate
            b = (255.99 * b).truncate

            f << "#{r} #{g} #{b}\n"
          end
        end
      end
    end
  end
end
