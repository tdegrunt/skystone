module org::bukkit::block::Block

  include Orientation

  def block_at_real(wind, distance=nil)
    face_parm = translate_wind_to(wind, :beta)

    face = face_for_symbol(face_parm) || face_parm
    return nil unless face

    distance ? get_relative(face, distance) : get_relative(face)
  end

  def block_at_side_for(facing, side, distance=nil)
    case facing
    when :east
      case side
      when :left
        block_at_real(:south, distance)
      when :right
        block_at_real(:north, distance)
      end
    when :west
      case side
      when :left
        block_at_real(:north, distance)
      when :right
        block_at_real(:south, distance)
      end
    when :north
      case side
      when :left
        block_at_real(:east, distance)
      when :right
        block_at_real(:west, distance)
      end
    when :south
      case side
      when :left
        block_at_real(:west, distance)
      when :right
        block_at_real(:east, distance)
      end
    end
  end

end