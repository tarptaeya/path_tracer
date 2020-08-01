require 'matrix'

class Vector
  def *(x)
    case x
    when Numeric
      els = @elements.collect{|e| e * x}
      self.class.elements(els, false)
    when Matrix
      Matrix.column_vector(self) * x
    when Vector
      els = self.collect2(x).map {|v1, v2| v1 * v2}
      self.class.elements(els, false)
    else
      apply_through_coercion(x, __method__)
    end
  end
end
