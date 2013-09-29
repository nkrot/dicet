require 'spec_helper'

describe ParadigmForm do
  before do
    @nn  = Tag.create!(name: "NN")
    @nns = Tag.create!(name: "NNS")
    @vb  = Tag.create!(name: "VB")
    @vbz = Tag.create!(name: "VBZ")

    @words = {
      "palabras" => {
        "NNS" => Word.create!(text: "palabras", tag: @nns)
      },
      "run" => {
        "VB" => Word.create!(text: "run", tag: @vb), 
        "NN" => Word.create!(text: "run", tag: @nn), 
      },
      "runs" => {
#        "VBZ" => Word.create!(text: "runs", tag: @vbz), 
        "NNS" => Word.create!(text: "runs", tag: @nns), 
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

    # test scenarios:
    # a-la #new -- an empty paradigm
    # after #create -- complete or partial paradigm
#    it
  end

end
