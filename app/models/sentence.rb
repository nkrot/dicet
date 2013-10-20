class Sentence < ActiveRecord::Base
  has_many :sentence_tokens
  has_many :tokens, :through => :sentence_tokens
  belongs_to :document

  def self.with_words tokens
    joins(:tokens).where("tokens.id" => tokens).distinct
  end

  def self.search params
    conditions = Hash.new {|h,k| h[k] = []}

    params[:word].split.each do |w|
      if w =~ /^\/.+\/$/
        # recognize /REGEXP/ syntax
        conditions[:regexp] << w[1..-2]
      elsif params[:casesensitive] == '1'
        conditions[:text] << w
      else
        conditions[:upcased_text] << w.mb_chars.upcase
      end
    end

    tokens = Token.find_by_literal_or_regexp(conditions)
    sentences = Sentence.with_words(tokens)

    return sentences, tokens
  end

  # TODO: call it from Document.add_file_data?
  def self.add_file_data(data, fname="unknown")
    infos = {
      'added_documents'    => 0,
      'added_sentences'    => 0,
      'added_new_words'    => 0, # did not previously exist in DB
      'added_total_words'  => 0  # words in sentences
    }

    c_docs = 0
    doc = Document.create(title: "#{fname}::#{c_docs}")

    data.split(/\n/).each do |line|
      line = line.chomp.strip
      next  if line.empty? || line =~ /^#/

      if line =~ /=DOC-SEPARATOR=/
        c_docs += 1
        doc = Document.create(title: "#{fname}::#{c_docs}")
        infos['added_documents'] += 1
        $stderr.puts "Adding new document: #{doc.title}"
        next
      end

      sent = Sentence.create(document: doc)
      infos['added_sentences'] += 1

      tokens = line.split
      tokens.each_with_index do |token, pos|
        tok = Token.find_or_create_by(text: token) do |tk|
          infos['added_new_words'] += 1
          tk.upcased_text = token.mb_chars.upcase.to_s
        end
        SentenceToken.create(sentence: sent, token: tok, position: pos)
      end
    end

    infos
  end

end
