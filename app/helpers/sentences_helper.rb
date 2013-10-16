module SentencesHelper

  def to_html sent, tokens
    sent.tokens.map do |tok|
      if tokens.include?(tok)
        hi_found(escape_once(tok.text))
      else
        escape_once(tok.text)
      end
    end.join(" ")
  end

  # highlight as found
  def hi_found str
    "<span class='found_word'>#{str}</span>"
  end
end
