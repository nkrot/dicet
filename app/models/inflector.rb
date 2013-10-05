class Inflector
  
  @@host = '10.165.64.112' # syn-proc2
#  @@host = 'localhost'
  @@port = 3001 # this value is hardcoded into bin/syn_ldb_server

  def self.tcp_socket_available?
    is_alive = false
    puts "Checking tcp server"
    begin
      server = TCPSocket.open(@@host, @@port)
    rescue Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
      puts "No server for syn_ldb discovered at #{@@host}:#{@@port}"
      puts "Exception caught: #{e}"
    else
      puts "Server for syn_ldb discovered at #{@@host}:#{@@port}"
      is_alive = true
      server.close
    end
    is_alive
  end

  # all trg_words are Word.new {tag=Tag, text=nil}
  def self.convert(src_words, trg_words)
    src_words.each do |sw|
      trg_words.each do |tw|
        next  unless tw.empty?
        tw.text = @@syn_ldb.call(sw.text, sw.tag.name, tw.tag.name)
      end
    end
  end

  private

  def self.convert_with_pipe(src_word, src_tag, trg_tag)
#    puts "Converting #{src_word}_#{src_tag} --> #{trg_tag}"
    @@cmd.puts "convert #{src_tag} #{trg_tag} #{src_word.encode("windows-1252")}"
    res = @@cmd.gets.chomp
    res.empty? ? nil : res.encode("UTF-8", "Windows-1252")
  end

  def self.convert_with_remote_server(src_word, src_tag, trg_tag)
    server = TCPSocket.open(@@host, @@port)
#    puts "Converting #{src_word}_#{src_tag} --> #{trg_tag}"
    server.puts "convert #{src_tag} #{trg_tag} #{src_word.encode("windows-1252")}"
    res = server.gets.chomp
    server.close
    res.empty? ? nil : res.encode("UTF-8", "Windows-1252")
  end

  def self.convert_non_available(src_word, src_tag, trg_tag)
    "ERROR: no access to syn_ldb utility"
  end

  public

  # To convert words between tags, the ProSAO1 syn_ldb utility is used,
  # Inflector tries to discover an available instance of the utility
  # checking the following:
  # 1. first, check if a prosao1 is available in the environment
  # 2. then check if there is a server running at @@server:@@port
  # 3. if both the above fail, use default procedure

  if ENV['LDBPATH']
    @@path = "ENV['LDBPATH']/../syn_ldb"

    puts "Starting @@path"
    @@cmd = IO.popen(@@path, "w+")
    @@syn_ldb = Proc.new {|sw, st, tt| Inflector.convert_with_pipe(sw, st, tt) }

  elsif self.tcp_socket_available?
    @@syn_ldb = Proc.new {|sw, st, tt| Inflector.convert_with_remote_server(sw, st, tt) }

  else
    # fake script
#    @@path = Rails.root.join("bin/syn_ldb").to_s
#    puts "Starting fake #{@@path}"
#    @@cmd = IO.popen(@@path, "w+")
#    @@syn_ldb = Proc.new {|sw, st, tt| Inflector.convert_with_pipe(sw, st, tt) }

    @@syn_ldb = Proc.new {|sw, st, tt| Inflector.convert_non_available(sw, st, tt)}
  end

end
