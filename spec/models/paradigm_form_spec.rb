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
    [@vb, @vbz, @vbg, @vbd, @vbn].each do |tag, idx|
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
        expect( sl.new_word ).to be_nil
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
        pdgf.save

        # check counts after
        expect( Word.where(text: 'mosquito').count   ).to eq 1
        expect( Word.where(text: 'mosquitos').count  ).to eq 2
        expect( Word.where(text: 'mosquitoes').count ).to eq 1

        puts Word.where(text: 'mosquito').inspect
        puts mosquito_notag.inspect # oops, why tag is not updated?

        # expectations:
        # + mosquito_notag should get its tag and paradigm attributes set
        # + no other mosquito should be added to db
        expect( mosquito_notag.tag      ).to eq @nn
        expect( mosquito_notag.paradigm ).not_to be_nil

        # expectations:
        # + mosquito_vbz should not be affected
        # + instead, another instance of mosquito should be created in DB with NNS tag
        expect( mosquitos_vbz.tag ).to eq @vbz
        expect( Word.where({text: 'mosquitos', tag: @nns}).count ).to eq 1

        # expectations:
        # + mosquitoes should be added to db with NNS tag
        expect( Word.where({text: 'mosquitos', tag: @nns}).count ).to eq 1
      end

    end

    describe "that is in DB (we are editing an existing paradigm)" do
      it "tests for updating an existing paradigm"
    end

    it "tests for deletion of individual words"

    it "should update comment and status fields"
  end
end
