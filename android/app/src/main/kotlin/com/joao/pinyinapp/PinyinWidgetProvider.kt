package com.joao.pinyinapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.text.SpannableString
import android.text.Spanned
import android.text.style.LocaleSpan
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale

// Widget da tela inicial com o hanzi escolhido no app.
//
// O nome qualificado desta classe e as chaves abaixo são duplicados em
// HomeWidgetPluginDataSource (lib/features/home_screen_widget/data/datasources/
// home_widget_plugin_data_source.dart) e em ios/PinyinWidget/PinyinWidget.swift;
// mudar um exige mudar os outros.
class PinyinWidgetProvider : HomeWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    val wordId = widgetData.getString(KEY_WORD_ID, null)
    val simplified = widgetData.getString(KEY_SIMPLIFIED, null)
    val pinyin = widgetData.getString(KEY_PINYIN, null)

    for (appWidgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.pinyin_widget)

      if (simplified == null) {
        views.setViewVisibility(R.id.widget_hanzi, View.GONE)
        views.setViewVisibility(R.id.widget_pinyin, View.GONE)
        views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
      } else {
        views.setViewVisibility(R.id.widget_empty, View.GONE)
        views.setViewVisibility(R.id.widget_hanzi, View.VISIBLE)
        views.setTextViewText(R.id.widget_hanzi, simplifiedChinese(simplified))
        views.setViewVisibility(
            R.id.widget_pinyin,
            if (pinyin.isNullOrEmpty()) View.GONE else View.VISIBLE,
        )
        views.setTextViewText(R.id.widget_pinyin, pinyin.orEmpty())
      }

      // `homeWidget` na query é como o plugin home_widget reconhece o toque.
      val uri = wordId?.let { Uri.parse("pinyinapp://word/$it?homeWidget") }
      views.setOnClickPendingIntent(
          android.R.id.background,
          HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri),
      )

      appWidgetManager.updateAppWidget(appWidgetId, views)
    }
  }

  // Sem a indicação de idioma o Android pode desenhar os caracteres com
  // glifos japoneses quando o aparelho não está em chinês.
  private fun simplifiedChinese(text: String): CharSequence =
      SpannableString(text).apply {
        setSpan(LocaleSpan(Locale.SIMPLIFIED_CHINESE), 0, length, Spanned.SPAN_INCLUSIVE_EXCLUSIVE)
      }

  private companion object {
    const val KEY_WORD_ID = "word_id"
    const val KEY_SIMPLIFIED = "word_simplified"
    const val KEY_PINYIN = "word_pinyin"
  }
}
