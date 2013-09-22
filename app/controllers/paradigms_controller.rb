class ParadigmsController < ApplicationController

#  before_filter :set_no_cache # no effect, maybe the issue is not in caching

  # skip login for actions that are supposed to be used from command line
  # with utilities like curl
  skip_before_filter :require_login, only: [ :dump ]

  def index
    # show all
    @paradigms = Paradigm.all
  end

  # TODO: unnecessary?
  def show
    @paradigm = Paradigm.find(params[:id])
    @title = "Paradigm"
  end

  def new
    @title = "Add a new paradigm"

    @paradigm_types = ParadigmType.all.map do |pdgt|
      Paradigm.new(paradigm_type_id: pdgt.id)
    end

    @paradigms = []
    if params[:word_id]
      @current_word = Word.find(params[:word_id])
      @paradigms = Word.where(text: @current_word.text).map(&:paradigm).uniq.compact # => Array
#      puts "WORD_PARADIGMS: (#{@paradigms.class})"
#      puts @paradigms.inspect
    end
  end

  def create
    # bring a new paradigm and save it to db
    pdg_id = save_paradigms params

    @paradigm = Paradigm.find(pdg_id)
    
    # TODO: get rid of it @idx
    @idx = params[:pdg].keys.first # params = {..., 'pdg'=> {'1' => {...}}}
    @page_section_id = params[:page_section_id]
    @current_word = Word.find(params[:word_id])

    render action: 'new_paradigm_of_type'
  end

  def new_paradigm_of_type
#    puts "(in paradigms/new_paradigm_of_type) #{params.inspect}"

    @paradigm = Paradigm.new(paradigm_type_id: params[:id])
    @idx = 1
    @page_section_id = params[:page_section_id]
    @current_word = Word.find(params[:word_id])
  end

  def edit
    @title = "Edit paradigm"
    @current_word = Word.find_by(id: params[:word_id])
    @paradigm = Paradigm.find(params[:id])
    @idx = 1
    @page_section_id = "paradigm_data_#{@idx}"
  end

  def update
#    puts "PARAMS: #{params.inspect}"

    update_paradigm(params)

    # TODO: same as in #edit
    @title = "Edit paradigm"
    @current_word = Word.find_by(id: params[:word_id]) # TODO: what if it has been deleted in update_paradigm?
    @paradigm = Paradigm.find(params[:id])
    @idx = 1
    @page_section_id = params[:page_section_id]
  end

  def destroy
#    puts "(DESTROY): #{params}"

    pdg = Paradigm.find(params[:id])
    if debug=false
      puts "Deleting #{pdg.inspect}"
      puts "WORDS: #{pdg.words.length}"
    end
    pdg.words.each { |word| word.suicide }
    pdg.destroy

    @page_section_id = params[:page_section_id]
  end

  def dump
