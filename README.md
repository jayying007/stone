
stone是一门脚本语言。
- [x] 支持基本的控制语句（表达式、条件判断、循环等）
- [x] 支持函数声明、调用
- [x] 支持原生函数调用（目前支持：输出printf）

## 语法定义

```text
    args       : expr { "," expr }
    postfix    : "." IDENTIFIER | "(" [ args ] ")"
    primary    : ("(" expr ")" | NUMBER | IDENTIFIER | STRING ) { postfix }
    factor     : [ OP ] primary
    expr       : factor { OP factor }
    block      : "{" [ statement ] {("; " | EOL) [ statement ]} "}"
    param      : IDENTIFIER
    params     : param { "," param }
    param_list : "(" [ params ] ")"
    def        : "def" IDENTIFIER param_list block
    member     : def | expr
    class_body : "{" [ member ] {("; " | EOL) [ member ]} "}"
    defclass   : "class" IDENTIFIER [ "extends" IDENTIFIER ] class_body
    statement  : "if" expr block [ "else" block ]
                | "while" expr block
                | expr
    program    : [ defclass | def | statement ] ("; " | EOL)
```

其中，  
program 代表 一条完整的语句  
primary 代表 基本构成元素  
OP 代表 运算符  
EOL 代表 换行符  

## 代码
### 示例1
```
res = 0
i = 0
while i < 10 {
   if i % 2 == 0 {
      res = res + i
   }
   i = i + 1
}

if res > 10 {
   printf("Hello world")
} else {
   printf("Hello stone")
}
// 输出
// Hello world
```
### 示例2
```
def fact(n) {
   f = 0
   if n == 1 {
      f = 1
   } else {
      f = fact(n - 1) * n
   }
   f
}
ans = fact(5)
printf("ans is:" + ans)
// 输出
// ans is:120
```
### 示例3
```
def hanota(n, A, B, C) {
   if n == 1 {
      printf(A + " --> " + C)
   } else {
      hanota(n - 1, A, C, B)
      printf(A + " --> " + C)
      hanota(n - 1, B, A, C)
   }
}
hanota(3, "A", "B", "C")
// 输出
// A --> C
// A --> B
// C --> B
// A --> C
// B --> A
// B --> C
// A --> C
```

## 设计思想
### 面向对象
首先需要有一个ClassInfo来存储类的相关信息。  
接着在创建对象时，将ClassInfo的信息添加到这个对象的上下文中，函数也要绑定到对应的上下文。