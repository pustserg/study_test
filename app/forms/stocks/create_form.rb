module Stocks
  class CreateForm
    attr_reader :stock, :errors

    def initialize(params)
      @stock = Stock.new(params)
    end

    def save
      if stock.valid?
        stock.save
      else
        @errors = stock.errors.full_messages
        false
      end
    rescue ActiveRecord::RecordNotUnique
      @errors = 'Name has already been taken'
      false
    end
  end
end
