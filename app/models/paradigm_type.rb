class ParadigmType < ActiveRecord::Base
  has_many :tags

  validates :name, presence: true #, uniqueness: true
end
