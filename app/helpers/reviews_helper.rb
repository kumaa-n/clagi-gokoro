module ReviewsHelper
  def rating_fields_data
    [
      {
        label: "テンポ",
        field: :tempo_rating,
        intro: "曲の速さやリズムの取りやすさ、安定したテンポ維持の難易度を意識して評価してください。",
        criteria: [
          "テンポはゆっくり（60～80 bpm）。一定のビートを保ちやすく、拍感を掴みやすい。",
          "テンポは中程度（80～100 bpm）。落ち着いた速さで、適度な緊張感がある。",
          "テンポは標準（100～120 bpm）。速さの変化に対応しながら、安定したリズム維持が求められる。",
          "テンポは速め（120～140 bpm）。細かなリズムやシンコペーションを正確に刻む必要がある。",
          "高速テンポ（140 bpm以上）。体力・集中力を要し、長時間の正確なリズム維持が難しい。"
        ]
      },
      {
        label: "運指技巧",
        field: :fingering_technique_rating,
        intro: "ポジション移動や押弦の複雑さ、左手の安定感を基準に判断しましょう。",
        criteria: [
          "オープンポジション中心。ポジション移動やセーハはほぼなし。",
          "短いポジション移動や部分セーハが登場。基本フォームを保てれば対応可能。",
          "5〜7ポジションへの移動、全セーハ、スラーを組み合わせる場面が増える。",
          "高ポジションへの頻繁な移動やストレッチ、連続スライドが要求される。",
          "広範囲の跳躍移動や複雑な運指分割、高速ポジションチェンジを正確にこなす必要がある。"
        ]
      },
      {
        label: "弾弦技巧",
        field: :plucking_technique_rating,
        intro: "右手の独立性、アルペジオや特殊奏法など弦を弾く技術の難度を評価してください。",
        criteria: [
          "単音メロディーや基本的なアルペジオ。右手の独立性はほぼ不要。",
          "単純な分散和音やベース音との同時発音。右手の指替えがゆっくり行える。",
          "メロディー・ベース・内声を同時に扱い、指替えや弦移動が連続する。",
          "高速アルペジオ、トレモロ、ラスゲアード風の奏法など高度なコントロールが求められる。",
          "多声部を完全に独立して扱い、音色・ダイナミクスの細密なコントロールと特殊奏法を織り交ぜる。"
        ]
      },
      {
        label: "表現力",
        field: :expression_rating,
        intro: "フレーズの抑揚や音色変化、感情表現の幅広さをどれだけ求められるかで判断してください。",
        criteria: [
          "基本的な強弱変化のみ。フレーズごとの自然な山と谷を作れば十分。",
          "緩やかなルバートやアクセント付けを織り交ぜ、曲想を整える必要がある。",
          "フレーズ内での音色変化、ビブラートの活用など中程度の表現幅が求められる。",
          "多声部のバランス調整や微細なダイナミクス操作で立体感を作る。",
          "高度な解釈力と即応性が必要。多彩な音色変化・緻密なニュアンスを瞬時に切り替える。"
        ]
      },
      {
        label: "暗譜・構成",
        field: :memorization_rating,
        intro: "曲の構造理解や暗譜の負担感、セクションの複雑さを基準に評価してください。",
        criteria: [
          "短い楽曲で反復が多い。A-Bなど単純な構成で暗譜しやすい。",
          "2〜3セクションの構成。簡単な変化や転調があり、流れを把握すれば覚えられる。",
          "複数テーマや変奏を含み、セクションごとの役割を整理する必要がある。",
          "長尺で展開が多彩。転調や再現部の位置関係を理解しないと記憶が難しい。",
          "高度に複雑な構成。多数のモチーフ・転調・リズム変化を分析して整理する必要がある。"
        ]
      }
    ]
  end

  def general_guidelines_data
    [
      { stars: 1, label: "とても易しい", description: "初心者でも弾ける。基本的な技術と短い練習時間で仕上げられる。" },
      { stars: 2, label: "やや易しい", description: "基礎を身につけた初級者向け。落ち着いて取り組めば習得できる。" },
      { stars: 3, label: "普通", description: "標準的な中級レパートリー。計画的な練習で確実に仕上げられる。" },
      { stars: 4, label: "やや難しい", description: "上級者入口。高度な技術や表現力が必要で、重点的な練習が必要。" },
      { stars: 5, label: "とても難しい", description: "最上級レベル。豊富な演奏経験と高い集中力、総合的な技術を要する。" }
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
end
