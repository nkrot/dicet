class ParadigmTypesController < ApplicationController
  def index
    @title = "Paradigm types"
    @paradigm_types = ParadigmType.all

#    @paradigm_types.each do |pdgt|
#      puts "Tags by type of #{pdgt.name}"
#      puts pdgt.tags.inspect #s.to_a.first.inspect
#    end
  end
end
