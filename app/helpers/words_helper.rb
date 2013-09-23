module WordsHelper

  def links_to_paradigm_edit word
    word.homonyms.map do |w|
      html_options = {'class' => ['lnk_to_pdg']}
      if w.paradigm.dumped?
        html_options['class'] << 'dumped'
      end

      link_to "#{w.tagname}:#{w.paradigm_id}", edit_paradigm_path(:id => w.paradigm_id, :word_id => word.id), html_options
    end.join(", ")
  end
end
