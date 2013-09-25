# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users_file = "db/seeds/users.txt"

File.open(Rails.root.join(users_file)) do |f|
  puts " -- loading users from #{users_file}"
  f.readlines.each do |line|
    line = line.chomp.strip.sub(/\s+#.*$/, "")
    if line =~ /^#/ || line.empty?
      # skip
    elsif line =~ /^(.*[^\s])\s+([^\s]+@[^\s]+)\s+(.+)/
      User.create do |u|
        u.login    = $1
        u.email    = $2
        u.password = $3
      end
    end
  end
end

######################################################################

tagset_file = "db/seeds/tagset_eng.txt"

File.open(Rails.root.join(tagset_file)) do |f|
  puts " -- loading tagset from #{tagset_file}"
  TagsController.add_file_data(f.read)
end

######################################################################

pdg_types_file = "db/seeds/pdg_types_eng.txt"

File.open(Rails.root.join(pdg_types_file)) do |f|
  puts " -- loading paradigm types from #{pdg_types_file}"
  ParadigmType.add_file_data(f.read)
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
#    i = idx - (idx/users.length) * users.length
#    user_name = users[i].first
#    user = User.find_by(login: user_name)
    i = 1 + idx - (idx/User.count) * User.count
    task.user = User.find(i)
  end

  unless task.save
    puts task.errors.full_messages
  end
end
