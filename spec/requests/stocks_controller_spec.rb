require 'rails_helper'

describe StocksController, type: :request do
  describe 'GET #index' do
    subject { get "/bearers/#{bearer.id}/stocks" }
    let(:bearer) { create :bearer }

    let!(:stocks) { create_list :stock, 3, bearer: bearer }
    let!(:other_bearer_stock) { create :stock }

    it 'returns ok' do
      subject

      expect(response).to have_http_status(:ok)
    end

    it 'returns correct stocks' do
      subject

      expect(response.parsed_body.pluck('id')).to match_array(stocks.map(&:id))
    end

    it 'does not return other bearer stocks' do
      subject

      expect(response.parsed_body.pluck('id')).not_to include(other_bearer_stock.id)
    end
  end

  describe 'GET #show' do
    context 'when stock exists' do
      subject { get "/bearers/#{stock.bearer.id}/stocks/#{stock.id}" }

      let(:stock) { create :stock }

      it 'returns correct response' do
        subject

        expect(response.parsed_body).to eq({ id: stock.id, name: stock.name, bearer_name: stock.bearer.name }.as_json)
      end
    end

    context 'when stock does not exist' do
      subject { get "/bearers/#{bearer.id}/stocks/-1" }

      let(:bearer) { create :bearer }

      it 'returns 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    subject { post "/bearers/#{bearer.id}/stocks", params: params }

    let(:bearer) { create :bearer }

    context 'with unique name' do
      let(:params) do
        {
          stock: {
            name: Faker::Name.name
          }
        }
      end

      it 'is success' do
        subject

        expect(response).to have_http_status(:created)
      end

      it 'creates bearer stock' do
        expect { subject }.to change { bearer.stocks.count }.by(1)
      end

      it 'renders created stock' do
        subject

        stock = Stock.last

        expect(response.parsed_body).to eq({ id: stock.id, name: stock.name, bearer_name: stock.bearer.name }.as_json)
      end
    end

    context 'with not unique name' do
      let(:stock) { create :stock }

      let(:params) do
        {
          stock: {
            name: stock.name
          }
        }
      end

      it 'is not success' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders error' do
        subject

        expect(response.parsed_body['errors']).to eq ['Name has already been taken']
      end
    end
  end

  describe 'PUT #update' do
    context 'when stock exists' do
      subject { put "/bearers/#{stock.bearer.id}/stocks/#{stock.id}", params: params }

      let!(:bearer) { create :bearer }
      let(:stock) { create :stock, bearer: bearer }

      context 'with unique name' do
        context 'with same bearer' do
          let(:params) do
            {
              stock: {
                name: Faker::Name.unique.name
              }
            }
          end

          it 'is success' do
            subject

            expect(response).to have_http_status(:ok)
          end

          it 'changes stock name' do
            expect { subject }.to change { stock.reload.name }.to(params.dig(:stock, :name))
          end

          it 'renders updated stock' do
            subject

            stock = Stock.last

            expect(response.parsed_body).to eq({ id: stock.id, name: stock.name, bearer_name: stock.bearer.name }.as_json)
          end
        end

        context 'with other bearer' do
          let(:params) do
            {
              stock: {
                name: Faker::Name.unique.name,
                bearer_name: Faker::Name.unique.name
              }
            }
          end

          it 'is success' do
            subject

            expect(response).to have_http_status(:ok)
          end

          it 'changes stock name' do
            expect { subject }.to change { stock.reload.name }.to(params.dig(:stock, :name))
          end

          it 'creates new bearer' do
            expect { subject }.to change(Bearer, :count).by(1)
          end

          it 'renders updated stock' do
            subject

            expect(response.parsed_body).to be_empty
          end

        end
      end

      context 'with not unique name' do
        let(:other_stock) { create :stock }

        let(:params) do
          {
            stock: {
              name: other_stock.name
            }
          }
        end

        it 'is not success' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders error' do
          subject

          expect(response.parsed_body['errors']).to eq ['Name has already been taken']
        end
      end
    end

    context 'when stock does not exists' do
      subject { put "/bearers/#{bearer.id}/stocks/-1", params: params }

      let(:bearer) { create :bearer }
      let(:params) do
        {
          stock: {
            name: Faker::Name.unique.name,
            bearer_name: Faker::Name.unique.name
          }
        }
      end

      it 'returns 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when stock exists' do
      subject { delete "/bearers/#{stock.bearer.id}/stocks/#{stock.id}" }

      let!(:stock) { create :stock }

      it 'returns ok' do
        subject

        expect(response).to have_http_status(:ok)
      end

      it 'deletes stock' do
        expect { subject }.to change(Stock, :count).by(-1)
      end

      it 'does not delete stock from db' do
        expect { subject }.not_to change(Stock.unscoped, :count)
      end
    end

    context 'when stock does not exists' do
      subject { delete "/bearers/#{bearer.id}/stocks/-1" }
      let(:bearer) { create :bearer }

      it 'returns 404' do
        subject

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
