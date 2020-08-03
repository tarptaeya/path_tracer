module PathTracer
  class HitRecord
    attr_accessor :t, :p, :n, :material,
      :u, :v
  end
end

module PathTracer
  class AABB
    attr_reader :min, :max

    def initialize(min, max)
      @min = min
      @max = max
    end

    def +(other)
      b0 = self
      b1 = other
      min = Vector[
        [b0.min[0], b1.min[0]].min,
        [b0.min[1], b1.min[1]].min,
        [b0.min[2], b1.min[2]].min,
      ]
      max = Vector[
        [b0.max[0], b1.max[0]].max,
        [b0.max[1], b1.max[1]].max,
        [b0.max[2], b1.max[2]].max,
      ]
      
      AABB.new(min, max)
    end

    def hit(ray, t_min, t_max)
      for i in 0..2
        inv_d = 1.0 / ray.direction[i]
        t0 = (@min[i] - ray.origin[i]) * inv_d
        t1 = (@max[i] - ray.origin[i]) * inv_d
        t0, t1 = t1, t0 if inv_d < 0
        t_min = t0 > t_min ? t0 : t_min
        t_max = t1 < t_max ? t1 : t_max
        return false if t_max <= t_min
      end

      true
    end
  end
end

module PathTracer
  class Hitable
    attr_reader :bounding_box

    def hit(ray, t_min, t_max)
    end
  end
end

module PathTracer
  class Sphere < Hitable
    attr_reader :center, :radius

    def initialize(center, radius, material)
      @center = center
      @radius = radius
      @material = material

      min = @center - @radius * Vector[1, 1, 1]
      max = @center + @radius * Vector[1, 1, 1]
      @bounding_box = AABB.new(min, max)
    end

    def hit(ray, t_min, t_max)
      oc = ray.origin - @center
      a = ray.direction.dot(ray.direction)
      b = oc.dot(ray.direction)
      c = oc.dot(oc) - @radius * @radius
      d = b * b - a * c
      if d > 0
        temp = (-b - d ** 0.5) / a
        if temp < t_max && temp > t_min
          rec = populate_hit_record(ray, temp)
          return rec
        end

        temp = (-b + d ** 0.5) / a
        if temp < t_max && temp > t_min
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
      phi = Math.atan2(rec.n[2], rec.n[0])
      theta = Math.asin(rec.n[1])
      rec.u = 1 - (phi + Math::PI) / (2 * Math::PI)
      rec.v = (theta + Math::PI / 2) / Math::PI

      rec
    end
  end
end

module PathTracer
  class Triangle < Hitable
    def initialize(p, material)
      @p = p
      @material = material

      min = Vector[
        p.map {|i| i[0]}.min,
        p.map {|i| i[1]}.min,
        p.map {|i| i[2]}.min,
      ]
      max = Vector[
        p.map {|i| i[0]}.max,
        p.map {|i| i[1]}.max,
        p.map {|i| i[2]}.max,
      ]
      @bounding_box = AABB.new(min, max)
    end

    def hit(ray, t_min, t_max)
      n = (@p[1] - @p[0]).cross(@p[2] - @p[0]).normalize
      t = (@p[0] - ray.origin).dot(n) / ray.direction.dot(n)
      if t > t_min && t < t_max
        p = ray.point(t)
        hit = true
        hit = hit && ((@p[1] - @p[0]).cross(p - @p[0])).dot(n) >= 0
        hit = hit && ((@p[2] - @p[1]).cross(p - @p[1])).dot(n) >= 0
        hit = hit && ((@p[0] - @p[2]).cross(p - @p[2])).dot(n) >= 0

        if hit
          rec = HitRecord.new
          rec.t = t
          rec.p = p
          rec.n = n
          rec.n *= -1 if ray.direction.dot(n) >= 0
          rec.material = @material
          # todo u, v

          return rec
        end
      end

      nil
    end
  end
end

module PathTracer
  class TriangleMesh < Hitable
    def initialize(file, material)
      @triangles = load_obj_file(file, material)
      @hitable = BVHNode.from_list(@triangles)
      @bounding_box = @hitable.bounding_box
    end

    def hit(ray, t_min, t_max)
      @hitable.hit(ray, t_min, t_max)
    end

    private

    def load_obj_file(file, material)
      vertices = []
      triangles = []

      File.open(file) do |f|
        f.each_line do |line|
          line = line.strip.gsub(/\s+/, " ").split
          case line.first
          when "v"
            v = line.drop(1).map(&:to_f)
            vertices << Vector[*v]
          when "f"
            f = line.drop(1)
              .map {|i| i.split("/").first.to_i - 1}
            p = f.map {|i| vertices[i]}
            triangles << Triangle.new(p, material)
          end
        end
      end

      triangles
    end
  end
end

module PathTracer
  class Ground < Hitable
    def initialize(y, material)
      @y = y
      @material = material
      min = Vector[-Float::INFINITY, y, -Float::INFINITY]
      max = Vector[Float::INFINITY, y, -Float::INFINITY]
      @bounding_box = AABB.new(min, max)
    end

    def hit(ray, t_min, t_max)
      n = Vector[0, 1, 0]
      t = (Vector[0, @y, 0] - ray.origin).dot(n) / ray.direction.dot(n)
      if t > t_min && t < t_max
        rec = HitRecord.new
        rec.t = t
        rec.p = ray.point(t)
        rec.n = n
        rec.material = @material
        rec
      else
        nil
      end
    end
  end
end

module PathTracer
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

module PathTracer
  class BVHNode < Hitable
    def initialize(left, right)
      @left = left
      @right = right

      @bounding_box = left.bounding_box
      @bounding_box += right.bounding_box if right
    end

    def self.from_list(list)
      n = list.count
      axis = (3 * Random.rand).truncate
      list.sort_by! {|x| x.bounding_box.min[axis]}

      if n == 0
        nil
      elsif n == 1
        BVHNode.new(list.first, nil)
      elsif n == 2
        BVHNode.new(list.first, list.last)
      else
        left = from_list(list.take(n / 2))
        right = from_list(list.drop(n / 2))
        BVHNode.new(left, right)
      end
    end

    def hit(ray, t_min, t_max)
      if @bounding_box.hit(ray, t_min, t_max)
        t = t_max
        rec = nil
        left_hit = false
        right_hit = false

        if @left &&  rec1 = @left.hit(ray, t_min, t)
          left_hit = true
          rec = rec1
          t = rec.t
        end

        if @right && rec1 = @right.hit(ray, t_min, t)
          right_hit = true
          rec = rec1
          t = rec.t
        end

        return rec if left_hit or right_hit
      end

      nil
    end
  end
end
