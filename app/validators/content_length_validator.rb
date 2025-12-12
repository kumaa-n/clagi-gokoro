class ContentLengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    # 改行を除いた文字数を計算
    content_length = value.gsub(/[\r\n]+/, "").length

    if options[:minimum] && content_length < options[:minimum]
      record.errors.add(attribute, :too_short, count: options[:minimum])
    end

    if options[:maximum] && content_length > options[:maximum]
      record.errors.add(attribute, :too_long, count: options[:maximum])
    end
  end
end
