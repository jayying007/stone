
stone是一门简单的脚本语言，适合用来学习

有以下特性：  
- [x] 支持基本的控制语句（表达式、条件判断、循环等）
- [x] 支持函数声明、调用
- [x] 支持原生函数调用（目前支持：输出printf）
- [x] 支持面向对象、单一继承 

没有添加的：
- [ ] 数组通过下标访问
- [ ] 函数闭包
- [ ] 优化变量/函数的访问

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
### 示例4
```
class Array {
   pointer = 0
   index = 0
   def init(count) {
      pointer = array(count)
   }
   def add(value) {
      arraySet(pointer, index, value)
      index = index + 1
   }
   def get(index) {
      arrayGet(pointer, index)
   }
}

arr = Array.new
arr.init(10)
arr.add("J")
arr.add("a")
arr.add("y")

name = arr.get(0) + arr.get(1) + arr.get(2)
printf(name)
// 输出
// Jay
```
### 示例5
```
class Position {
   x = y = 0
   def move (nx, ny) {
      x = nx; y = ny
   }
}
class Pos3D extends Position {
   z = 0
   copy = Position.new   // 如果是Pos3D会翻车
   def set (nx, ny, nz) {
         this.move(nx, ny)
         z = nz
   }
}
p = Pos3D.new
p.set(5, 6, 7)
printf("x:" + p.x + " y:" + p.y + " z:" + p.z)
p.copy.x = 10086
printf(p.copy.x)
// 输出
// x:5 y:6 z:7
// 10086
```

## 设计思路
### 面向对象
首先需要有一个ClassInfo来存储类的相关信息。  
接着在创建对象时，将ClassInfo的信息添加到这个对象的上下文中，函数也要绑定到对应的上下文。
> 实际上这有些性能问题，但这是最简单的实现方式
### 数组
基于简单考虑，这里并没有添加数组下标的支持。  
可以参考代码示例4的实现方式创建一个Array类，然后支持array,arrayGet,arraySet原生函数即可。
> 同理可以实现所有的数据结构

## 命令行构建
```shell
xcodebuild -project stone.xcodeproj -scheme stone -derivedDataPath output
```