module ReviewsHelper
  def rating_fields_data
    [
      {
        label: "テンポ",
        field: :tempo_rating,
        intro: "曲の速さとリズムを崩さずにテンポを保つ難しさを評価してください。",
        criteria: [
          "かなりゆっくり。落ち着いて弾けて、速さも保ちやすい。",
          "ゆっくり。少しだけ忙しくなるが、安定して弾きやすい。",
          "ふつう。リズムが崩れないよう注意が必要。",
          "速い。ミスしやすく、正確さと集中が必要。",
          "とても速い。体力と集中力が必要で、長く保つのが難しい。"
        ]
      },
      {
        label: "運指技巧",
        field: :fingering_technique_rating,
        intro: "弦を押さえる技術を評価してください。",
        criteria: [
          "ローポジション中心。押さえ方はシンプルで、移動はほとんどない。",
          "ローポジション内で少し移動する程度。指の形を保てば弾きやすい。",
          "ローポジション〜ミドルポジションへ動く。まとめて押さえる形や、指を入れ替えて音をつなぐ動きが増える。",
          "ハイポジションへよく移動する。指を広げる押さえ方や、なめらかに移動する動きが増える。",
          "ローポジション〜ハイポジションを素早く行き来する。難しい押さえ方を正確に続ける必要がある。"
        ]
      },
      {
        label: "弾弦技巧",
        field: :plucking_technique_rating,
        intro: "弦を弾く技術を評価してください。",
        criteria: [
          "ゆっくりでシンプル。1本ずつ弾く場面が多い。",
          "少し同時に鳴らす（2〜3音）場面があるが、動きは落ち着いている。",
          "メロディと低い音を同時に弾くことが多く、弦の移動が続く。",
          "速い動きが増える。細かく弾き続けたり、弾き方を切り替える必要がある。",
          "とても細かいコントロールが必要。音の大きさや鳴らし分けを常に意識する。"
        ]
      },
      {
        label: "表現力",
        field: :expression_rating,
        intro: "強弱や音の雰囲気で「曲らしく聞かせる」難しさを評価してください。",
        criteria: [
          "強弱を少し付ければ十分。",
          "強調や間の取り方が必要。",
          "音の雰囲気を場所で変える必要がある。",
          "メロディと伴奏の音量調整が必要。",
          "強弱・音・間を細かく切り替える必要がある。"
        ]
      },
      {
        label: "暗譜・構成",
        field: :memorization_rating,
        intro: "覚える量と曲の流れのわかりやすさを評価してください。",
        criteria: [
          "短くて同じ部分が多く、すぐに覚えられる。",
          "少し長いが、区切りがはっきりしていて覚えやすい。",
          "ふつうの長さ。似た部分が多く、間違えやすいので整理が必要。",
          "長くて場面がよく変わる。途中で雰囲気が変わり、迷いやすい。",
          "とても長くて複雑。場面・リズム・雰囲気の変化が多く、しっかり把握しないと覚えにくい。"
        ]
      }
    ]
  end

  def general_guidelines_data
    [
      { stars: 1, label: "とても易しい（例：月光 - F.ソル）", description: "初心者でも弾ける。基本的な技術と短い練習時間で仕上げられる。" },
      { stars: 2, label: "やや易しい（例：禁じられた遊び - 作曲者不詳）", description: "基礎を身につけた初級者向け。落ち着いて取り組めば習得できる。" },
      { stars: 3, label: "普通（例：カヴァティーナ - マイヤーズ）", description: "標準的な中級レパートリー。計画的な練習で確実に仕上げられる。" },
      { stars: 4, label: "やや難しい（例：タンゴ・アン・スカイ - ディアンス）", description: "上級者入口。高度な技術や表現力が必要で、重点的な練習が必要。" },
      { stars: 5, label: "とても難しい（例：アストリアス - アルベニス）", description: "最上級レベル。豊富な演奏経験と高い集中力、総合的な技術を要する。" }
    ]
  end

  def rating_display_data(review)
    rating_fields_data.map do |field_data|
      {
        label: field_data[:label],
        rating: review.send(field_data[:field]),
        description: field_data[:intro],
        criteria: field_data[:criteria].map.with_index(1) do |criterion, index|
          { star: "★#{index}", text: criterion }
        end
      }
    end
  end

  def render_tags(tags, song: nil, linkable: false)
    return "" if tags.blank?

    tags.map do |tag|
      if linkable && song
        link_to tag,
                song_reviews_path(song, tag: tag),
                class: "badge badge-primary badge-sm hover:badge-secondary transition-colors relative z-30",
                data: { turbo_frame: "_top" }
      else
        content_tag(:span, tag, class: "badge badge-primary badge-sm")
      end
    end.join(" ").html_safe
  end

  def x_share_url(review)
    text = "「#{review.song.title}」のレビュー\n#クラギごころ"
    url = review_url(review)
    "https://twitter.com/intent/tweet?text=#{CGI.escape(text)}&url=#{CGI.escape(url)}"
  end
end
