module SystemHelper
  # HTML5バリデーションを無効化してフォームを送信する
  # サーバー側のバリデーションをテストする際に使用
  def submit_form_without_html5_validation(button_text = nil)
    # JavaScriptで直接フォームを送信（HTML5バリデーションをバイパス）
    page.execute_script("document.querySelector('form').submit()")
  end
end

RSpec.configure do |config|
  config.include SystemHelper, type: :system
end
