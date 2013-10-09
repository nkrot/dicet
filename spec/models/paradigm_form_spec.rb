require 'spec_helper'

describe ParadigmForm do
  before do
    @nn  = Tag.create!(name: "NN")
    @nns = Tag.create!(name: "NNS")
    @vb  = Tag.create!(name: "VB")
    @vbz = Tag.create!(name: "VBZ")
    @vbg = Tag.create!(name: "VBG")
    @vbd = Tag.create!(name: "VBD")
    @vbn = Tag.create!(name: "VBN")

    @pdgt_nn = ParadigmType.create!(name: "nn")
    [@nn, @nns].each_with_index do |tag, idx|
      @pdgt_nn.paradigm_tags << ParadigmTag.create! do |pt|
        pt.paradigm_type = @pdgt_nn
        pt.tag           = tag
        pt.order         = idx
      end
    end
    @pdgt_nn.save
#    puts @pdgt_nn.inspect
#    puts @pdgt_nn.paradigm_tags.inspect

    @pdgt_vb = ParadigmType.create!(name: "vb")
    [@vb, @vbz, @vbg, @vbd, @vbn].each_with_index do |tag, idx|
      @pdgt_vb.paradigm_tags << ParadigmTag.create! do |pt|
        pt.paradigm_type = @pdgt_vb
        pt.tag           = tag
        pt.order         = idx
      end
    end
    @pdgt_vb.save
