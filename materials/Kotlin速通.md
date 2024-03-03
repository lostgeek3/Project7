# Kotlin速通

[数据关键字](#数据关键字)

[数据类型](#数据类型)

[数据结构](#数据结构)

[分支结构](#分支结构)

[范围表示](#范围表示)

[循环](#循环)

[函数](#函数)

[类](#类)

### 数据关键字

```kotlin
val a = 1; //只读

var b = 2; //变量
b = 3;  
```

### 数据类型

| **Category**           | **Basic types**                    |
| ---------------------- | ---------------------------------- |
| Integers               | `Byte`, `Short`, `Int`, `Long`     |
| Unsigned integers      | `UByte`, `UShort`, `UInt`, `ULong` |
| Floating-point numbers | `Float`, `Double`                  |
| Booleans               | `Boolean`                          |
| Characters             | `Char`                             |
| Strings                | `String`                           |

```kotlin
// Variable declared without initialization
val d: Int
// Variable initialized
d = 3

// Variable explicitly typed and initialized
val e: String = "hello"

e.startsWith(h) // True
```

### 数据结构

| **Collection type** | **Description**                                                         |
| ------------------- | ----------------------------------------------------------------------- |
| Lists               | Ordered collections of items                                            |
| Sets                | Unique unordered collections of items                                   |
| Maps                | Sets of key-value pairs where keys are unique and map to only one value |

1. Lists
   
   ```kotlin
   // Read only list
   val readOnlyShapes = listOf("triangle", "square", "circle")
   
   // Mutable list with explicit type declaration
   val shapes: MutableList<String> = mutableListOf("triangle", "square", "circle")
   
   shapes.first()
   shapes.last()
   shapes.count() // length
   prinln("square" in shapes) // True
   shapes.add("pentagon") 
   shapes.remove("pentagon")
   ```

2. Sets
   
   ```kotlin
   // Read-only set
   val readOnlyFruit = setOf("apple", "banana", "cherry", "cherry")
   // Mutable set with explicit type declaration
   val fruit: MutableSet<String> = mutableSetOf("apple", "banana", "cherry", "cherry")
   
   fruit.count()
   "banana" in fruit 
   fruit.add("dragonfruit")
   fruit.remove("dragonfruit")
   ```

3. Maps
   
   ```kotlin
   // Read-only map
   val readOnlyJuiceMenu = mapOf("apple" to 100, "kiwi" to 190, "orange" to 100)
   // Mutable map with explicit type declaration
   val juiceMenu: MutableMap<String, Int> = mutableMapOf("apple" to 100, "kiwi" to 190, "orange" to 100)
   
   juiceMenu["apple"]
   juiceMenu.count()
   juiceMenu.put("coconut", 150)
   juiceMenu.remove("orange")
   juiceMenu.containsKey("kiwi")
   
   println(readOnlyJuiceMenu.keys)
   // [apple, kiwi, orange]
   println(readOnlyJuiceMenu.values)
   // [100, 190, 100]
   
   println("orange" in readOnlyJuiceMenu.keys)
   // true
   println(200 in readOnlyJuiceMenu.values)
   // false
   ```

### 分支结构

1. if
   
   ```kotlin
   val a = 1
   val b = 2
   
   println(if (a > b) a else b) // Returns a value: 2
   ```

2. when
   
   ```kotlin
   val obj = "Hello"
   
   // 约等于switch
   // 只执行第一个满足条件的case
   when (obj) {
       // Checks whether obj equals to "1"
       "1" -> println("One")
       // Checks whether obj equals to "Hello"
       "Hello" -> println("Greeting")
       // Default statement
       else -> println("Unknown")     
   }
   // Greeting
   
   val result = when (obj) {
       // If obj equals "1", sets result to "one"
       "1" -> "One"
       // If obj equals "Hello", sets result to "Greeting"
       "Hello" -> "Greeting"
       // Sets result to "Unknown" if no previous condition is satisfied
       else -> "Unknown"
   }
   println(result)
   // Greeting
   
   // 多分支结构
   val temp = 18
   
   val description = when {
       // If temp < 0 is true, sets description to "very cold"
       temp < 0 -> "very cold"
       // If temp < 10 is true, sets description to "a bit cold"
       temp < 10 -> "a bit cold"
       // If temp < 20 is true, sets description to "warm"
       temp < 20 -> "warm"
       // Sets description to "hot" if no previous condition is satisfied
       else -> "hot"             
   }
   println(description)
   // warm
   ```

### 范围表示

```kotlin
1..4 // 1, 2, 3, 4
1..<4 // 1, 2, 3
4 downTo 1 // 4, 3, 2, 1
1..5 step 2 // 1, 3, 5

'a'..'d' // 'a', 'b', 'c', 'd'
'z' downTo 's' step 2 // 'z', 'x', 'v', 't'
```

### 循环

1. For
   
   ```kotlin
   for (number in 1..5) { 
       // number is the iterator and 1..5 is the range
       print(number)
   }
   
   val cakes = listOf("carrot", "cheese", "chocolate")
   for (cake in cakes) {
       println("Yummy, it's a $cake cake!")
   }
   ```

2. While

### 函数

```kotlin
fun sum(x: Int, y: Int): Int {
    return x + y
}

// 省去大括号的简化版
fun sum(x: Int, y: Int) = x + y // 返回值类型可以省略
```

```kotlin
fun printMessageWithPrefix(message: String, prefix: String) {
    println("[$prefix] $message")
}
// 没有返回值时，返回值是Unit类型的值Unit

fun main() {
    // Uses named arguments with swapped parameter order
    // 指明参数名时，可以不按照顺序
    printMessageWithPrefix(prefix = "Log", message = "Hello")
    // [Log] Hello
}
```

```kotlin
// 参数默认值
fun printMessageWithPrefix(message: String, prefix: String = "Info") {
    println("[$prefix] $message")
}

fun main() {
    // Function called with both parameters
    printMessageWithPrefix("Hello", "Log") 
    // [Log] Hello

    // Function called only with message parameter
    printMessageWithPrefix("Hello")        
    // [Info] Hello

    printMessageWithPrefix(prefix = "Log", message = "Hello")
    // [Log] Hello
}
```

```kotlin
// lambda表达式
fun main() {
    println({ string: String -> string.uppercase() }("hello"))
    // HELLO
}

// Assign to variable﻿
fun main() {
    val upperCaseString = { string: String -> string.uppercase() }
    println(upperCaseString("hello"))
    // HELLO
}

// Pass to another function﻿
val numbers = listOf(1, -2, 3, -4, 5, -6)
val positives = numbers.filter { x -> x > 0 }
val negatives = numbers.filter { x -> x < 0 }
println(positives)
// [1, 3, 5]
println(negatives)
// [-2, -4, -6]

// 函数的类型
val upperCaseString: (String) -> String = { string -> string.uppercase() }

fun main() {
    println(upperCaseString("hello"))
    // HELLO
}
```

### 类

```kotlin
class Contact(val id: Int, var email: String = "example@gmail.com") {
    val category: String = "work"
    fun printId() {
        println(id)
    }
}
// 括号里是class header
// 大括号里是class body
// 默认情况class header是constructor
val contact = Contact(1, "mary@gmail.com")
```

###### 数据类

```kotlin
data class User(val name: String, val id: Int)
val user = User("Alex", 1)

// Automatically uses toString() function so that output is easy to read
println(user)            
// User(name=Alex, id=1)

// 可以用 == 比较

// 拷贝构造
// Creates a copy of user with name: "Max"
println(user.copy("Max"))  
// User(name=Max, id=1)

// Creates a copy of user with id: 3
println(user.copy(id = 3)) 
// User(name=Alex, id=3)
```

### Null

```kotlin
// Nullable type需要用?显式指定
fun main() {
    // neverNull has String type
    var neverNull: String = "This can't be null"

    // Throws a compiler error
    neverNull = null

    // nullable has nullable String type
    var nullable: String? = "You can keep a null here"

    // This is OK  
    nullable = null

    // By default, null values aren't accepted
    var inferredNonNull = "The compiler assumes non-nullable"

    // Throws a compiler error
    inferredNonNull = null

    // notNull doesn't accept null values
    fun strLength(notNull: String): Int {                 
        return notNull.length
    }

    println(strLength(neverNull)) // 18
    println(strLength(nullable))  // Throws a compiler error
}
```

```kotlin
// 安全调用可能为null的值的成员
fun lengthString(maybeString: String?): Int? = maybeString?.length

fun main() { 
    var nullString: String? = null
    println(lengthString(nullString))
    // null
}
```

###### Elvis operator

可能为null的变量 ?: 如果为null的返回值

```kotlin
fun main() {
    var nullString: String? = null
    println(nullString?.length ?: 0)
    // 0
}
```
