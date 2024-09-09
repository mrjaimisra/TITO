class SomeRubyCodeWithComplexity
  class CustomZeroDivisionError < ZeroDivisionError; end

  attr_reader :foo, :bar

  def intialize(foo, bar)
    @foo = foo
    @bar = bar
  end

  def perform(divisor)
    number_i_care_about = format(foo) + format(bar)
    remainder_after_dividing = number_i_care_about.modulo(divisor)

    puts "This is the remainder: #{remainder_after_dividing}"
  rescue ZeroDivisionError => e
    raise(CustomZeroDivisionError, "Who there... looks like you #{e.message}, friend. No bueno!")
  end

  def format(value)
    value.to_i unless value.is_a?(Integer)
  end
end

SomeRubyCodeWithComplexity.new.perform(0)
