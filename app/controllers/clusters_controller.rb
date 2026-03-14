class ClustersController < ApplicationController
  def index
    @clusters = WishCluster.order(wishes_count: :desc)
  end

  def show
    @cluster = WishCluster.find(params[:id])
    @wishes = @cluster.wishes.visible.includes(:comments, :votes).order(created_at: :desc)
  end
end
