class Inflector
  
  @@cmd = IO.popen(Rails.root.join("bin/syn_ldb").to_s, "w+")

  # return hash
  # {
  #   "VBZ" => [word1, word2,...],
  #   "VBN" => [word]
  # }
  def convert(word, src_tag, trg_tags)

    if trg_tags.is_a? String
      trg_tags = [ trg_tags ]
    end

    res_words = {}
    trg_tags.each do |trg_tag|
      @@cmd.puts "convert #{src_tag} #{trg_tag} #{word}"
      res = @@cmd.gets.chomp
      res_words [trg_tag] = [ res ]
    end

    res_words
  end

end
