module RayTracer
  class Material
    def scatter(ray, rec)
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

    private

    def random_in_unit_sphere
      loop do
        p = 2 * Vector[Random.rand, Random.rand, Random.rand] - Vector[1, 1, 1]
        return p if p.dot(p) < 1
      end
    end
  end
end
