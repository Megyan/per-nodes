# String

## Java内存模型
Java的堆是一个运行时数据区.堆是由垃圾回收来负责的，堆的优势是可以动态地分配内存大小，生存期也不必事先告诉编译器，因为它是在运行时动态分配内存的，Java的垃圾收集器会自动收走这些不再使用的数据。但缺点是，由于要在运行时动态分配内存，存取速度较慢
 
栈的优势是，存取速度比堆要快，仅次于寄存器，栈数据可以共享。但缺点是，存在栈中的数据大小与生存期必须是确定的，缺乏灵活性。栈中主要存放一些基本类型的变量数据（int, short, long, byte, float, double, boolean, char）和对象句柄(引用)

JVM会在方法区为每个被装载的类型维护一个常量池。常量池就是该类型所用到常量的一个有序集合，包括直接常量（string,integer和 floating point常量）和对其他类型，字段和方法的符号引用

对于String常量，它的值是在常量池中的。而JVM中的常量池在内存当中是以表的形式存在的， 对于String类型，有一张固定长度的CONSTANT_String_info表用来存储文字字符串值，注意：该表只存储文字字符串值，不存储符号引用。

## 特性实例

```java
public static void main(String[] args) {  
        /** 
         * 情景一：字符串池 
         * JAVA虚拟机(JVM)中存在着一个字符串池，其中保存着很多String对象; 
         * 并且可以被共享使用，因此它提高了效率。 
         * 由于String类是final的，它的值一经创建就不可改变。 
         * 字符串池由String类维护，我们可以调用intern()方法来访问字符串池。  
         */  
        String s1 = "abc";     
        //↑ 在字符串池创建了一个对象  
        String s2 = "abc";     
        //↑ 字符串pool已经存在对象“abc”(共享),所以创建0个对象，累计创建一个对象  
        System.out.println("s1 == s2 : "+(s1==s2));    
        //↑ true 指向同一个对象，  
        System.out.println("s1.equals(s2) : " + (s1.equals(s2)));    
        //↑ true  值相等  
        //↑------------------------------------------------------over  
        /** 
         * 情景二：关于new String("") 
         *  
         */  
        String s3 = new String("abc");  
        //↑ 创建了两个对象，一个存放在字符串池中，一个存在与堆区中；  
        //↑ 还有一个对象引用s3存放在栈中  
        String s4 = new String("abc");  
        //↑ 字符串池中已经存在“abc”对象，所以只在堆中创建了一个对象  
        System.out.println("s3 == s4 : "+(s3==s4));  
        //↑false   s3和s4栈区的地址不同，指向堆区的不同地址；  
        System.out.println("s3.equals(s4) : "+(s3.equals(s4)));  
        //↑true  s3和s4的值相同  
        System.out.println("s1 == s3 : "+(s1==s3));  
        //↑false 存放的地区多不同，一个栈区，一个堆区  
        System.out.println("s1.equals(s3) : "+(s1.equals(s3)));  
        //↑true  值相同  
        //↑------------------------------------------------------over  
        /** 
         * 情景三：  
         * 由于常量的值在编译的时候就被确定(优化)了。 
         * 在这里，"ab"和"cd"都是常量，因此变量str3的值在编译时就可以确定。 
         * 这行代码编译后的效果等同于： String str3 = "abcd"; 
         */  
        String str1 = "ab" + "cd";  //1个对象  
        String str11 = "abcd";   
        System.out.println("str1 = str11 : "+ (str1 == str11));  
        //↑------------------------------------------------------over  
        /** 
         * 情景四：  
         * 局部变量str2,str3存储的是存储两个拘留字符串对象(intern字符串对象)的地址。 
         *  
         * 第三行代码原理(str2+str3)： 
         * 运行期JVM首先会在堆中创建一个StringBuilder类， 
         * 同时用str2指向的拘留字符串对象完成初始化， 
         * 然后调用append方法完成对str3所指向的拘留字符串的合并， 
         * 接着调用StringBuilder的toString()方法在堆中创建一个String对象， 
         * 最后将刚生成的String对象的堆地址存放在局部变量str3中。 
         *  
         * 而str5存储的是字符串池中"abcd"所对应的拘留字符串对象的地址。 
         * str4与str5地址当然不一样了。 
         *  
         * 内存中实际上有五个字符串对象： 
         *       三个拘留字符串对象、一个String对象和一个StringBuilder对象。 
         */  
        String str2 = "ab";  //1个对象  
        String str3 = "cd";  //1个对象                                         
        String str4 = str2+str3;                                        
        String str5 = "abcd";    
        System.out.println("str4 = str5 : " + (str4==str5)); // false  
        //↑------------------------------------------------------over  
        /** 
         * 情景五： 
         *  JAVA编译器对string + 基本类型/常量 是当成常量表达式直接求值来优化的。 
         *  运行期的两个string相加，会产生新的对象的，存储在堆(heap)中 
         */  
        String str6 = "b";  
        String str7 = "a" + str6;  
        String str67 = "ab";  
        System.out.println("str7 = str67 : "+ (str7 == str67));  
        //↑str6为变量，在运行期才会被解析。  
        final String str8 = "b";  
        String str9 = "a" + str8;  
        String str89 = "ab";  
        System.out.println("str9 = str89 : "+ (str9 == str89));  
        //↑str8为常量变量，编译期会被优化  
        //↑------------------------------------------------------over  
    }
```

**关注点:**

* 1.情景三与情景四的区别在于

```java
String str4 = str2+str3;  //情景四是使用形参 这一句产生了两个对象,一个中间对象StringBuilder,一个最终对象String
String str1 = "ab" + "cd";  //情景三使用实参 
```

* 2.情景五表达了,对于final修饰的常量,编译时会优化,直接用真实的值(实参)代替引用(形参)

## 总结

* 1.String类初始化后是不可变的(immutable)
* 2.代码中的字符串常量在编译的过程中收集并放在class文件的常量区中，如"123"、"123"+"456"等，含有变量的表达式不会收录，如"123"+a
* 3.JVM在加载类的时候，根据常量区中的字符串生成常量池，每个字符序列如"123"会生成一个实例放在常量池里，这个实例是不在堆里的，也不会被GC
* 4.使用String不一定创建对象

```
在执行到双引号包含字符串的语句时，如String a = "123"，JVM会先到常量池里查找，如果有的话返回常
量池里的这个实例的引用，否则的话创建一个新实例并置入常量池里。如果是 String a = "123" + b (假
设b是"456")，前半部分"123"还是走常量池的路线，但是这个+操作符其实是转换成
[SringBuffer].Appad()来实现的，所以最终a得到是一个新的实例引用，而且a的value存放的是一个新申
请的字符数组内存空间的地址(存放着"123456")，而此时"123456"在常量池中是未必存在的
```

* 5.使用new String，一定创建对象

```
在执行String a = new String("123")的时候，首先走常量池的路线取到一个实例的引用，然后在堆上创
建一个新的String实例，走以下构造函数给value属性赋值，然后把实例引用赋值给a
```

* 6.String.intern()

存在于.class文件中的常量池，在运行期被JVM装载，并且可以扩充。String的 intern()方法就是扩充常量池的 一个方法；当一个String实例str调用intern()方法时，Java 查找常量池中 是否有相同Unicode的字符串常量，如果有，则返回其的引用，如果没有，则在常 量池中增加一个Unicode等于str的字符串并返回它的引用

【参考】
<http://www.cnblogs.com/ITtangtang/p/3976820.html>

