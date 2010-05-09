miquire :core, 'retriever'

class User < Retriever::Model

  @@users = Hash.new
  @@idname_id = Hash.new

  # args format
  # key     | value
  # --------+-----------
  # id      | user id
  # idname  | account name
  # nickname| account usual name
  # location| location(not required)
  # detail  | detail
  # profile_image_url | icon

  self.keys = [[:id, :string],
               [:idname, :string],
               [:name, :string],
               [:location, :string],
               [:detail, :string],
               [:profile_image_url, :string],
              ]

  def self.system
    if not defined? @@system then
      @@system = User.new({ :id => 0,
                            :idname => Environment::ACRO,
                            :name => Environment::NAME,
                            :profile_image_url => MUI::Skin.get("icon.png")})
    end
    @@system
  end

  def idname
    self[:idname]
  end

  def follow
    if(@value[:post]) then
      @value[:post].follow(self)
    end
  end

  def inspect
    "User(@#{@value[:idname]})"
  end

  def self.findById(id)
    result = assert_type(User, @@users[id])
    return result if result
  end

  def self.findByIdname(idname)
    id = @@idname_id[idname]
    self.findById(id) if(id)
  end

  def ==(other)
    if other.is_a?(String) then
      @value[:idname] == other
    elsif other.is_a?(User) then
      other[:id] == self[:id]
    end
  end

  def marshal_dump
    raise RuntimeError, 'User cannot marshalize'
  end
end
