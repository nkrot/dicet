require 'spec_helper'

describe Paradigm do
  before { @paradigm = Paradigm.new(status: "new", comment: "Just completed")}

  subject { @paradigm }

  it { should respond_to :status }
  it { should respond_to :comment }

  describe "when status is valid" do
    before { @paradigm.status = "new" }
    it { should be_valid }

    before { @paradigm.status = "ready" }
    it { should be_valid }

    before { @paradigm.status = "review" }
    it { should be_valid }

    before { @paradigm.status = "dumped" }
    it { should be_valid }
  end

  describe "when status is invalid" do
    before { @paradigm.status = "hello" }
    it { should_not be_valid }

    before { @paradigm.status = "" }
    it { should_not be_valid }
  end
end
