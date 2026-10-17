import SwiftUI
import WidgetKit

// Duplicadas em HomeWidgetPluginDataSource
// (lib/features/home_screen_widget/data/datasources/home_widget_plugin_data_source.dart)
// e nos .entitlements; mudar uma exige mudar as outras.
private let appGroupId = "group.com.joao.pinyinapp"
private let widgetKind = "PinyinWidget"

private enum Keys {
  static let wordId = "word_id"
  static let simplified = "word_simplified"
  static let pinyin = "word_pinyin"
}

struct HanziEntry: TimelineEntry {
  let date: Date
  let wordId: String?
  let simplified: String?
  let pinyin: String?

  static let example = HanziEntry(
    date: .now, wordId: nil, simplified: "你好", pinyin: "nǐ hǎo")
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> HanziEntry { .example }

  func getSnapshot(in context: Context, completion: @escaping (HanziEntry) -> Void) {
    // Na galeria de widgets, antes de alguma palavra ser escolhida, mostra o exemplo.
    let entry = storedEntry()
    completion(context.isPreview && entry.simplified == nil ? .example : entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HanziEntry>) -> Void) {
    // Quem recarrega é o app, ao trocar a palavra; não há nada para agendar.
    completion(Timeline(entries: [storedEntry()], policy: .never))
  }

  private func storedEntry() -> HanziEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    return HanziEntry(
      date: .now,
      wordId: defaults?.string(forKey: Keys.wordId),
      simplified: defaults?.string(forKey: Keys.simplified),
      pinyin: defaults?.string(forKey: Keys.pinyin)
    )
  }
}

struct PinyinWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: HanziEntry

  var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .widgetURL(tapURL)
      .widgetBackground()
  }

  @ViewBuilder private var content: some View {
    if let simplified = entry.simplified {
      VStack(spacing: 4) {
        Text(simplified)
          .font(.system(size: family == .systemSmall ? 56 : 72, weight: .medium))
          .lineLimit(1)
          .minimumScaleFactor(0.3)
          .simplifiedChineseGlyphs()
        if let pinyin = entry.pinyin {
          Text(pinyin)
            .font(family == .systemSmall ? .subheadline : .title3)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
      }
      .padding(.horizontal, 4)
    } else {
      Text("Escolha um hanzi no app")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
  }

  /// `homeWidget` na query é como o plugin home_widget reconhece o toque.
  private var tapURL: URL? {
    guard let id = entry.wordId else { return nil }
    return URL(string: "pinyinapp://word/\(id)?homeWidget")
  }
}

extension View {
  /// Escolhe os glifos do chinês simplificado (PingFang SC) mesmo com o
  /// iPhone em outro idioma, em vez de variantes japonesas.
  @ViewBuilder fileprivate func simplifiedChineseGlyphs() -> some View {
    if #available(iOS 17.0, *) {
      typesettingLanguage(Locale.Language(identifier: "zh-Hans"))
    } else {
      environment(\.locale, Locale(identifier: "zh-Hans"))
    }
  }

  /// A partir do iOS 17 o widget precisa declarar o fundo pelo
  /// `containerBackground`; antes disso basta um `background` comum.
  @ViewBuilder fileprivate func widgetBackground() -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(.background, for: .widget)
    } else {
      background(Color(uiColor: .systemBackground))
    }
  }
}

@main
struct PinyinWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: widgetKind, provider: Provider()) { entry in
      PinyinWidgetView(entry: entry)
    }
    .configurationDisplayName("Hanzi")
    .description("Mostra o hanzi escolhido no Pinyinapp.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
