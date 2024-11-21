<!-- めも　
不具合：小数点使えるけど表示されなくなった、なんでやねん。税抜きがおかしくなる。MSをおすとえらーがでるよ。
MRおすと数字がでるんの数字。
未実装：+/-での符号の入れ替え。CEおすと入力直後だけが消える。00をおすと00が加えられる。
努力課題：イコールを縦2列で表示 
FB:.を二回入力した場合、０で割ったときエラー、‐から始められるように。-->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 初期値やセッションの確認
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
    String showExplanation = request.getParameter("showExplanation");

    double memory = session.getAttribute("memory") != null ? (double) session.getAttribute("memory") : 0;
    boolean calculated = "true".equals(request.getParameter("calculated"));
    boolean newNumber = "true".equals(request.getParameter("newNumber"));
    boolean isExplanationVisible = "true".equals(showExplanation);
    String error = ""; // エラー表示用変数

	 // 説明内容のリスト
    String[] explanations = {
        "数字ボタン: 0〜9の数字を入力。",
        "演算子ボタン: +, -, *, / を使用して計算。",
        "税抜き・税込みボタン: 税込み価格や税抜き価格を計算。",
        "＝ボタン: 計算結果を表示。",
        "Cボタン: 入力した数値をクリア。",
        "CEボタン: 現在の入力をクリア。",
        "±ボタン: 数値の符号を反転。",
        "√ボタン: 数値の平方根を計算。",
        "メモリ機能: メモリに値を保存したり、読み込んだり、追加したり、減算したりできます。"
    };
    
    // ボタンの動作
    if (memoryClear != null) {
        memory = 0;
    } else if (memoryRecall != null) {
        num = String.valueOf(memory);
    } else if (memorySave != null && !num.isEmpty()) {
        memory = Double.parseDouble(num);
    } else if (memoryAdd != null) {
        memory += Double.parseDouble(num);
    } else if (memorySubtract != null) {
        memory -= Double.parseDouble(num);
    } else if (clear != null) {
        if (clear.equals("CE")) {
        	num = "";
        } else {
            expression = "";
            num = "";
            calculated = false;
            newNumber = false;
            error = ""; // エラーもクリア
        }
    } else if (negate != null) {
        if (num.isEmpty()) {
            num = "-"; // 数値が空の場合、`-` のみを設定
        } else if (num.equals("-")) {
            num = ""; // `-` がすでに入力されている場合はクリア
        } else {
            num = String.valueOf(-Double.parseDouble(num)); // 符号反転
        }
    } else if(input != null && input.equals(".") && !num.contains(".")) {
        num += ".";
    }else if (taxIncluded != null) {
        num = String.valueOf(Double.parseDouble(num) * 1.1);
    } else if (taxExcluded != null) {
        num = String.valueOf(Double.parseDouble(num) / 1.1);
    } else if (percent != null) {
        num = String.valueOf(Double.parseDouble(num) / 100);
    } else if (squareRoot != null) {
        try {
            double value = Double.parseDouble(num);
            if (value >= 0) {
                num = String.valueOf(Math.sqrt(value));
            } else {
                error = "Error";
            }
        } catch (Exception e) {
            error = "Error";
        }
    } else if (input != null) {
        // 数字と演算子の入力処理
        if (calculated) {
            expression = "";  // 計算後に式をリセット
            num = input;      // 新しい数値を入力
            calculated = false;
            newNumber = false;
    	}else {
            if (input.matches("[0-9]")) {
                if (newNumber && num.equals("-")) {  // 新しい数値の入力、または `-` の後
                    num += input;  // 負号後に数字を続けて入力
                    newNumber = false;
                } else if(newNumber){
                	num = input;
                	newNumber = false;
                } else {
                    num += input;  // 通常の数字入力
                }
            } else if (input.equals("-") && (num.isEmpty() || num.matches("[-]"))) {
                // 数値が空または `-` のみの状態で再度 `-` を入力
                num = num.equals("-") ? "" : "-";  // 切り替え
            } else {
                expression += num + input;  // 演算子を含む式を入力
                // 演算子入力後に num をリセット
                newNumber = true;
            }
        }
    } else if (calculate != null && !expression.isEmpty()) {
        try {
            expression += num;  // 現在の数値を式に追加
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
                            error = "Error";
                            throw new ArithmeticException("Division by zero");
                        }
                        break;
                }
            }
            if(result == Math.floor(result)){
            	expression = String.valueOf((int)result);
            }else{
            	expression = String.valueOf(result);  // 結果を式に設定
            }
            num = "";  // 計算後に num をリセット
            calculated = true;
            newNumber = false;
        } catch (Exception e) {
            error = "Error";  // 計算エラー
            expression = "";
            num = "";
            calculated = false;
            newNumber = false;
        }
    }

    session.setAttribute("memory", memory);
    String displayExpression = error.isEmpty() ? (calculated ? expression : num) : error;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Calculator</title>
