class Inflector
  
  @@host = '10.165.64.112' # syn-proc2
  @@port = 3001 # this value is hardcoded into bin/syn_ldb_server

  if ENV['LDBPATH']
    @@path = "ENV['LDBPATH']/../syn_ldb"
    puts "Starting @@path"
    @@cmd = IO.popen(@@path, "w+")
  else
    # fake script
    puts "Starting fake syn_ldb"
    @@cmd = IO.popen(Rails.root.join("bin/syn_ldb").to_s, "w+")
  end

  # all trg_words are Word.new {tag=Tag, text=nil}
  def self.convert(src_words, trg_words)
    src_words.each do |sw|
      trg_words.each do |tw|
        next  unless tw.empty?
        tw.text = Inflector.convert_ll(sw.text, sw.tag.name, tw.tag.name)
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

  def self.convert_ll(src_word, src_tag, trg_tag)
    puts "Converting #{src_word}_#{src_tag} --> #{trg_tag}"
    @@cmd.puts "convert #{src_tag} #{trg_tag} #{src_word.encode("windows-1252")}"
    res = @@cmd.gets.chomp
    res.empty? ? nil : res.encode("UTF-8", "Windows-1252")
  end

end
