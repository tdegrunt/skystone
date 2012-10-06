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

  def opposite_of(wind)
    case
    when wind == :north
      :south
    when wind == :east
      :west
    when wind == :south
      :north
    when wind == :west
      :east
    when wind == :up
      :down
    when wind == :down
      :up
    end
  end

end