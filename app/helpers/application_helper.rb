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
end