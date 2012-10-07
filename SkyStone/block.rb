module org::bukkit::block::Block

  include Orientation

  def block_at_real(wind, distance=nil)
    face_parm = translate_wind_to(wind, :beta)

    face = face_for_symbol(face_parm) || face_parm
    return nil unless face

    distance ? get_relative(face, distance) : get_relative(face)
  end

  def block_at_side_for(facing, side, distance=nil)
    wind = side_of_facing(facing, side)
    block_at_real(wind, distance)
  end

end