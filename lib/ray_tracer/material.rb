module RayTracer
  class Material
    def scatter(ray, rec)
    end

    private

    def random_in_unit_sphere
      loop do
        p = 2 * Vector[Random.rand, Random.rand, Random.rand] - Vector[1, 1, 1]
        return p if p.dot(p) < 1
      end
    end

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
      [@albedo, scattered]
    end
  end
end

module RayTracer
  class Metal < Material
    def initialize(albedo)
      @albedo = albedo
    end

    def scatter(ray, rec)
      reflected = reflect(ray.direction.normalize, rec.n)
      scattered = Ray.new(rec.p, reflected)
      if scattered.direction.dot(rec.n) > 0
        [@albedo, scattered]
      else
        nil
      end
    end
  end
end