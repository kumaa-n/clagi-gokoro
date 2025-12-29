class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :reviews, dependent: :destroy
  has_many :review_favorites, dependent: :destroy
  has_many :favorited_reviews, -> { order("review_favorites.created_at DESC") }, through: :review_favorites, source: :review

  # バリデーションとビューで使用する文字数制限
  NAME_MIN_LENGTH = 2
  NAME_MAX_LENGTH = 15
  PASSWORD_MIN_LENGTH = Devise.password_length.min
  SELF_INTRODUCTION_MAX_LENGTH = 500

  validates :email, uniqueness: true, allow_blank: true
  validates :name, uniqueness: true, length: { in: NAME_MIN_LENGTH..NAME_MAX_LENGTH }
  validates :provider_uid, presence: true, uniqueness: { scope: :provider }, if: -> { provider_uid.present? }
  validates :self_introduction, content_length: { maximum: SELF_INTRODUCTION_MAX_LENGTH }, allow_blank: true

  def email_required?
    false
  end

  def oauth_user?
    provider.present?
  end

  def email_registered?
    email.present?
  end

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, provider_uid: auth.uid) do |user|
      user.name = generate_unique_name(auth.info.name)
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!  # 検証済みのため確認をスキップ
    end
  end

  def self.generate_unique_name(base_name)
    # 名前の文字数がオーバーしていた際の調整
    name = base_name.to_s.strip[0, NAME_MAX_LENGTH]

    # デフォルト名使用
    name = "user" if name.length < NAME_MIN_LENGTH

    # 既に存在しない場合はそのまま返す
    return name unless exists?(name: name)

    # 重複する場合はランダムな4桁の数字を追加してユニークにする
    10.times do
      # ランダムな4桁の数字を生成
      suffix = rand(1000..9999).to_s
      max_length = NAME_MAX_LENGTH - suffix.length
      unique_name = "#{name[0, max_length]}#{suffix}"

      return unique_name unless exists?(name: unique_name)
    end

    # 万が一10回試行しても重複する場合はタイムスタンプを使用
    timestamp = Time.current.to_i.to_s[-4..]
    "#{name[0, NAME_MAX_LENGTH - 4]}#{timestamp}"
  end
end
