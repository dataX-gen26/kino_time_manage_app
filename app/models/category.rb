class Category < ApplicationRecord
  belongs_to :user
  has_many :actuals, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
end