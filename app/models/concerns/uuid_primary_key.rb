module UuidPrimaryKey
  extend ActiveSupport::Concern

  included do
    self.primary_key = :uuid
  end

  # uuidの短縮
  def short_uuid
    # base64で短縮
    # -を削除したあと16進数に変換、パディングの=を削除
    Base64.urlsafe_encode64([uuid.delete("-")].pack("H*")).tr("=", "")
  end

  # URLに短縮uuidを使用
  def to_param
    short_uuid
  end

  class_methods do
    # 短縮uuidから検索
    def find_by_short_uuid(short_uuid)
      # base64でデコード
      # uuidは「8-4-4-4-12」の形式（例：550e8400-e29b-41d4-a716-446655440000）
      # なので16進数から変換して-を挿入
      decode_uuid = Base64.urlsafe_decode64(short_uuid).unpack1("H*").insert(8, "-").insert(13, "-").insert(18, "-").insert(23, "-")
      find_by(uuid: decode_uuid)
    end
  end
end
