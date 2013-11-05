module TokensHelper

  def filter_checked?(name)
    params[name] == '1'
  end

end
