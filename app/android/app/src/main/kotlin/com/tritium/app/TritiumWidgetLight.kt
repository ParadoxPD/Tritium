// File: android/app/src/main/kotlin/com/tritium/app/TritiumWidgetLight.kt

package com.tritium.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import kotlin.math.*

class TritiumWidgetLight : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { widgetId ->
            updateWidget(context, appWidgetManager, widgetId)
        }
    }
    
    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.tritium_widget_light)
        
        // Get saved data
        val prefs = context.getSharedPreferences("TritiumWidget_$widgetId", Context.MODE_PRIVATE)
        val input = prefs.getString("input", "") ?: ""
        val result = prefs.getString("result", "0") ?: "0"
        
        // Update display
        views.setTextViewText(R.id.input_display, if (input.isEmpty()) "0" else input)
        views.setTextViewText(R.id.result_display, result)
        
        // Setup button clicks
        setupButtonClicks(context, views, widgetId)
        
        appWidgetManager.updateAppWidget(widgetId, views)
    }
    
    private fun setupButtonClicks(context: Context, views: RemoteViews, widgetId: Int) {
        // Number and operator buttons
        val buttons = listOf(
            R.id.btn_7 to "7", R.id.btn_8 to "8", R.id.btn_9 to "9",
            R.id.btn_4 to "4", R.id.btn_5 to "5", R.id.btn_6 to "6",
            R.id.btn_1 to "1", R.id.btn_2 to "2", R.id.btn_3 to "3",
            R.id.btn_0 to "0", R.id.btn_dot to ".",
            R.id.btn_power to "^", R.id.btn_sqrt to "√",
            R.id.btn_lparen to "(", R.id.btn_rparen to ")",
            R.id.btn_multiply to "×", R.id.btn_divide to "÷",
            R.id.btn_add to "+", R.id.btn_subtract to "-"
        )
        
        buttons.forEach { (buttonId, value) ->
            val intent = Intent(context, TritiumWidgetLight::class.java).apply {
                action = "BUTTON_PRESS"
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                putExtra("button_value", value)
            }
            
            views.setOnClickPendingIntent(
                buttonId,
                PendingIntent.getBroadcast(
                    context,
                    buttonId + widgetId * 1000,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
        }
        
        // DEL button
        val delIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_DELETE"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_del,
            PendingIntent.getBroadcast(
                context,
                R.id.btn_del + widgetId * 1000,
                delIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        
        // AC button
        val acIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_CLEAR"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_ac,
            PendingIntent.getBroadcast(
                context,
                R.id.btn_ac + widgetId * 1000,
                acIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        
        // Ans button - inserts previous result
        val ansIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_ANS"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_ans,
            PendingIntent.getBroadcast(
                context,
                R.id.btn_ans + widgetId * 1000,
                ansIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
        
        // Equals button - calculates result
        val equalsIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_EQUALS"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_equals,
            PendingIntent.getBroadcast(
                context,
                R.id.btn_equals + widgetId * 1000,
                equalsIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        val widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) return
        
        val prefs = context.getSharedPreferences("TritiumWidget_$widgetId", Context.MODE_PRIVATE)
        
        when (intent.action) {
            "BUTTON_PRESS" -> {
                val value = intent.getStringExtra("button_value") ?: return
                val currentInput = prefs.getString("input", "") ?: ""
                prefs.edit().putString("input", currentInput + value).apply()
                updateAllWidgets(context)
            }
            "BUTTON_DELETE" -> {
                val currentInput = prefs.getString("input", "") ?: ""
                if (currentInput.isNotEmpty()) {
                    prefs.edit().putString("input", currentInput.dropLast(1)).apply()
                }
                updateAllWidgets(context)
            }
            "BUTTON_CLEAR" -> {
                prefs.edit()
                    .putString("input", "")
                    .putString("result", "0")
                    .apply()
                updateAllWidgets(context)
            }
            "BUTTON_ANS" -> {
                val currentInput = prefs.getString("input", "") ?: ""
                val lastResult = prefs.getString("result", "0") ?: "0"
                prefs.edit().putString("input", currentInput + lastResult).apply()
                updateAllWidgets(context)
            }
            "BUTTON_EQUALS" -> {
                val input = prefs.getString("input", "") ?: ""
                if (input.isNotEmpty()) {
                    val result = evaluateExpression(input)
                    prefs.edit()
                        .putString("result", result)
                        .putString("input", "")
                        .apply()
                }
                updateAllWidgets(context)
            }
        }
    }
    
    private fun evaluateExpression(expr: String): String {
        return try {
            // Replace symbols with operators
            var expression = expr
                .replace("×", "*")
                .replace("÷", "/")
                .replace("√", "sqrt")
            
            // Simple evaluation for basic operations
            val result = calculateBasic(expression)
            
            // Format result
            if (result % 1.0 == 0.0) {
                result.toLong().toString()
            } else {
                String.format("%.10f", result).trimEnd('0').trimEnd('.')
            }
        } catch (e: Exception) {
            "Error"
        }
    }
    
    private fun calculateBasic(expr: String): Double {
        // Handle sqrt
        var expression = expr
        while (expression.contains("sqrt(")) {
            val start = expression.indexOf("sqrt(")
            var depth = 0
            var end = start + 5
            while (end < expression.length) {
                when (expression[end]) {
                    '(' -> depth++
                    ')' -> {
                        if (depth == 0) break
                        depth--
                    }
                }
                end++
            }
            val inner = expression.substring(start + 5, end)
            val sqrtResult = sqrt(calculateBasic(inner))
            expression = expression.substring(0, start) + sqrtResult + expression.substring(end + 1)
        }
        
        // Handle parentheses
        while (expression.contains("(")) {
            val end = expression.indexOf(")")
            var start = end
            while (start >= 0 && expression[start] != '(') start--
            
            val inner = expression.substring(start + 1, end)
            val result = calculateBasic(inner)
            expression = expression.substring(0, start) + result + expression.substring(end + 1)
        }
        
        // Handle power
        while (expression.contains("^")) {
            val idx = expression.indexOf("^")
            val leftNum = extractLeftNumber(expression, idx)
            val rightNum = extractRightNumber(expression, idx)
            val result = leftNum.first.toDouble().pow(rightNum.first.toDouble())
            expression = expression.substring(0, leftNum.second) + result + 
                        expression.substring(rightNum.second)
        }
        
        // Handle multiplication and division
        while (expression.contains("*") || expression.contains("/")) {
            val mulIdx = expression.indexOf("*").let { if (it == -1) Int.MAX_VALUE else it }
            val divIdx = expression.indexOf("/").let { if (it == -1) Int.MAX_VALUE else it }
            val idx = minOf(mulIdx, divIdx)
            val op = expression[idx]
            
            val leftNum = extractLeftNumber(expression, idx)
            val rightNum = extractRightNumber(expression, idx)
            val result = if (op == '*') {
                leftNum.first.toDouble() * rightNum.first.toDouble()
            } else {
                leftNum.first.toDouble() / rightNum.first.toDouble()
            }
            expression = expression.substring(0, leftNum.second) + result + 
                        expression.substring(rightNum.second)
        }
        
        // Handle addition and subtraction
        var result = 0.0
        var currentNum = ""
        var lastOp = '+'
        
        for (i in expression.indices) {
            val c = expression[i]
            if (c.isDigit() || c == '.') {
                currentNum += c
            } else if (c == '+' || c == '-') {
                if (currentNum.isNotEmpty()) {
                    result = when (lastOp) {
                        '+' -> result + currentNum.toDouble()
                        '-' -> result - currentNum.toDouble()
                        else -> currentNum.toDouble()
                    }
                    currentNum = ""
                }
                lastOp = c
            }
        }
        
        if (currentNum.isNotEmpty()) {
            result = when (lastOp) {
                '+' -> result + currentNum.toDouble()
                '-' -> result - currentNum.toDouble()
                else -> currentNum.toDouble()
            }
        }
        
        return result
    }
    
    private fun extractLeftNumber(expr: String, opIdx: Int): Pair<String, Int> {
        var start = opIdx - 1
        while (start >= 0 && (expr[start].isDigit() || expr[start] == '.')) start--
        return Pair(expr.substring(start + 1, opIdx), start + 1)
    }
    
    private fun extractRightNumber(expr: String, opIdx: Int): Pair<String, Int> {
        var end = opIdx + 1
        while (end < expr.length && (expr[end].isDigit() || expr[end] == '.')) end++
        return Pair(expr.substring(opIdx + 1, end), end)
    }
    
    private fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        
        // Update all light widgets
        val lightIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, TritiumWidgetLight::class.java)
        )
        lightIds.forEach { updateWidget(context, appWidgetManager, it) }
        
        // Update all dark widgets
        val darkIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, TritiumWidgetDark::class.java)
        )
        darkIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.tritium_widget_dark)
            val prefs = context.getSharedPreferences("TritiumWidget_$id", Context.MODE_PRIVATE)
            val input = prefs.getString("input", "") ?: ""
            val result = prefs.getString("result", "0") ?: "0"
            views.setTextViewText(R.id.input_display, if (input.isEmpty()) "0" else input)
            views.setTextViewText(R.id.result_display, result)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
