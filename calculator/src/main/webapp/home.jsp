<!-- めも　
不具合：小数点使えるけど表示されなくなった、なんでやねん。税抜きがおかしくなる。MSをおすとえらーがでるよ。
MRおすと数字がでるんの数字。
未実装：+/-での符号の入れ替え。CEおすと入力直後だけが消える。00をおすと00が加えられる。
努力課題：イコールを縦2列で表示 
FB:.を二回入力した場合、０で割ったときエラー、‐から始められるように。-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Calculator</title>
<link rel="stylesheet" type="text/css" href="calculator.css">
</head>
<body>
<% 
    // 現在の数式、入力された数字、ボタンからの入力を取得
    String expression = request.getParameter("expression") != null ? request.getParameter("expression") : "";
    String num = request.getParameter("num") != null ? request.getParameter("num") : ""; 
    String input = request.getParameter("input");
    String calculate = request.getParameter("calculate");
    String clear = request.getParameter("clear");
    String memoryClear = request.getParameter("clearMemory");
    String memoryRecall = request.getParameter("recallMemory");
    String memorySave = request.getParameter("saveMemory");
    String memoryAdd = request.getParameter("addMemory");
    String memorySubtract = request.getParameter("subtractMemory");
    String taxIncluded = request.getParameter("taxIncluded");
    String taxExcluded = request.getParameter("taxExcluded");
    String percent = request.getParameter("percent");
    String squareRoot = request.getParameter("squareRoot");
    String negate = request.getParameter("negate");

    // メモリ機能に関する処理
    double memory = session.getAttribute("memory") != null ? (double) session.getAttribute("memory") : 0.0;
    boolean calculated = "true".equals(request.getParameter("calculated"));
    boolean newNumber = "true".equals(request.getParameter("newNumber"));

    // 各種ボタンの処理
    if (memoryClear != null) {
        memory = 0; // メモリクリア
    } else if (memoryRecall != null) {
        num = String.valueOf(memory); // メモリの呼び出し
    } else if (memorySave != null) {
        memory = Double.parseDouble(num); // メモリに保存
    } else if (memoryAdd != null) {
        memory += Double.parseDouble(num); // メモリに加算
    } else if (memorySubtract != null) {
        memory -= Double.parseDouble(num); // メモリから減算
    } else if (clear != null) {
        // クリアボタン処理
        expression = ""; 
        num = "";
        calculated = false;
        newNumber = false;
    } else if (negate != null) {
        num = String.valueOf(-Double.parseDouble(num)); // 符号反転
    } else if (taxIncluded != null) {
        num = String.valueOf(Double.parseDouble(num) * 1.1); // 税込計算
    } else if (taxExcluded != null) {
        num = String.valueOf(Double.parseDouble(num) / 1.1); // 税抜計算
    } else if (percent != null) {
        num = String.valueOf(Double.parseDouble(num) / 100); // パーセント計算
    } else if (squareRoot != null) {
        num = String.valueOf(Math.sqrt(Double.parseDouble(num))); // 平方根計算
    } else if (input != null) {
        // 数字と演算子の入力処理
        if (calculated) {
            expression = "";
            num = input;
            calculated = false;
            newNumber = false;
        } else {
            if (input.matches("[0-9]")) {
                if (newNumber) {
                    num = input;
                    newNumber = false;
                } else {
                    num += input;
                }
            } else {
                expression += num + input;
                newNumber = true;
            }
        }
    } else if (calculate != null && !expression.isEmpty()) {
        // 計算実行
        try {
            expression += num;
            String[] tokens = expression.split("((?<=[-+*/])|(?=[-+*/]))");
            double result = Double.parseDouble(tokens[0]);

            for (int i = 1; i < tokens.length; i += 2) {
                String operator = tokens[i];
                double nextNum = Double.parseDouble(tokens[i + 1]);
                switch (operator) {
                    case "+": result += nextNum; break;
                    case "-": result -= nextNum; break;
                    case "*": result *= nextNum; break;
                    case "/": 
                        if (nextNum != 0) {
                            result /= nextNum;
                        } else {
                            out.println("<p>Error</p>");
                            expression = ""; 
                        }
                        break;
                }
            }
            expression = String.valueOf(result);
            num = "";
            calculated = true;
            newNumber = false;
        } catch (Exception e) {
            out.println("<p>Error</p>");
            expression = "";
            num = "";
            calculated = false;
            newNumber = false;
        }
    }

    // メモリ値の保存
    session.setAttribute("memory", memory);
    String displayExpression = calculated ? expression : num;
%>

<div class="calculator">
    <h2>Calculator</h2>
    <div class="display"><%= displayExpression %></div>
    <form action="home.jsp" method="post">
        <div class="buttons">
            <button type="submit" class="button memory" name="clearMemory" value="MC">MC</button>
            <button type="submit" class="button memory" name="recallMemory" value="MR">MR</button>
            <button type="submit" class="button memory" name="saveMemory" value="MS">MS</button>
            <button type="submit" class="button memory" name="addMemory" value="+M">+M</button>
            <button type="submit" class="button memory" name="subtractMemory" value="-M">-M</button>
            
            <button type="submit" class="button operator" name="negate" value="+/-">+/-</button>
            <button type="submit" class="clear" name="clear" value="clear">CE</button>
            <button type="submit" class="clear" name="clear" value="clear">C</button>
            <button type="submit" class="tax_button" name="taxIncluded" value="taxIncluded">税</button>
            <button type="submit" class="tax_botton" name="taxExcluded" value="taxExcluded">抜</button>
            
            <button type="submit" class="button" name="input" value="7">7</button>
            <button type="submit" class="button" name="input" value="8">8</button>
            <button type="submit" class="button" name="input" value="9">9</button>
            <button type="submit" class="button operator" name="input" value="/">÷</button>
            <button type="submit" class="button operator" name="percent" value="%">%</button>
            
            <button type="submit" class="button" name="input" value="4">4</button>
            <button type="submit" class="button" name="input" value="5">5</button>
            <button type="submit" class="button" name="input" value="6">6</button>
            <button type="submit" class="button operator" name="input" value="*">×</button>
            <button type="submit" class="button operator" name="squareRoot" value="√">√</button>
            
            <button type="submit" class="button" name="input" value="1">1</button>
            <button type="submit" class="button" name="input" value="2">2</button>
            <button type="submit" class="button" name="input" value="3">3</button>
            <button type="submit" class="button operator" name="input" value="-">-</button>
            <button type="submit" class="button operator" name="input" value="-">-</button>
            
            <button type="submit" class="button" name="input" value="0">0</button>
            <button type="submit" class="button" name="input" value="00">00</button>
            <button type="submit" class="button" name="input" value=".">.</button>
            <button type="submit" class="button operator" name="input" value="+">+</button>
            <button type="submit" class="button equal" name="calculate" value="=">=</button>
        </div>

        <!-- 隠しフィールドで現在の数式と状態を保存 -->
        <input type="hidden" name="expression" value="<%= expression %>">
        <input type="hidden" name="num" value="<%= num %>">
        <input type="hidden" name="calculated" value="<%= calculated ? "true" : "false" %>">
        <input type="hidden" name="newNumber" value="<%= newNumber ? "true" : "false" %>">
    </form>
</div>
</body>
</html>
