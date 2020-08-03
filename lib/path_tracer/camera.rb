module PathTracer
  class Camera
    def initialize(lookfrom, lookat, vup, vfov, aspect, aperture = 0, focus_dist = 1)
      @lens_radius = aperture / 2.0
      theta = vfov * Math::PI / 180
      half_height = Math.tan(theta / 2)
      half_width = aspect * half_height
      @origin = lookfrom
      @w = (lookfrom - lookat).normalize
      @u = vup.cross(@w).normalize
      @v = @w.cross(@u)
      @lower_left_corner = @origin - (half_width * @u + half_height * @v + @w) * focus_dist
      @horizontal = 2 * half_width * focus_dist * @u
      @vertical = 2 * half_height * focus_dist * @v
    end

    def ray(s, t)
      rand = @lens_radius * random_in_unit_sphere
      origin = @origin + @u * rand[0] + @v * rand[1]
      direction = @lower_left_corner + s * @horizontal + t * @vertical - origin
      Ray.new(origin, direction)
    end
  end
end
