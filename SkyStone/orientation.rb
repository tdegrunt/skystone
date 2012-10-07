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

  def get_direction(from, to)
    case
    when to.get_z.to_i < from.get_z.to_i
      :north
    when to.get_z.to_i > from.get_z.to_i
      :south
    when to.get_x.to_i < from.get_x.to_i
      :west
    when to.get_x.to_i > from.get_x.to_i
      :east
    end
  end

  # find the control (lapis) block, from the base
  # java: Block getRelative(int modX, int modY, int modZ)
  def find_and_return_control_block(for_what, type, block)
    case
    when block.get_relative(1, 0, 3).is?(type)
      block.get_relative(1, 0, 3)
    when block.get_relative(-1, 0, 3).is?(type)
      block.get_relative(-1, 0, 3)
    when block.get_relative(1, 0, -3).is?(type)
      block.get_relative(1, 0, -3)
    when block.get_relative(-1, 0, -3).is?(type)
      block.get_relative(-1, 0, -3)
    when block.get_relative(3, 0, 1).is?(type)
      block.get_relative(3, 0, 1)
    when block.get_relative(3, 0, -1).is?(type)
      block.get_relative(3, 0, -1)
    when block.get_relative(-3, 0, 1).is?(type)
      block.get_relative(-3, 0, 1)
    when block.get_relative(-3, 0, -1).is?(type)
      block.get_relative(-3, 0, -1)
    end
  end

  def find_and_return(type, block)
    case
    when block.block_at_real(:north) && block.block_at_real(:north).is?(type)
      block.block_at_real(:north)
    when block.block_at_real(:east) && block.block_at_real(:east).is?(type)
      block.block_at_real(:east)
    when block.block_at_real(:south) && block.block_at_real(:south).is?(type)
      block.block_at_real(:south)
    when block.block_at_real(:west) && block.block_at_real(:west).is?(type)
      block.block_at_real(:west)
    when block.block_at_real(:up) && block.block_at_real(:up).is?(type)
      block.block_at_real(:up)
    when block.block_at_real(:down) && block.block_at_real(:down).is?(type)
      block.block_at_real(:down)
    end
  end

end