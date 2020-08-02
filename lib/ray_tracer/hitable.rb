module RayTracer
  class HitRecord
    attr_accessor :t, :p, :n, :material,
      :u, :v
  end
end

module RayTracer
  class AABB
    attr_reader :min, :max

    def initialize(min, max)
      @min = min
      @max = max
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

module RayTracer
  class Hitable
    def hit(ray, t_min, t_max)
    end

    def bounding_box
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

    def bounding_box
      min = @center - @radius * Vector[1, 1, 1]
      max = @center + @radius * Vector[1, 1, 1]
      @aabb ||= AABB.new(min, max)
      @aabb
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

module RayTracer
  class BVHNode < Hitable
    def initialize(left, right)
      @left = left
      @right = right

      if right
        b0 = left.bounding_box
        b1 = right.bounding_box
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
        @aabb = AABB.new(min, max)
      else
        @aabb = left.bounding_box
      end
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
      if @aabb.hit(ray, t_min, t_max)
        t = t_max
        rec = nil
        left_hit = false
        right_hit = false

        if @left and  rec1 = @left.hit(ray, t_min, t)
          left_hit = true
          rec = rec1
          t = rec.t
        end

        if @right and rec1 = @right.hit(ray, t_min, t)
          right_hit = true
          rec = rec1
          t = rec.t
        end

        return rec if left_hit or right_hit
      end

      nil
    end

    def bounding_box
      @aabb
    end
  end
end
