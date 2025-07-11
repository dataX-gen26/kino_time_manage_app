class User < ApplicationRecord
  has_many :actuals, dependent: :destroy
  has_many :categories, dependent: :destroy
end