<style>
/* Bodyのスタイル */
body {
    font-family: Arial, sans-serif;
    display: flex;
    justify-content: center;
    align-items: center;
 
    margin: 0;
}

.explanation-list {
    width: 200px;
    height: 100%;
    background-color: #f7f7f7;
    position: absolute;
    left: 0;
    top: 0;
    padding: 10px;
    border-right: 2px solid #333;
    display: <% if (isExplanationVisible) { %> block <% } else { %> none <% } %>;
}

/* 計算機コンテナのスタイル */
.calculator {
	margin-left: 220px; /* 説明が表示されているときに左にスペースを作る */
    width: 360px;
    text-align: center;
    border: 2px solid #333;
    padding: 5px;
    border-radius: 8px;
}

/* ディスプレイのスタイル */
.display {
    text-align: right;
    font-size: 1.2em;
    margin-bottom: 10px;
    padding: 10px; /* ボタンのサイズに合わせて調整 */
    height: 50px; /* 固定サイズに変更 */
    border: 1px solid #333;
    border-radius: 4px;
    background-color: #f7f7f7;
    overflow: hidden; /* テキストがオーバーフローする場合 */
    white-space: nowrap; /* テキストが折り返されないように */
    text-overflow: ellipsis; /* 長いテキストを省略 */
}

/* ボタンのグリッドレイアウト */
.buttons {
    display: grid;
    grid-template-columns: repeat(4, 1fr); /* 4列に分ける */
    grid-template-rows: repeat(5, 1fr);    /* 5行に分ける */
    gap: 5px;
}

/* 一般的なボタンのスタイル */
button {
    font-size: 1.2em;
    padding: 15px;
    margin-bottom: 5px;
    width: 60px; /* ボタンの幅を固定 */
    height: 50px; /* ボタンの高さを固定 */
    border: none;
    border-radius: 4px;
    background-color: #e0e0e0;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

/* ボタンにホバーしたときの効果 */
button:hover {
    background-color: #d0d0d0;
}

/* 演算子ボタンの特別なスタイル */
.operator {
    background-color: #ffbf00;
    color: white;
}

.operator:hover {
    background-color: #ff9f00;
}

/* イコールボタンの特別なスタイル */
.equal {
    background-color: #4caf50;
    color: white;
    grid-row: span 2;  /* 縦に2行にまたがる */
    grid-column: 4;   /* 4列目に配置 */
}

.equal:hover {
    background-color: #45a049;
}

/* クリアボタンの特別なスタイル */
.clear {
    background-color: #f44336;
    color: white;
}

.clear:hover {
    background-color: #e53935;
}

/* 0ボタンの特別なスタイル */
.zero {
    grid-column: span 2; /* 0ボタンは2列分にまたがる */
    grid-row: 5;         /* 5行目に配置 */
}

/* 税込み・税抜きボタンのスタイル */
.tax-button {
    font-size: 0.1em; /* 小さな文字サイズ */
    display: inline-flex; /* 横並びにするため */
    width: 60px; /* 幅を固定 */
    height: 50px; /* 高さを調整 */
    background-color: #f0f0f0;
    color: #333;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

/* 税込み・税抜きボタンにホバーしたときの効果 */
.tax-button:hover {
    background-color: #e0e0e0;
}


</style>
</head>
<body>
<div class="explanation-list">
    <h3>説明</h3>
    <ul>
        <% for (String explanation : explanations) { %>
            <li><%= explanation %></li>
        <% } %>
    </ul>
</div>

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
            <button type="submit" class="clear" name="clear" value="CE">CE</button>
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
            <button type="submit" class="button equal" name="calculate" value="=">=</button>
            
            <button type="submit" class="button" name="input" value="0">0</button>
            <button type="submit" class="button" name="input" value="00">00</button>
            <button type="submit" class="button" name="input" value=".">.</button>
            <button type="submit" class="button operator" name="input" value="+">+</button>
            <button type="submit" class="button" name="showExplanation" value="true">?</button>
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
