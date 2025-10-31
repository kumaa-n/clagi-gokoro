module ApplicationHelper
  def flash_class(type)
    {
      notice:  "alert-success",
      alert:   "alert-error",
      error:   "alert-error",
      warning: "alert-warning"
    }[type.to_sym] || "alert-info"
  end
end
