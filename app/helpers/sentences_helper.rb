module SentencesHelper
  def to_html sent, tokens
    # TODO: use tag() helper
    sent.tokens.map do |tok|
      if tokens.include?(tok)
        '<span class="red">' + tok.text + '</span>'
      else
        tok.text
      end
    end.join(" ")
  end
end