#    puts @pdgt_vb.inspect
#    puts @pdgt_vb.paradigm_tags.inspect

    @pdgs = {
      "palabras" => {
        "nn" => Paradigm.create!(paradigm_type: @pdgt_nn, status: 'ready')
      },
      "run" => {
        "vb" => Paradigm.create!(paradigm_type: @pdgt_vb, status: 'ready'),
        "nn" => Paradigm.create!(paradigm_type: @pdgt_nn, status: 'ready')
      },
      "mosquitos" => {
        "vb" => Paradigm.create!(paradigm_type: @pdgt_vb, status: 'ready'),
      }
    }

    # NOTE, when a word is assigned a tag, it also gets a paradigm_id
    @words = {
      "palabras" => {
        "NNS" => Word.create!(text: "palabras", tag: @nns, paradigm: @pdgs["palabras"]["nn"])
      },
      "run" => {
        "VB" => Word.create!(text: "run", tag: @vb, paradigm: @pdgs["run"]["vb"]),
        "NN" => Word.create!(text: "run", tag: @nn, paradigm: @pdgs["run"]["nn"]), 
      },
      "runs" => {
#        "VBZ" => Word.create!(text: "runs", tag: @vbz, paradigm: @pdgs["run"]["vb"]), 
        "NNS" => Word.create!(text: "runs", tag: @nns, paradigm: @pdgs["run"]["nn"]), 
      },
      "Emacs" => {
        "UNKNOWN" => Word.create!(text: "Emacs")
      }
    }

  end

  describe "when initializing from a params hash" do
    before do

      @paradigm_type_id = 3
      @comment = "hello kitty"
      @status = "ready"

      @params = {
        "page_section_id"=>"paradigm_data_0",
        "word_id"=>"7",
        "pdg"=>{
          "0"=>{
            "#{@paradigm_type_id}"=>{ # ex: "3" stands for nn-type paradigm
              "#{@nn.id}"=>{ # tag.id of NN
                "0"=>{"tag"=>"NN", "#{@words["run"]["NN"].id}"=>"run", "deleted"=>"false"}
              },
              "#{@nns.id}"=>{ # tag.id of NNS
                "1" =>{"tag"=>"NNS", "#{@words["runs"]["NNS"].id}"=>"runs", "deleted"=>"false"},
                "9" =>{"tag"=>"NNS", "word"=>"runz", "deleted"=>"false"},
                "10"=>{"tag"=>"VBZ", "word"=>"runs", "deleted"=>"false"}    # obtained by copying NNS-slot and changing it
              },
              "extras"=>{"comment"=>"#{@comment}", "status"=>"#{@status}"}
            }
          }
        }
      }

      @pdgform = ParadigmForm.new @params
    end

    it { @pdgform.should respond_to :extras }
    it { @pdgform.should respond_to :slots }

    it { @pdgform.extras.should be_kind_of Hash }

    it "should have paradigm_type_id" do
      expect( @pdgform.paradigm_type_id ).to eq @paradigm_type_id
    end

    it "should have comment and status in extras" do
      expect( @pdgform.extras["comment"] ).to eq @comment
      expect( @pdgform.comment ).to eq @comment

      expect( @pdgform.extras["status"]  ).to eq @status
      expect( @pdgform.status  ).to eq @status
    end

    it "should respond to predicates about the status" do
      # this predicates are delegated to underying Paradigm object
      expect( @pdgform.review?       ).to be_false
      expect( @pdgform.ready_or_new? ).to be_true

      expect( @pdgform.dumped?       ).to be_false
    end

    it "should have data of the correct type in slots" do
      slots = @params["pdg"]["0"]["#{@paradigm_type_id}"].reject {|k,v| k == "extras"}
      num_slots = slots.values.map(&:length).sum
      expect( @pdgform.slots.length ).to be num_slots

      @pdgform.slots.each { |slot| expect( slot ).to be_kind_of ParadigmForm::Slot }
    end
  end

  describe "when initializing from a Paradigm object" do

    it "that is new (has no words attached), should contain empty Word objects" do
      pdg = Paradigm.new(paradigm_type: @pdgt_nn)
      pdg_form = ParadigmForm.new(pdg)

      pdg_form.slots.each do |sl|
        expect( sl.old_word ).to be_kind_of Word
        expect( sl.new_word ).to be_kind_of Word
      end
    end

    it "that is already in DB, should contain words from DB" do
      wd  = Word.where(text: "run").first
      pdg = wd.paradigm
      pdg_form = ParadigmForm.new(pdg)

      # pdg.words.length counts only words that are in DB ignoring unsaved Words.new
      expect( pdg_form.slots.length ).to eq pdg.tags.length

      pdg.each_word_with_tag do |w, t|
        if w.id
          expect( pdg_form.words ).to include w
        else
          # unsaved words are not in the collections and (looks like) cannot be checked with include
          found = pdg_form.old_words.any? {|w_f|
            w_f.tag_id == w.tag_id && w_f.paradigm_id == w.paradigm_id
          }
          expect( found ).to be_true
        end
      end
    end
  end

  describe "when saving the paradigm" do

    before do
      @params = {}

      @params['mosquito'] = {
        "page_section_id" => "paradigm_data_0", "word_id" => "7",
        "pdg" => {
          "0" => {
            "#{@pdgt_nn.id}" => {
              "#{@nn.id}" => {
                "0"=>{"tag"=>"NN",   "word"=>"mosquito",   "deleted"=>"false"}
              },
              "#{@nns.id}" => {
                "1" =>{"tag"=>"NNS", "word"=>"mosquitos",  "deleted"=>"false"},
                "3" =>{"tag"=>"NNS", "word"=>"mosquitoes", "deleted"=>"false"},
              },
              "extras"=>{"comment"=>"double NNS", "status"=>"ready"}
            }
          }
        }
      }

