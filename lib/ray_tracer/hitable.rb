module RayTracer
  class HitRecord
    attr_accessor :t, :p, :n, :material
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
          rec = popupate_hit_record(ray, temp)
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

    def popupate_hit_record(ray, t)
      rec = HitRecord.new
      rec.t = t
      rec.p = ray.point(t)
      rec.n = (rec.p - @center) / @radius.to_f
      rec.material = @material

      rec
    end
  end
end
