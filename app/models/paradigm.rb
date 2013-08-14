class Paradigm < ActiveRecord::Base
  STATUSES = [
     "new",       # in progress
     "ready",     # completed paradigm
     "review",    # needs review
     "dumped"     # was already taken from DB. means that changing it will not affect anything 
    ]

  has_many :words
#  validates_associated :words # TODO: what does it mean?

  validates :status, inclusion: { in: STATUSES, 
    message: "%{value} is not a valid status, should be one of #{STATUSES.join(" ")}"}

end
