class Activity::CategoriesController < ApplicationController
  before_action :set_activity_category, only: %i[ show edit update destroy ]

  def index
    @activity_categories = Current.user.activity_categories
  end

  def show
  end

  def new
    @activity_category = Activity::Category.new
  end

  def edit
  end

  def create
    @activity_category = Current.user.activity_categories.new(activity_category_params)

    if @activity_category.save
      redirect_to settings_path, notice: "Catégorie créée"
    else
      redirect_to settings_path, alert: @activity_category.errors.full_messages.first
    end
  end

  def update
    if @activity_category.update(activity_category_params)
      redirect_to settings_path
    else
      redirect_to settings_path, alert: @activity_category.errors.full_messages.first
    end
  end

  def destroy
    @activity_category.destroy!
    redirect_to settings_path, notice: "Catégorie supprimée"
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to settings_path, alert: "Impossible de supprimer cette catégorie"
  end

  private

  def set_activity_category
    @activity_category = Current.user.activity_categories.find(params.expect(:id))
  end

  def activity_category_params
    params.expect(activity_category: [ :label ])
  end
end
