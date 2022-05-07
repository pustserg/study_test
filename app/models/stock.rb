class Stock < ApplicationRecord
  # To be discussed, usually gem like paranoia https://github.com/rubysherpas/paranoia is used for safe delete
  default_scope -> { where(deleted_at: nil) }
  belongs_to :bearer

  validates :name, presence: true, uniqueness: true

  def destroy
    update(deleted_at: Time.current)
  end

  def destroy!
    update!(deleted_at: Time.current)
  end
end
