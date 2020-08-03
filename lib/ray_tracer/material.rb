module RayTracer
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
  end
end

module RayTracer
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

module RayTracer
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

module RayTracer
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
