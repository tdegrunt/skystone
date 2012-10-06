module Orientation

  def wind_rotations_for(wind)
    case
    when wind == :north
      [:north, :east, :south, :west]
    when wind == :east
      [:east, :south, :west, :north]
    when wind == :south
      [:south, :west, :north, :east]
    when wind == :west
      [:west, :north, :east, :south]
    end
  end

end