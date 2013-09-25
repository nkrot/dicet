# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = [["alpha", "alpha@example.com", 111],
         ["beta",  "beta@example.com",  222],
         ["gamma", "gamma@example.com", 333],
         ["delta", "delta@example.com", 444]]

users.each do |user|
  User.create(login: user[0], email: user[1], password: user[2])
end

######################################################################

tagset = ["!", ["FO", "Formula"], ["FW", "Foreign word"], "(", ")", "LQ", "RQ", "DA", ",", ".", "...", ":", ";", "?", "ABL", "ABN", "ABX", "AP", "APS", "AT", "ATI", "BE", "BED", "BEDZ", "BEG", "BEM", "BEN", "BER", "BEZ", "CC", "CD", "CD-CD", "CD1", "CD1S", "CDS", "CS", "DO", "DOD", "DOZ", "DT", "DTI", "DTS", "DTX", "EX", "HV", "HVD", "HVG", "HVN", "HVZ", "IN", "JJ", "JJR", "JJT", "JNP", "MD", ["NN", "Noun common singular"], ["NNS", "Noun common plural"], "NNP", "NNPS",  ["NNU", "Unit of measurement, singular"], ["NNUS", "Unit of measurement, plural"], "NP", "NPS", "NPL", ["NPLS", "Noun proper locative (or may be not) plural"], "NPT", "NPTS", "NR", "NRS", "OD", "PN", "PP$", "PP$$", "PP1A", "PP1AS", "PP1O", "PP1OS", "PP2", "PP3", "PP3A", "PP3AS", "PP3O", "PP3OS", "PPL", "PPLS", "QL", "QLP", "RB", "RBR", "RBT", "RI", "RN", "RP", "TO", "UH", "VB", "VBZ", "VBG", "VBD", "VBN", "WDT", "WP", "WRB", ["XNOT", "Negation particle"], "ZZ", "POS", "JJing", "JJed", ["NOTAG", "Tag unknown. Add something meaningful instead"],
["TYPO", "The word has a spelling mistake"], ["NOTYPO", "Word has no spelling mistakes"]]

tagset.each do |tag|
  if tag.instance_of? Array
    Tag.create(name: tag.first, description: tag.last)
  else
    Tag.create(name: tag)
  end
end

######################################################################

pdg_types = {
  "nn"  => ["NN", "NNS"],
  "np"  => ["NP", "NPS"],
  "npt" => ["NPT", "NPTS"],
  "npl" => ["NPL", "NPLS"],
  "vb"  => ["VB", "VBZ", "VBG", "VBD", "VBN", "JJing", "JJed"],
  "jj"  => ["JJ", "JJR", "JJT", "RB"],
  "rb"  => ["RB", "RBR", "RBT"],
  "other" => ["NOTAG"],
  "typo"  => ["TYPO", "NOTYPO"]
}

pdg_types.each do |name, tags|
  ts = tags.map {|tag| Tag.where(name: tag).first}
  pdg_type = ParadigmType.create(name: name)
  # set the proxytable ParadigmTag, more specifically, this hack sets order field
  # TODO: how to accomplish it in a nicer way?
  ts.each_with_index do |t, idx|
    pdg_type.paradigm_tags << ParadigmTag.create do |pt|
      pt.paradigm_type_id = pdg_type.id
      pt.tag_id           = t.id
      pt.order            = idx
    end
  end
  pdg_type.save
end

######################################################################

# 0 at the beginning means this task will not be assigned to a user
# initially.

tasks = \
[
 ["word", "lamps", "running", "runing", "tasc"],
 ["lamp", "run", "computer", "computers"],
 ["runs", "rain", "wording"],
 ["apple", "Apple", "brutto"],
 [0, "wind", "wander", "wandering", "worded"],
 ["task", "assignee", "doer"],
 ["apples", "raining", "rains"],
 [0, "windy", "winds", "wall", "notes"],
 [0, "chair", "cherry", "advancedly", "advantageously", "omg"],
 [0, "success", "successful", "successfully", "order"],
 [0, "net", "networks", "netto", "dwells"],
 [0, "coin", "coins", "koen", "mosquitoes"],
 [0, "dwarf", "dwell", "dweller", "double", "keys"],
 [0, "enhance", "enhancement", "envisage", "enormous", "enormously", "eloquent"],
 [0, "five", "fake", "fool", "foment", "foster", "fluffy", "lorries"],
 [0, "giant", "grotesque", "gothic", "goblin", "loosing"],
 [0, "kernel", "kompressor", "Kirk", "key", "keyboard"],
 [0, "lousy", "looser", "loose", "lorry"],
 [0, "masterpiece", "moisture", "mosquito"],
 [0, "noise", "niece", "noisy", "nicely"],
 [0, "ordered", "orange", "Orinoco", "onomatopeya"],
]

tasks.each_with_index do |words, idx|
  user_id = nil
  if words.first == 0
    user_id = words.shift
  end

  priority = [10,9,8].sample
  task = Task.new(priority: priority)
  task.words = words.map {|w| Word.new(text: w)}

  unless user_id
    # assign a user
    i = idx - (idx/users.length) * users.length
    user_name = users[i].first
    user = User.find_by(login: user_name)
    task.user = user
  end

  unless task.save
    puts task.errors.full_messages
  end
end
