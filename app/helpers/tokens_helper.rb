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
end
