module TokensHelper

  def filter_checked?(name)
    params[name] == '1'
  end

  def hi_if_ordered_by(colname)
    if @order_by_column.to_s == colname.to_s
      'orderby'
    else
      ''
    end
  end

  def show_take token
    token.taken? ? 'none' : ''
  end

  def show_drop token
    token.taken? ? '' : 'none'
  end

  def show_setbad token
    token.good? ? '' : 'none'
  end

  def show_setgood token
    token.good? ? 'none' : ''
  end

end
