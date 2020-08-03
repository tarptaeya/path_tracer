module RayTracer
  def random_in_unit_sphere
    loop do
      p = 2 * Vector[Random.rand, Random.rand, Random.rand] - Vector[1, 1, 1]
      return p if p.dot(p) < 1
    end
  end
end
