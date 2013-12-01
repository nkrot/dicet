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

  def link_to_task token
    words = token.words
    if words
      url = new_paradigm_path(word_id: words.first)
      link_to token.task_id, url
    else
      token.task_id
    end
  end
end
