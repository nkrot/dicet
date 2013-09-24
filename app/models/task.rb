class Task < ActiveRecord::Base
  belongs_to :user
  has_many :words

  # defaults
  NUMWORDS = 5 # default size of the task - number of words in the task
  PRIORITY = 9
end
