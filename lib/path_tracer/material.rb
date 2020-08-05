module PathTracer
  class Material
    def scatter(ray, rec)
    end

    def emitted(u, v, p)
      Vector[0, 0, 0]
    end

    private

    def reflect(v, n)
      v - 2 * v.dot(n) * n
    end

    def refract(i, n, ni_over_nt)
      cos_i = -i.dot(n)
      cos_r_squared = 1 - (ni_over_nt) ** 2 * (1 - cos_i ** 2)
      if cos_r_squared > 0
        cos_r = cos_r_squared ** 0.5
        ni_over_nt * i + (ni_over_nt * cos_i - cos_r) * n
      else
        nil
      end
    end
  end
end

module PathTracer
  class Lambertian < Material
    def initialize(albedo)
      @albedo = albedo
    end

    def scatter(ray, rec)
      target = rec.p + rec.n + random_in_unit_sphere
      scattered = Ray.new(rec.p, target - rec.p)
      attenuation = @albedo.value(rec.u, rec.v, rec.p)
      [attenuation, scattered]
    end
  end
end

module PathTracer
  class Metal < Material
    def initialize(albedo, fuzz=0)
      @albedo = albedo
      @fuzz = fuzz
    end

    def scatter(ray, rec)
      reflected = reflect(ray.direction.normalize, rec.n)
      scattered = Ray.new(rec.p, reflected + @fuzz * random_in_unit_sphere)
      if scattered.direction.dot(rec.n) > 0
        attenuation = @albedo.value(rec.u, rec.v, rec.p)
        [attenuation, scattered]
      else
        nil
      end
    end
  end
end

module PathTracer
  class Dielectric < Material
    def initialize(refractive_index, albedo=ConstTexture.new(Vector[1, 1, 1]))
      @refractive_index = refractive_index
      @albedo = albedo
    end

    def scatter(ray, rec)
      outer_normal = rec.n
      ni_over_nt = 1.0 / @refractive_index
      if ray.direction.dot(rec.n) > 0
        outer_normal *= -1.0
        ni_over_nt = 1.0 / ni_over_nt
      end

      if refracted = refract(ray.direction, outer_normal, ni_over_nt)
        scattered = Ray.new(rec.p, refracted)
        attenuation = @albedo.value(rec.u, rec.v, rec.p)
        [attenuation, scattered]
      else
        nil
      end
    end
  end
end

module PathTracer
  class DiffuseLight < Material
    def initialize(emit)
      @emit = emit
    end

    def scatter(ray, rec)
      nil
    end

    def emitted(u, v, p)
      @emit.value(u, v, p)
    end
  end
end
