crumb :root do
  link "ホーム", root_path
end

crumb :songs do
  link "曲一覧", songs_path
  parent :root
end

crumb :new_song do
  link "新しい曲を追加", new_song_path
  parent :songs
end

crumb :song_reviews do |song|
  link "レビュー一覧", song_reviews_path(song)
  parent :songs
end

crumb :new_review do |song|
  link "レビュー投稿", new_song_review_path(song)
  parent :song_reviews, song
end

crumb :review do |review|
  link "レビュー詳細", review_path(review)
  parent :song_reviews, review.song
end

crumb :edit_review do |review|
  link "レビュー編集", edit_review_path(review)
  parent :review, review
end

crumb :profile do
  link "マイページ", profile_path
  parent :root
end

crumb :edit_profile do
  link "プロフィール編集", edit_profile_path
  parent :profile
end

crumb :edit_email_change do
  link "メールアドレス変更", edit_email_change_path
  parent :profile
end

# パスワード変更（マイページから）
crumb :new_password do
  link "パスワード変更", new_user_password_path
  parent :profile
end
