module Stocks
  class UpdateForm
    attr_reader :stock, :params, :errors

    def initialize(stock, params)
      @stock = stock
      @params = params
    end

    def save
      ApplicationRecord.transaction do
        stock.assign_attributes( bearer: bearer, name: params[:name] )

        if stock.valid?
          stock.save! if stock.changed?
          true
        else
          @errors = stock.errors.full_messages
          false
        end
      rescue ActiveRecord::RecordNotUnique
        @errors = 'Name has already been taken'
        false
      end
    end

    private

    def bearer
      @bearer ||= if params[:bearer_name].present?
                    bearer = Bearer.find_or_create_by!(name: params[:bearer_name])
                  else
                    stock.bearer
                  end
    end
  end
end
