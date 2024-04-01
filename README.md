
stone是一门脚本语言

## 语法定义

```text
    primary    : "(" expr ")" | NUMBER | IDENTIFIER | STRING
    factor     : [ OP ] primary
    expr       : factor { OP factor }
    block      : "{" [ statement ] {("; " | EOL) [ statement ]} "}"
    statement  : "if" expr block [ "else" block ]
                | "while" expr block
                | expr
    program    : [ statement ] ("; " | EOL)
```

其中，  
program 代表 一条完整的语句  
primary 代表 基本构成元素  
OP 代表 运算符  
EOL 代表 换行符  

