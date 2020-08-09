require 'path_tracer'

include PathTracer

width = 600
height = 200

checker = GroundCheckerTexture.new(Vector[0.2, 0.2, 0.2], Vector[0.9, 0.9, 0.9], 10)
environment_texture = ImageTexture.new(File.join(__dir__, "environment_1.jpg"))

cam = Camera.new(Vector[0, 0, 2], Vector[0, 0, 0], Vector[0, 1, 0], 60, width / height.to_f, 0.2, 2.0)
world = BVHNode.from_list([
  Sphere.new(Vector[-1, 0, 0], 0.5, Metal.new(ConstTexture.new(Vector[0.3, 0.3, 0.8]), 0.3)),
  Sphere.new(Vector[0, 0, 0], 0.5, Metal.new(ConstTexture.new(Vector[0.9, 0.9, 0.9]), 0)),
  Sphere.new(Vector[1, 0, 0], 0.5, Lambertian.new(ConstTexture.new(Vector[0.3, 0.8, 0.3]))),

  Ground.new(-0.5, Lambertian.new(checker)),
  Sphere.new(Vector[0, 0, 0], 1000, DiffuseLight.new(environment_texture)),
])
scene = Scene.new(width, height, cam, world)
scene.render(ns=1, "cover.ppm")
