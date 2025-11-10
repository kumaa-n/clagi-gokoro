module ApplicationHelper
  def page_title(title = "")
    base_title = "クラギごころ"
    title.present? ? "#{title} | #{base_title}" : base_title
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
end
