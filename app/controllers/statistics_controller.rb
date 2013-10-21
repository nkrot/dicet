class StatisticsController < ApplicationController
  skip_before_filter :require_login, only: [ :compute ]

  def recompute
    Statistic.recompute
    render text: "hello"
  end

end
