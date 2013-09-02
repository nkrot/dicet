module WordsHelper

  def links_to_paradigm_edit word
    word.homonyms.map do |w|
      link_to "#{w.tagname}:#{w.paradigm_id}", edit_paradigm_path(:id => w.paradigm_id, :word_id => word.id)
    end.join(", ")
  end
end
