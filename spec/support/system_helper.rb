module SystemHelper
  # HTML5バリデーションを無効化してフォームを送信する
  # サーバー側のバリデーションをテストする際に使用
  def submit_form_without_html5_validation(button_text)
    page.execute_script("document.querySelector('form').setAttribute('novalidate', 'novalidate')")
    click_button button_text
  end
end

RSpec.configure do |config|
  config.include SystemHelper, type: :system
end