#    puts "(DUMP): #{params.inspect}"
    attrs = params.select {|k,v| k == "status"}

    @paradigms = Paradigm.all
    @paradigms = @paradigms.where(attrs)  if attrs
 
    render formats: [:text]
  end

  private

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def update_paradigm params
    debug = false
    puts params.inspect  if debug

    pdg = Paradigm.find(params[:id])

    each_paradigm_2(params) do |pdg_type_id, tag_word_data, extras|
      # update paradigm fields
      attrs = {
#        paradigm_type_id: pdg_type_id, # no change must happen in #edit/#update
        comment: extras["comment"],
        status:  extras["status"]
      }
      pdg.update_attributes(attrs)

      # now update words linked to the paradigm
      each_word(tag_word_data) do |tag_id, old_word, new_word|
        puts "Compare: #{old_word.inspect} vs. #{new_word.inspect}"  if debug
        if !old_word && !new_word
          # this happens if the user first added a new word+tag (w/o saving)
          # and then marked it for deletion
        elsif old_word && ! new_word
          # the old word was marked for deletion
          old_word.suicide
        elsif old_word
          old_word.update_from(new_word)
        else
          # newly added word+tag pair
          new_word.paradigm = pdg
          new_word.save
        end
      end
    end
  end

  # PARAMS
  #  "word_id"=>"17",
  #  "pdg"=>{
  #    "1"=>{      # index of the pdg on the page -> can be ignored
  #      "5"=>{    # paradigm_type.id
  #        "96"=>{ # tag.id=96
  #          # word/tag pair #0, 0 can be ignored
  #          "0"=>{"tag"=>"VB", "101"=>"word" ...},   # word.id=101
  #          # word/tag pair #1, 1 can be ignored
  #          "1"=>{"tag"=>"VB", "106"=>"word" ...}},  # word.id=106
  #        "97"=>{
  #          "2"=>{"tag"=>"VBZ", "102"=>"words" ...},
  #          "3"=>{"tag"=>"VBZ", "107"=>"words" ...}},
  #        "98"=>{
  #          "4"=>{"tag"=>"VBG", "10"=>"wording" ...},
  #          "5"=>{"tag"=>"VBG", "108"=>"wording" ...}},
  #        "99"=>{
  #          "6"=>{"tag"=>"VBD", "17"=>"worded" ...},
  #          "7"=>{"tag"=>"VBD", "109"=>"worded" ...}},
  #        "100"=>{
  #          "8"=>{"tag"=>"VBN", "103"=>"worded" ...},
  #          "9"=>{"tag"=>"VBN", "110"=>"worded" ...}},
  #        "107"=>{
  #          "10"=>{"tag"=>"JJing", "104"=>"word",    "deleted"=>"true" },
  #          "11"=>{"tag"=>"JJing", "111"=>"wording", "deleted"=>""     }},
  #        "108"=>{
  #          "12"=>{"tag"=>"JJed", "105"=>"word" ...},
  #          "13"=>{"tag"=>"JJed", "112"=>"worded" ...}},
  #        "extras"=>{"comment"=>"", "status"=>"ready"}}}},
  #  "commit"=>"Save", "id"=>"5"}

  def each_paradigm_2 params
    params[:pdg].each_value do |pdgtid_data|
      pdgtid_data.each do |pdg_type_id, tag_word_data|
        extras = tag_word_data["extras"]
        tag_word_data.delete_if {|k,v| k == "extras" }
        # tag_word_data is a hash of the form:
        #   "96"=>{ # tag.id=96
        #     # word/tag pair #0, 0 can be ignored
        #     "0"=>{"tag"=>"VB", "101"=>"word", "deleted"=>""},   # word.id=101
        #     # word/tag pair #1, 1 can be ignored
        #     "1"=>{"tag"=>"VB", "106"=>"word", "deleted"=>""}},  # word.id=106
        yield pdg_type_id, tag_word_data, extras
      end
    end
  end

  def each_word tag_word_data
    tag_word_data.each do |tag_id, hash|
      # "0"=>{"tag"=>"VB", "101"=>"run", "deleted=>""},   # word.id=101
      #   or w/o old_word
      # "0"=>{"tag"=>"VB", "word"=>"run", "deleted"=>""},  # no word.id
      #   or with deleted set to true
      # "4"=>{"tag"=>"NNS", "128"=>"palabras", "deleted"=>"true"}
      hash.each do |num, tw_hash|
        old_word = nil
        if tw_hash.key? Word.label
          # no old word
          word_id = Word.label
        else
          # old_word is set from word.id
          word_id = tw_hash.keys.detect {|k| k =~ /^\d+$/} #=>101
          old_word = Word.find(word_id) # TODO: what if it was deleted in the meanwhile?
        end

        if tw_hash["deleted"].to_s.downcase =~ /^(1|true)/
          # if the word+tag is marked for deletion, we do not need the new word
          # the new word being equal to nil will signal the old word needs to be deleted
          new_word = nil
        else
          # new_word is set from submitted values of the keys "tag" and 101/"word"
          # or is retrieved from db if it is already there and has not yet been taken to a pdg
          word_text = tw_hash[word_id].strip
          attrs = {text: word_text, tag_id: nil, paradigm_id: nil}
          new_word = Word.where(attrs).first_or_initialize
          new_word.tag = Tag.find_by(name: tw_hash["tag"])
        end

        yield tag_id, old_word, new_word
      end
    end
  end

  def save_paradigms params
    debug = false
    puts params  if debug

    pdg_ids = []
    saved = true
    each_paradigm_2(params) do |pdg_type_id, tag_word_data, extras|
      if debug
        puts "pdg_type_id=#{pdg_type_id}"
        puts "tag_word_data: #{tag_word_data.inspect}"
        puts "extras: #{extras.inspect}"
      end
      pdg = Paradigm.new
      attrs = {
        paradigm_type_id: pdg_type_id, 
        comment: extras["comment"],
        status:  extras["status"]
      }
      pdg.update_attributes(attrs)
      saved = pdg.save && saved

      pdg_ids << pdg.id

      # retrieve individual words
      each_word(tag_word_data) do |tag_id, old_word, new_word|
        # tag_id can be ignored (the user may have edited the tag)
        # old_word is not supposed to exist
        # new_word TODO: it can be nil (if deleted=true)
        if debug
          puts "tag_id: #{tag_id}"
          puts "old_word: #{old_word.inspect}"
          puts "new_word: #{new_word.inspect}"
        end

        # TODO: there are more cases, see update_paradigm
        if !old_word && !new_word
          # this happens if the user first added a new word+tag (w/o saving)
          # and then marked it for deletion
        elsif old_word
          old_word.update_from(new_word)
          old_word.paradigm = pdg
          old_word.save
#          puts "Saved: as #{Word.find(old_word.id).inspect}"
        else
          new_word.paradigm = pdg
          new_word.save
        end
      end
    end
    saved

    pdg_ids.first
  end

#  def paradigm_params
#    params.require(:paradigm).permit(:status, :comment)
#  end
end