#      @params['apple']
    end

    
    describe "that is not in DB yet" do

      it "recognize existing words and add unknown words to DB" do
        mosquito_notag = Word.create!(text: 'mosquito')
        mosquitos_vbz  = Word.create!(text: 'mosquitos', tag: @vbz, paradigm: @pdgs['mosquitos']['vb'])

        # check counts before
        expect( Word.where(text: 'mosquito').count   ).to eq 1
        expect( Word.where(text: 'mosquitos').count  ).to eq 1
        expect( Word.where(text: 'mosquitoes').count ).to eq 0

        pdgf = ParadigmForm.new @params['mosquito']
        expect { pdgf.save }.to change{ Paradigm.count }.by 1

        # check counts after
        expect( Word.where(text: 'mosquito').count   ).to eq 1
        expect( Word.where(text: 'mosquitos').count  ).to eq 2
        expect( Word.where(text: 'mosquitoes').count ).to eq 1

        # expectations:
        # + mosquito_notag should get its tag and paradigm attributes set
        # + no other mosquito should be added to db
        _mosquito_notag = Word.find(mosquito_notag.id)
        expect( _mosquito_notag.tag      ).to eq @nn
        expect( _mosquito_notag.paradigm ).not_to be_nil

        # expectations:
        # + mosquito_vbz should not be affected
        # + instead, another instance of mosquito should be created in DB with NNS tag
        _mosquitos_vbz = Word.find(mosquitos_vbz.id)
        expect( _mosquitos_vbz.tag ).to eq @vbz
        expect( Word.where({text: 'mosquitos', tag: @nns}).count ).to eq 1

        # expectations:
        # + mosquitoes should be added to db with NNS tag
        expect( Word.where({text: 'mosquitos', tag: @nns}).count ).to eq 1
      end

      it "should update comment and status fields" do

        pdgf = ParadigmForm.new @params['mosquito']

        expect( pdgf.paradigm.comment ).to be_nil
        expect( pdgf.paradigm.status  ).to be_nil

        expect( pdgf.comment ).to eq 'double NNS'
        expect( pdgf.status  ).to eq 'ready'

        pdgf.save

        expect( pdgf.paradigm.comment ).to eq 'double NNS'
        expect( pdgf.paradigm.status  ).to eq 'ready'

        expect( pdgf.comment ).to eq 'double NNS'
        expect( pdgf.status  ).to eq 'ready'
      end
    end

    describe "that is in DB (we are editing an existing paradigm)" do

      it "word(s) can be added" do
        # initially, we have in DB
        # - Word time_NN
        # - Word times
        # - Paradigm with only one word time_NN
        # we add
        # - existing Word times as NNS to this paradigm
        # - a new Word tempora to this paradigm
        pdg_nn_time = Paradigm.create!(paradigm_type: @pdgt_nn, status: 'review')
        time_nn     = Word.create!(text: 'time', tag: @nn, paradigm: pdg_nn_time)
        times_notag = Word.create!(text: 'times')

        word_count = Word.count

        params = {
          "id" => "#{pdg_nn_time.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_nn.id}" => {
                "#{@nn.id}" => {
                  "0" => {"tag"=>"NN",  "#{time_nn.id}"=>"#{time_nn.text}",  "deleted"=>"false"}
                },
                "#{@nns.id}" => {
                  "1" => {"tag"=>"NNS", "word"=>"#{times_notag.text}",  "deleted"=>"false"},
                  "3" => {"tag"=>"NNS", "word"=>"tempora",              "deleted"=>"false"},
                },
                "extras"=>{"comment"=>"time+times+tempora", "status"=>"ready"}
              }
            }
          }
        }

        # initial state:
        # + there is 1 word in the paradigm
        expect( pdg_nn_time.words.count ).to eq 1

        pdgf = ParadigmForm.new params
        expect { pdgf.save }.not_to change{ Paradigm.count }

        # expectations:
        # + the word that was originally in the paradigm was not affected
        _time_nn = Word.find(time_nn.id)
        expect( _time_nn ).to eq time_nn

        # expectations:
        # + addition finds an existing word in DB and sets its attributes
        _times_nns = Word.find(times_notag.id)
        expect( _times_nns.tag      ).to eq @nns
        expect( _times_nns.paradigm ).to eq pdg_nn_time

        # expectations:
        # + addition creates a new word in DB
        expect( Word.count ).to eq word_count+1
        _tempora_nns = Word.where(text: "tempora").first
        expect( _tempora_nns.tag      ).to eq @nns
        expect( _tempora_nns.paradigm ).to eq pdg_nn_time

        # expectations
        # + now the paradigm has 3 words
        expect( pdg_nn_time.words.count ).to eq 3
      end

      it "word(s) can be deleted" do
        # initially in DB we have
        # - Word time_nn
        # - Word times_nns
        # - Word tempora_nns
        # - Word Zeiten_nns that does not belong to the original word list
        # - a paradigm with time_nn, tempora_nns and Zeiten_nns
        # then we
        # - delete tempora_nns and Zeiten_nns from the paradigm
        # - add times_nns
        # - try adding another word but change our mind
        task = Task.create!
        pdg_nn_time = Paradigm.create!(paradigm_type: @pdgt_nn, status: 'review')
        time_nn     = Word.create!(text: 'time', tag: @nn, paradigm: pdg_nn_time, task: task)
        times_notag = Word.create!(text: 'times')
        tempora_nns = Word.create!(text: 'tempora', tag: @nns, paradigm: pdg_nn_time, task: task)
        zeiten_nns  = Word.create!(text: 'Zeiten',  tag: @nns, paradigm: pdg_nn_time)

        word_count  = Word.count

        params = {
          "id" => "#{pdg_nn_time.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_nn.id}" => {
                "#{@nn.id}" => {
                  "0" => {"tag"=>"NN",  "#{time_nn.id}"=>"#{time_nn.text}",  "deleted"=>"false"}
                },
                "#{@nns.id}" => {
                  "1" => {"tag"=>"NNS", "#{tempora_nns.id}"=>"#{tempora_nns.text}",  "deleted"=>"true"},
                  "5" => {"tag"=>"NNS", "#{zeiten_nns.id}"=>"#{zeiten_nns.text}",    "deleted"=>"true"},
                  "2" => {"tag"=>"NNS", "word"=>"#{times_notag.text}",  "deleted"=>"false"},
                  "3" => {"tag"=>"NNS", "word"=>"", "deleted"=>"true"}, # we changed our mind
                },
                "extras"=>{"comment"=>"time+times-tempora", "status"=>"ready"}
              }
            }
          }
        }

        pdgf = ParadigmForm.new params
        expect{ pdgf.save }.not_to change{ Paradigm.count }

        # expectations
        # + Word tempora was released
        _tempora_nns = Word.find(tempora_nns.id)
        expect( _tempora_nns.tag      ).to be_nil
        expect( _tempora_nns.paradigm ).to be_nil

        # expectations:
        # + Word times was taken into the paradigm
        _times_nns = Word.find(times_notag.id)
        expect( _times_nns.tag      ).to eq @nns
        expect( _times_nns.paradigm ).to eq pdg_nn_time
        
        # expectations:
        # + the word Zeiten_nns was removed from the database
        expect( Word.where(text: zeiten_nns.text) ).to be_empty
        expect( Word.count                        ).to eq word_count-1

        # expectations:
        # + the new paradigm has two words
        expect( pdg_nn_time.words.count ).to eq 2
      end

      it "word.tag can be changed" do
        # we have in DB
        # - Word time_nn
        # - Word times_vbz
        # - a paradigm that groups time_nn and times_vbz
        # we then
        # - change tag of times_vbz to NNS
        pdg_nn_time = Paradigm.create!(paradigm_type: @pdgt_nn, status: 'review')
        time_nn     = Word.create!(text: 'time',  tag: @nn,  paradigm: pdg_nn_time)
        times_vbz   = Word.create!(text: 'times', tag: @vbz, paradigm: pdg_nn_time)

        word_count  = Word.count

        params = {
          "id" => "#{pdg_nn_time.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_nn.id}" => {
                "#{@nn.id}" => {
                  "0" => {"tag"=>"NN",  "#{time_nn.id}"=>"#{time_nn.text}",  "deleted"=>"false"}
                },
                "#{@vbz.id}" => {
                  "1" => {"tag"=>"NNS", "#{times_vbz.id}"=>"#{times_vbz.text}",  "deleted"=>""},
                },
                "extras"=>{"comment"=>"times_vbz->times_nns", "status"=>"ready"}
              }
            }
          }
        }

        # initial state
        # + there are two words in the paradigm
        expect( pdg_nn_time.words.count ).to eq 2

        pdgf = ParadigmForm.new params
        expect { pdgf.save }.not_to change{ Paradigm.count }

        # expectations:
        # + number of words in DB stays the same
        # + number of words in the paradigm stays the same
        expect( Word.count              ).to eq word_count
        expect( pdg_nn_time.words.count ).to eq 2

        # expectations:
        # + tag is changed in the same record record
        # + tag of times_vbz is changed to NNS
        _times_nns = Word.find(times_vbz.id)
        expect( _times_nns.tag      ).to eq @nns
        expect( _times_nns.paradigm ).to eq pdg_nn_time
      end

      it "word.text can be changed, release the old word" do
        # initially we have in DB
        # - Word time_nn
        # - Word times_nns
        # - Word tempora_nns
        # - Paradigm that groups time_nn, tempora_nns
        # then we
        # - replace tempora_nns with times_nns
        task = Task.create!
        pdg_nn_time = Paradigm.create!(paradigm_type: @pdgt_nn, status: 'review')
        time_nn     = Word.create!(text: 'time',    tag: @nn,  paradigm: pdg_nn_time, task: task)
        tempora_nns = Word.create!(text: 'tempora', tag: @nns, paradigm: pdg_nn_time, task: task)
        times_notag = Word.create!(text: 'times')

        word_count  = Word.count

        params = {
          "id" => "#{pdg_nn_time.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_nn.id}" => {
                "#{@nn.id}" => {
                  "0" => {"tag"=>"NN",  "#{time_nn.id}"=>"#{time_nn.text}",  "deleted"=>"false"}
                },
                "#{@nns.id}" => {
                  "1" => {"tag"=>"NNS", "#{tempora_nns.id}"=>"#{times_notag.text}",  "deleted"=>""},
                },
                "extras"=>{"comment"=>"tempora_nns->times_nns", "status"=>"ready"}
              }
            }
          }
        }

        pdgf = ParadigmForm.new params
        expect{ pdgf.save }.not_to change{ Paradigm.count }

        # expectations:
        # + the number of words in the paradigm continues to be 2
        # + the number of words in DB has not changed
        expect( pdg_nn_time.words.count ).to eq 2
        expect( Word.count              ).to eq word_count

        # expectations:
        # + changing text should find another suitable word
        _times_nns = Word.find(times_notag.id)
        expect( _times_nns.paradigm ).to eq pdg_nn_time
        expect( _times_nns.tag      ).to eq @nns

        # expectations:
        # + old word should be released
        _tempora_notag = Word.find(tempora_nns.id)
        expect( _tempora_notag.tag      ).to be_nil
        expect( _tempora_notag.paradigm ).to be_nil
      end

      it "word.text can be changed, delete the old word" do
        # initially we have in DB
        # - Word time_nn
        # - Word times_nns
        # - Paradigm that groups time_nn, tempora_nns
        # then we
        # - replace tempora_nns with times_nns
        task = Task.create!
        pdg_nn_time = Paradigm.create!(paradigm_type: @pdgt_nn, status: 'review')
        time_nn     = Word.create!(text: 'time',    tag: @nn,  paradigm: pdg_nn_time, task: task)
        tempora_nns = Word.create!(text: 'tempora', tag: @nns, paradigm: pdg_nn_time) # added word
        times_notag = Word.create!(text: 'times')

        word_count  = Word.count

        params = {
          "id" => "#{pdg_nn_time.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_nn.id}" => {
                "#{@nn.id}" => {
                  "0" => {"tag"=>"NN",  "#{time_nn.id}"=>"#{time_nn.text}",  "deleted"=>"false"}
                },
                "#{@nns.id}" => {
                  "1" => {"tag"=>"NNS", "#{tempora_nns.id}"=>"#{times_notag.text}",  "deleted"=>""},
                },
                "extras"=>{"comment"=>"tempora_nns->times_nns", "status"=>"ready"}
              }
            }
          }
        }

        pdgf = ParadigmForm.new params
        expect{ pdgf.save }.not_to change{ Paradigm.count }

        # expectations:
        # + the number of words in the paradigm continues to be 2
        # + the number of words in DB decreased, because tempora_nns was deleted
        expect( pdg_nn_time.words.count ).to eq 2
        expect( Word.count              ).to eq word_count-1

        # expectations:
        # + changing text should find another suitable word
        _times_nns = Word.find(times_notag.id)
        expect( _times_nns.paradigm ).to eq pdg_nn_time
        expect( _times_nns.tag      ).to eq @nns

        # expectations:
        # + word that was not originally in Word should be deleted
        expect{ Word.find(tempora_nns.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "word.text and word.tag can be changed at once"


      it "should update comment and status fields of the underlying paradigm", focus: true do

        pdg_vb_read = Paradigm.create!(paradigm_type: @pdgt_vb, status: 'review', comment: 'initial comment')
        read_vb     = Word.create!(text: 'read',  tag: @vb,  paradigm: pdg_vb_read)
        reads_vbz   = Word.create!(text: 'reads', tag: @vbz, paradigm: pdg_vb_read)
        read_vbn    = Word.create!(text: 'read',  tag: @vbn, paradigm: pdg_vb_read)

        params = {
          "id" => "#{pdg_vb_read.id}", # this is mandatory when editing an existing paradigm
          "pdg" => {
            "0" => {
              "#{@pdgt_vb.id}" => {
                "#{@vb.id}" => {
                  "0" => {"tag"=>"VB",  "#{read_vb.id}"=>"#{read_vb.text}",  "deleted"=>"false"}
                },
                "#{@vbz.id}" => {
                  "1" => {"tag"=>"VBZ", "#{reads_vbz.id}"=>"#{reads_vbz.text}",  "deleted"=>""},
                },
                "#{@vbg.id}" => {
                  "2" => {"tag"=>"VBG", "word"=>"",  "deleted"=>""},
                },
                "#{@vbd.id}" => {
                  "3" => {"tag"=>"VBD", "word"=>"",  "deleted"=>""},
                },
                "#{@vbn.id}" => {
                  "4" => {"tag"=>"VBN", "#{read_vbn.id}"=>"#{read_vbn.text}",  "deleted"=>""},
                },
                "extras" => {"comment"=>"updated comment", "status"=>"ready"}
              }
            }
          }
        }

        expect( Word.where(text: 'read').count ).to eq 2
        expect( pdg_vb_read.words.count        ).to eq 3

        pdgf = ParadigmForm.new params

        expect( Word.where(text: 'read').count ).to eq 2
        expect( pdg_vb_read.words.count        ).to eq 3

        expect( pdgf.comment ).to eq 'updated comment'
        expect( pdgf.status  ).to eq 'ready'

        # expectations:
        # + until saved the underlaying paradigm keeps original values
        expect( pdgf.paradigm.comment ).to eq pdg_vb_read.comment
        expect( pdgf.paradigm.status  ).to eq pdg_vb_read.status

        pdgf.save

        expect( Word.where(text: 'read').count ).to eq 2
        expect( pdg_vb_read.words.count        ).to eq 3

        # expectations:
        # + once saved, comment and status fields of the underlying paradigm are updated
        expect( pdgf.paradigm.comment ).to eq 'updated comment'
        expect( pdgf.paradigm.status  ).to eq 'ready'
      end

    end

  end
end
