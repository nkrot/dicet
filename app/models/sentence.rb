class Sentence < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :tokens, :through => :sentence_tokens

  def self.with_words tokens_params
    joins(:tokens).where(:tokens => tokens_params).distinct
  end

  def self.search params
    if params[:casesensitive] == '1'
      tokens_params = { text: params[:word].strip }
    else
      tokens_params = { upcased_text: params[:word].strip.mb_chars.upcase }
    end
    sentences = Sentence.with_words(tokens_params)
    tokens = Token.where(tokens_params)
    return sentences, tokens
  end

  # TODO: call it from Document.add_file_data?
  def self.add_file_data(data)
    infos = {
      'added_documents'    => 0,
      'added_sentences'    => 0,
      'added_new_words'    => 0, # did not previously exist in DB
      'added_total_words'  => 0  # words in sentences
    }

    data.split(/\n/).each do |line|
      line = line.chomp.strip
      next  if line.empty? || line =~ /^#/

      if line =~ /DOC-SEPARATOR/
        # ...
        next
      end

      sent = Sentence.create # TODO: set document_id

      tokens = line.split
      tokens.each_with_index do |token, pos|
        tok = Token.find_or_create_by(text: token) do |tk|
          tk.upcased_text = token.mb_chars.upcase.to_s
        end
        SentenceToken.create(sentence: sent, token: tok, position: pos)
      end
    end

    infos
  end

end
