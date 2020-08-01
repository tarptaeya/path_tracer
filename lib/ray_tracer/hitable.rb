module RayTracer
  class HitRecord
    attr_accessor :t, :p, :n, :material,
      :u, :v
  end
end

module RayTracer
  class Hitable
    def hit(ray, t_min, t_max)
    end
  end
end

module RayTracer
  class Sphere < Hitable
    attr_reader :center, :radius

    def initialize(center, radius, material)
      @center = center
      @radius = radius
      @material = material
    end

    def hit(ray, t_min, t_max)
      oc = ray.origin - @center
      a = ray.direction.dot(ray.direction)
      b = oc.dot(ray.direction)
      c = oc.dot(oc) - @radius * @radius
      d = b * b - a * c
      if d > 0
        temp = (-b - d ** 0.5) / a
        if temp < t_max and temp > t_min
          rec = populate_hit_record(ray, temp)
          return rec
        end

        temp = (-b + d ** 0.5) / a
        if temp < t_max and temp > t_min
          rec = populate_hit_record(ray, temp)
          return rec
        end
      end

      nil
    end

    private

    def populate_hit_record(ray, t)
      rec = HitRecord.new
      rec.t = t
      rec.p = ray.point(t)
      rec.n = (rec.p - @center) / @radius.to_f
      rec.material = @material

      # uv mapping
      x = (rec.p[0] - @center[0]) / @radius.to_f
      y = (rec.p[1] - @center[1]) / @radius.to_f
      z = (rec.p[2] - @center[2]) / @radius.to_f
      phi = Math.atan2(x, z) + Math::PI
      theta = Math.asin(y) + Math::PI / 2
      rec.u = phi / (2 * Math::PI)
      rec.v = theta / Math::PI

      rec
    end
  end
end

module RayTracer
  class HitableList < Hitable
    def initialize(objects)
      @objects = objects
    end

    def hit(ray, t_min, t_max)
      t_curr = t_max
      rec = nil
      for obj in @objects
        if rec1 = obj.hit(ray, t_min, t_curr)
          rec = rec1
          t_curr = rec.t
        end
      end

      rec
    end
  end
end
