require 'assembly-objectfile'

class PreAssembly::ObjectFile < Assembly::ObjectFile

  attr_accessor(
    :exclude_from_content,
    :checksum
  )

  def initialize(params = {})
    super(params[:path], params) # we need to be sure to call Assembly::ObjectFile's constructor to get any defaults set there
    self.checksum         = params[:checksum]
    @exclude_from_content = params[:exclude_from_content]
  end

  def checksum
    @checksum
  end

  def checksum=(value)
    @checksum=value
    self.provider_md5=value # this is an attribute of the Assembly::ObjectFile class
  end

  def <=>(other)
    @relative_path <=> other.relative_path
  end

end
