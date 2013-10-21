class Statistic < ActiveRecord::Base
  belongs_to :token

  def self.recompute
    Token.all.each do |token|
      token.recompute_statistics
    end
  end
end
