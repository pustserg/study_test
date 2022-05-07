class StocksController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    # TO BE DISCUSSED, do we need any pagination?
    stocks = Stock.where(bearer_id: params[:bearer_id])

    render json: stocks.map { |s| { id: s.id, name: s.name } }
  end

  def show
    render json: { id: stock.id, name: stock.name, bearer_name: stock.bearer.name }
  end

  def create
    form = Stocks::CreateForm.new(create_params)

    if form.save
      render json: { id: form.stock.id, name: form.stock.name, bearer_name: form.stock.bearer.name }, status: :created
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def update
    form = Stocks::UpdateForm.new(stock, update_params)

    if form.save && form.stock.reload.bearer_id.to_s == params[:bearer_id].to_s
      render json: { id: form.stock.id, name: form.stock.name, bearer_name: form.stock.bearer.name }
    elsif form.save
      # To be discussed: we do not want to render stock that belongs to other bearer
      head :ok
    else
      render json: { errors: form.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if stock.destroy
      head :ok
    else
      render json: { errors: stock.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def stock
    @stock ||= Stock.find_by!(bearer_id: params[:bearer_id], id: params[:id])
  end

  def render_404
    head :not_found
  end

  def create_params
    params.require(:stock).permit(:name).merge(bearer_id: params[:bearer_id]).to_h
  end

  def update_params
    params.require(:stock).permit(:name, :bearer_name).to_h
  end
end
