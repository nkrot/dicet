class ParadigmTag < ActiveRecord::Base
  belongs_to :paradigm_type
  belongs_to :tag

#  default_scope :order => 'order ASC'
end
