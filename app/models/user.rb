class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :reviews, dependent: :destroy

  validates :email, uniqueness: true, allow_blank: true
  validates :name, uniqueness: true, length: { in: 2..15 }

  def email_required?
    false
  end
end
