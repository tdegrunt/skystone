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

  def to_sym
    get_type.to_string.downcase.to_sym
  end
  
  def to_string
    if self.respond_to? :get_type_id
      "#{get_type_id}:#{get_data}"
    else
      "#{get_item_type_id}:#{get_data}"
    end
  end
  
  class << self
    def fetch_from(block, type)
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

end