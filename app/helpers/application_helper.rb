module ApplicationHelper
  def default_meta_tags
    base_title = "クラギごころ"
    title = content_for?(:title) ? content_for(:title) : ""
    description = "クラギごころはクラシックギター楽曲の難易度評価・演奏技術分析でギタリストの曲選びと練習をサポートするWebサービスです。テンポ、運指、表現力など詳細評価を共有できます。"
    ogp_image = image_url("ogp.webp")

    {
      site: base_title,
      title: title,
      reverse: true,
      charset: "utf-8",
      description: description,
      keywords: "クラシックギター,クラギ,難易度,レビュー,練習,レパートリー,テンポ,運指,表現力",
      icon: [
        { href: "/favicon.ico", sizes: "32x32" },
        { href: "/apple-touch-icon.png", rel: "apple-touch-icon", sizes: "180x180" }
      ],
      og: {
        site_name: base_title,
        title: title.presence || base_title,
        description: description,
        type: "website",
        url: request.original_url,
        image: ogp_image,
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        image: ogp_image
      }
    }
  end

  def flash_class(type)
    {
      notice:  "alert-success",
      alert:   "alert-error",
      error:   "alert-error",
      warning: "alert-warning"
    }[type.to_sym] || "alert-info"
  end

  def format_date(date)
    date.strftime("%Y/%m/%d")
  end

  def star_rating_display(rating, size: "md", total_stars: 5)
    size_class = size == "md" ? "rating" : "rating rating-#{size}"

    content_tag(:div, class: size_class) do
      (1..total_stars).map do |star|
        if star == rating
          content_tag(:div, nil, class: "mask mask-star-2 bg-orange-400", aria: { label: "#{star} star", current: true })
        else
          content_tag(:div, nil, class: "mask mask-star-2 bg-orange-400", aria: { label: "#{star} star" })
        end
      end.join.html_safe
    end
  end

  def header_user_name
    return nil unless user_signed_in?

    # current_userは更新失敗時に変更された値を持つ可能性があるため、
    # DBから最新の値を取得し、メモ化する
    @header_user_name ||= User.find(current_user.id).name
  end
end
