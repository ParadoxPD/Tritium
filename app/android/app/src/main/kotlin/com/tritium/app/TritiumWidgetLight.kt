// File: android/app/src/main/kotlin/com/tritium/app/TritiumWidgetDark.kt

package com.tritium.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.math.BigDecimal
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sqrt

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
            R.id.btn_power to "^", R.id.btn_sqrt to "√(",
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

            val uniqueRequestCode = widgetId + buttonId.hashCode()

            views.setOnClickPendingIntent(
                buttonId,
                PendingIntent.getBroadcast(
                    context,
                    uniqueRequestCode,
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
                widgetId + R.id.btn_del.hashCode(),
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
                widgetId + R.id.btn_ac.hashCode(),
                acIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        // Ans button
        val ansIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_ANS"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_ans,
            PendingIntent.getBroadcast(
                context,
                widgetId + R.id.btn_ans.hashCode(),
                ansIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        // Equals button
        val equalsIntent = Intent(context, TritiumWidgetLight::class.java).apply {
            action = "BUTTON_EQUALS"
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        views.setOnClickPendingIntent(
            R.id.btn_equals,
            PendingIntent.getBroadcast(
                context,
                widgetId + R.id.btn_equals.hashCode(),
                equalsIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        val widgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        )
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
            // Replace visual operators with math operators
            val cleanExpr = expr
                .replace("×", "*")
                .replace("÷", "/")
                .replace("√", "sqrt")
                .replace(Regex("(?<=[\\d)])(?=(sqrt|\\())"), "*")

            val result = calculateBasic(cleanExpr)

            // Formatting logic
            val abs = abs(result)
            when {
                // Scientific notation for very large or very small non-zero numbers
                abs >= 1e12 || (abs > 0 && abs < 1e-6) -> String.format("%.6e", result)
                // Integer check
                result == result.toLong().toDouble() -> result.toLong().toString()
                // Default clean decimal
                else -> BigDecimal(result).stripTrailingZeros().toPlainString()
            }
        } catch (e: Exception) {
            "Error"
        }
    }

    private fun calculateBasic(expr: String): Double {
        var expression = expr

        // 1. Handle Sqrt
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
            // If parenthesis was unclosed, take valid substring
            if (end > expression.length) end = expression.length

            val inner = expression.substring(start + 5, end)
            val sqrtResult = sqrt(calculateBasic(inner))
            expression = expression.substring(0, start) +
                    formatForCalc(sqrtResult) +
                    if (end + 1 < expression.length) expression.substring(end + 1) else ""
        }

        // 2. Handle Parentheses
        while (expression.contains("(")) {
            val end = expression.indexOf(")")
            if (end == -1) break // Should not happen if brackets balanced
            var start = end
            while (start >= 0 && expression[start] != '(') start--
            if (start < 0) break

            val inner = expression.substring(start + 1, end)
            val result = calculateBasic(inner)
            expression = expression.substring(0, start) +
                    formatForCalc(result) +
                    expression.substring(end + 1)
        }
        // 1.5 Handle Factorial
        while (expression.contains("!")) {
            val idx = expression.indexOf("!")
            val leftNum = extractLeftNumber(expression, idx)

            val value = leftNum.first.toDouble()
            val fact = factorial(value)

            var replacement = formatForCalc(fact)

            // Check for implicit multiplication after factorial
            val nextIdx = idx + 1
            if (nextIdx < expression.length) {
                val nextChar = expression[nextIdx]
                if (nextChar.isDigit() || nextChar == '(' || expression.startsWith("sqrt", nextIdx)) {
                    replacement += "*"
                }
            }

            expression =
                expression.substring(0, leftNum.second) +
                        replacement +
                        expression.substring(idx + 1)
        }
        // 3. Handle Powers
        while (expression.contains("^")) {
            val idx = expression.lastIndexOf("^") // Right associative roughly
            val leftNum = extractLeftNumber(expression, idx)
            val rightNum = extractRightNumber(expression, idx)
            val result = leftNum.first.toDouble().pow(rightNum.first.toDouble())

            expression = expression.substring(0, leftNum.second) +
                    formatForCalc(result) +
                    expression.substring(rightNum.second)
        }

        // 4. Handle Multiply / Divide
        while (expression.contains("*") || expression.contains("/")) {
            val mulIdx = expression.indexOf("*")
            val divIdx = expression.indexOf("/")
            val idx = if (mulIdx == -1) divIdx else if (divIdx == -1) mulIdx else minOf(mulIdx, divIdx)

            val op = expression[idx]
            val leftNum = extractLeftNumber(expression, idx)
            val rightNum = extractRightNumber(expression, idx)

            val result = if (op == '*') {
                leftNum.first.toDouble() * rightNum.first.toDouble()
            } else {
                leftNum.first.toDouble() / rightNum.first.toDouble()
            }

            expression = expression.substring(0, leftNum.second) +
                    formatForCalc(result) +
                    expression.substring(rightNum.second)
        }


        // 5. Handle Addition / Subtraction
        // Standard scan from left to right to handle e.g. 5 - 3 + 2 correctly
        var result = 0.0
        var currentNum = ""
        var lastOp = '+'

        // Pre-processing to handle leading negative if it exists after string replacements
        // But the loop below handles it if we are careful.

        var i = 0
        while (i < expression.length) {
            val c = expression[i]

            // If it's a digit, dot, OR a negative sign at the very start of a number (scientific notation E-10)
            // But for simple calc, we just check digits.
            if (c.isDigit() || c == '.') {
                currentNum += c
            } else if (c == 'E' || c == 'e') {
                // Handle scientific notation in intermediate string if present
                currentNum += c
                // If next is + or -, consume it
                if (i + 1 < expression.length && (expression[i + 1] == '+' || expression[i + 1] == '-')) {
                    currentNum += expression[i + 1]
                    i++
                }
            } else if (c == '+' || c == '-') {
                // If currentNum is empty and we hit '-', it might be a negative start
                if (currentNum.isEmpty() && c == '-') {
                    // Check if this is truly a negative sign for the first number
                    if (lastOp == '+' && result == 0.0) {
                        // We are at start of string or reset
                        currentNum += "-"
                    } else {
                        // It's an operator
                        lastOp = c
                    }
                } else {
                    if (currentNum.isNotEmpty()) {
                        result = applyOp(result, currentNum.toDouble(), lastOp)
                        currentNum = ""
                    }
                    lastOp = c
                }
            }
            i++
        }

        if (currentNum.isNotEmpty()) {
            result = applyOp(result, currentNum.toDouble(), lastOp)
        }

        return result
    }

    private fun applyOp(left: Double, right: Double, op: Char): Double {
        return when (op) {
            '+' -> left + right
            '-' -> left - right
            else -> right
        }
    }

    // Prevents scientific notation (1E+10) from breaking the simple parser in next steps
    private fun formatForCalc(d: Double): String {
        return BigDecimal(d).toPlainString()
    }

    private fun factorial(n: Double): Double {
        if (n < 0) throw IllegalArgumentException("Negative factorial")
        if (n % 1.0 != 0.0) throw IllegalArgumentException("Non-integer factorial")

        val k = n.toLong()

        return if (k <= 20) {
            var res = 1.0
            for (i in 2..k) res *= i
            res
        } else {
            // Stirling's approximation with correction term
            val x = k.toDouble()
            sqrt(2 * Math.PI * x) *
                    (x / Math.E).pow(x) *
                    (1 + 1.0 / (12 * x) + 1.0 / (288 * x * x))
        }
    }


    private fun extractLeftNumber(expr: String, opIdx: Int): Pair<String, Int> {
        var start = opIdx - 1
        // Scan back for digits, dots, or 'E' (scientific notation support)
        while (start >= 0 && (expr[start].isDigit() || expr[start] == '.' || expr[start] == 'E' || expr[start] == 'e')) {
            start--
        }
        // Handle negative sign if it belongs to the number
        if (start >= 0 && expr[start] == '-') {
            // Check if this '-' is an operator or a sign.
            // It is a sign if the char BEFORE it is NOT a digit (or if it's start of string)
            val charBefore = if (start - 1 >= 0) expr[start - 1] else null
            if (charBefore == null || (!charBefore.isDigit() && charBefore != ')')) {
                start--
            }
        }
        return Pair(expr.substring(start + 1, opIdx), start + 1)
    }

    private fun extractRightNumber(expr: String, opIdx: Int): Pair<String, Int> {
        var end = opIdx + 1
        // Handle negative sign at start of right number (e.g. 5 * -3)
        if (end < expr.length && expr[end] == '-') {
            end++
        }
        while (end < expr.length && (expr[end].isDigit() || expr[end] == '.' || expr[end] == 'E' || expr[end] == 'e')) {
            // Handle scientific notation e.g. 1.2E-5
            if ((expr[end] == 'E' || expr[end] == 'e') && end + 1 < expr.length) {
                if (expr[end + 1] == '-' || expr[end + 1] == '+') {
                    end += 2 // Skip E and sign
                    continue
                }
            }
            end++
        }
        return Pair(expr.substring(opIdx + 1, end), end)
    }

    private fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)

        // Update Light Widgets
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

        // Update Dark Widgets
        val lightIds = appWidgetManager.getAppWidgetIds(
            android.content.ComponentName(context, TritiumWidgetLight::class.java)
        )
        darkIds.forEach { updateWidget(context, appWidgetManager, it) }
    }
}
