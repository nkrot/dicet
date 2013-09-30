class Inflector
  
  @@host = '10.165.64.112' # syn-proc2
  @@port = 3001 # this value is hardcoded into bin/syn_ldb_server

  # TODO: how to start it only once, at app start up
  @@cmd = IO.popen(Rails.root.join("bin/syn_ldb").to_s, "w+")

  # all trg_words are Word.new {tag=Tag, text=nil}
  def convert(src_words, trg_words)
    src_words.each do |sw|
      trg_words.each do |tw|
        next  if tw.text
        tw.text = convert_ll(sw.text, sw.tag.name, tw.tag.name)
      end
    end
  end

  def test_server
    server = TCPSocket.open(@@host, @@port)

    [["VB VBZ run", "runs"],
     ["NNS NN bacteria", "bacterium"]].each do |q,r|
      server.puts "convert #{q}"
      res = server.gets.chomp
      check = r == res ? 'correct' : 'incorrect'
      puts "Server responded with: \"#{res}\", this is #{check}"
    end

    server.close
  end

  private

  def convert_ll(src_word, src_tag, trg_tag)
    puts "Converting #{src_word}_#{src_tag} --> #{trg_tag}"
    @@cmd.puts "convert #{src_tag} #{trg_tag} #{src_word}"
    res = @@cmd.gets.chomp
    # TODO: fix lettercase
    res.empty? ? nil : res
  end

  # return hash
  # {
  #   "VBZ" => [word1, word2,...],
  #   "VBN" => [word]
  # }
  def convert_unused(word, src_tag, trg_tags)

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
