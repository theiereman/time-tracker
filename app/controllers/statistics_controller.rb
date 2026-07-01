class StatisticsController < ApplicationController
  include StatisticsPresentable

  def show
    @shareable = true
    present_statistics_for(Current.user)
  end
end
