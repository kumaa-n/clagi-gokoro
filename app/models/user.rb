class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :reviews, dependent: :destroy

  validates :email, uniqueness: true, allow_blank: true
  validates :name, uniqueness: true, length: { in: 2..15 }
  validates :provider_uid, presence: true, uniqueness: { scope: :provider }, if: -> { provider_uid.present? }

  def email_required?
    false
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, provider_uid: auth.uid).first_or_create do |user|
      user.name = generate_unique_name(auth.info.name)
      user.password = Devise.friendly_token[0, 20]
      user.skip_confirmation!  # Googleで既に検証済みのため確認をスキップ
    end
  end

  def self.generate_unique_name(base_name)
    # 名前を15文字以内に調整
    name = base_name.to_s.strip[0, 15]

    # 名前が2文字未満の場合はデフォルト名を使用
    name = "user" if name.length < 2

    # 既に存在しない場合はそのまま返す
    return name unless exists?(name: name)

    # 重複する場合はランダムな4桁の数字を追加してユニークにする
    10.times do
      # ランダムな4桁の数字を生成（15文字制限を考慮）
      suffix = rand(1000..9999).to_s
      max_length = 15 - suffix.length
      unique_name = "#{name[0, max_length]}#{suffix}"

      return unique_name unless exists?(name: unique_name)
    end

    # 万が一10回試行しても重複する場合はタイムスタンプを使用
    timestamp = Time.current.to_i.to_s[-4..]
    "#{name[0, 11]}#{timestamp}"
  end
end
