module WordsHelper

  def links_to_paradigm_edit words
    words.map do |w|
      link_to "#{w.tagname}:#{w.paradigm_id}", edit_paradigm_path(:id => w.paradigm_id)
    end.join(", ")
  end
end
