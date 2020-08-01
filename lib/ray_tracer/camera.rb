require 'matrix'

module RayTracer
  class Camera
    def initialize(lookfrom, lookat, vup, vfov, aspect)
      theta = vfov * Math::PI / 180
      half_height = Math.tan(theta / 2)
      half_width = aspect * half_height
      @origin = lookfrom
      w = (lookfrom - lookat).normalize
      u = vup.cross(w).normalize
      v = w.cross(u)
      @lower_left_corner = @origin - half_width * u - half_height * v - w
      @horizontal = 2 * half_width * u
      @vertical = 2 * half_height * v
    end

    def ray(u, v)
      direction = @lower_left_corner + u * @horizontal + v * @vertical - @origin
      Ray.new(@origin, direction)
    end
  end
end
