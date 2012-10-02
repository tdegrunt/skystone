module org::bukkit::block::Block

  def block_at_real(wind, distance=nil)
    face_parm = translate_wind_to(wind, :beta)

    face = face_for_symbol(face_parm) || face_parm
    return nil unless face

    distance ? get_relative(face, distance) : get_relative(face)
  end

  def translate_wind_to(wind, wut = :real)
    if wut == :beta
      case
      when wind == :north
        :east
      when wind == :south
        :west
      when wind == :east
        :south
      when wind == :west
        :north
      end
    else
      case
      when wind == :north
        :west
      when wind == :south
        :east
      when wind == :east
        :north
      when wind == :west
        :south
      end
    end
  end
end