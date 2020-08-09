require 'path_tracer'

include PathTracer

width = 600
height = 200

checker = GroundCheckerTexture.new(Vector[0.2, 0.2, 0.2], Vector[0.9, 0.9, 0.9], 5)
environment_texture = ImageTexture.new(File.join(__dir__, "environment_1.jpg"))

lookfrom = Vector[0, 1, 4]
lookat = Vector[0, 1, 0]
cam = Camera.new(lookfrom, lookat, Vector[0, 1, 0], 50, width / height.to_f, 0.2, (lookfrom - lookat).magnitude)
world = BVHNode.from_list([
  Sphere.new(Vector[-2, 1, 0], 1.0, Metal.new(ConstTexture.new(Vector[0.95, 0.95, 0.95]), 0)),
  Sphere.new(Vector[0, 1, 0], 1.0, Dielectric.new(1.5)),
  Sphere.new(Vector[2, 1, 0], 1.0, Lambertian.new(ConstTexture.new(Vector[0.3, 0.8, 0.3]))),

  Ground.new(0.0, Lambertian.new(checker)),
  Sphere.new(Vector[0, 0, 0], 1000, DiffuseLight.new(environment_texture)),
])
scene = Scene.new(width, height, cam, world)
scene.render(ns=10, "cover.ppm")
