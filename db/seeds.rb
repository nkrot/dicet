# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

tagset = ["!", ["FO", "Formula"], ["FW", "Foreign word"], "(", ")", "LQ", "RQ", "DA", ",", ".", "...", ":", ";", "?", "ABL", "ABN", "ABX", "AP", "APS", "AT", "ATI", "BE", "BED", "BEDZ", "BEG", "BEM", "BEN", "BER", "BEZ", "CC", "CD", "CD-CD", "CD1", "CD1S", "CDS", "CS", "DO", "DOD", "DOZ", "DT", "DTI", "DTS", "DTX", "EX", "HV", "HVD", "HVG", "HVN", "HVZ", "IN", "JJ", "JJR", "JJT", "JNP", "MD", ["NN", "Noun common singular"], ["NNS", "Noun common plural"], "NNP", "NNPS",  ["NNU", "Unit of measurement, singular"], ["NNUS", "Unit of measurement, plural"], "NP", "NPS", "NPL", "NPLS", "NPT", "NPTS", "NR", "NRS", "OD", "PN", "PP$", "PP$$", "PP1A", "PP1AS", "PP1O", "PP1OS", "PP2", "PP3", "PP3A", "PP3AS", "PP3O", "PP3OS", "PPL", "PPLS", "QL", "QLP", "RB", "RBR", "RBT", "RI", "RN", "RP", "TO", "UH", "VB", "VBZ", "VBG", "VBD", "VBN", "WDT", "WP", "WRB", ["XNOT", "Negation particle"], "ZZ", "POS", "JJing", "JJed", "NOTAG"]

tagset.each do |tag| 
  if tag.instance_of? Array
    Tag.create(name: tag.first, description: tag.last)
  else
    Tag.create(name: tag)
  end
end

pdg_types = {
  "nn"  => ["NN", "NNS"],
  "np"  => ["NP", "NPS"],
  "npt" => ["NPT", "NPTS"],
  "npl" => ["NPL", "NPLS"],
  "vb"  => ["VB", "VBZ", "VBG", "VBD", "VBN", "JJing", "JJed"],
  "jj"  => ["JJ", "JJR", "JJT"]
}

pdg_types.each do |name, tags|
  tags.each_with_index do |tag, order|
    t = Tag.where(name: tag).first
    pdg_type = ParadigmType.new do |obj|
      obj.name = name
      obj.order = order
      obj.tag_id = t.id
    end
    pdg_type.save
  end
end
