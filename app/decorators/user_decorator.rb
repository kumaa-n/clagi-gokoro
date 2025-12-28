class UserDecorator < Draper::Decorator
  delegate_all

  # メールアドレスをマスキングして返す
  # 例: "test@example.com" => "te***@example.com"
  def masked_email
    return "" if email.blank?

    local, domain = email.split("@")
    return email if local.blank? || domain.blank?

    visible_chars = local.length <= 2 ? 1 : 2
    "#{local[0...visible_chars]}***@#{domain}"
  end
end
