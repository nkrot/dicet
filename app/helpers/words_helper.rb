module WordsHelper

  def each_word_with_link_to_paradigm_edit word
    word.homonyms.each do |w|
      html_options = {'class' => ['lnk_to_pdg']}
      if w.paradigm.dumped?
        html_options['class'] << 'dumped'
      end

      lnk = link_to("#{w.tagname}:#{w.paradigm_id}", edit_paradigm_path(:id => w.paradigm_id, :word_id => word.id), html_options)

      yield w, lnk
    end
  end

  def links_to_paradigm_edit word
    links = []
    each_word_with_link_to_paradigm_edit(word) do |wd, lnk|
      links << lnk
    end
    links
  end

  def select_bullet_image word
    if word.paradigm.review?
      'bullet_red.png'
    elsif word.paradigm.has_comment?
      'bullet_yellow.png'
    else
      'bullet_green.png'
    end
  end
end
