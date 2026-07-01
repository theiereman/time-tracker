class PublicStatisticsController < ApplicationController
  include StatisticsPresentable

  allow_unauthenticated_access only: :show
  layout "public"

  def show
    present_statistics_for(UserProfileLink.find_by!(token: params[:token]).user)
    render "statistics/show"
  end
end
